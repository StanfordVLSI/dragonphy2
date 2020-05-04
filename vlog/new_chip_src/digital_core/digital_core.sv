    `default_nettype none

module digital_core import const_pack::*; (
    input wire logic clk_adc,                           
    input wire logic [Nadc-1:0] adcout [Nti-1:0],
    input wire logic [Nti-1:0]  adcout_sign ,
    input wire logic [Nadc-1:0] adcout_rep [Nti_rep-1:0],
    input wire logic [Nti_rep-1:0] adcout_sign_rep,
    input wire logic ext_rstb,
    input wire logic clk_async,
    output wire logic clk_cdr,  
    output wire logic  [Npi-1:0] int_pi_ctl_cdr [Nout-1:0],
    output wire logic clock_out_p,
    output wire logic clock_out_n,
    output wire logic trigg_out_p,
    output wire logic trigg_out_n,
    input wire logic ext_dump_start,
    acore_debug_intf.dcore adbg_intf_i,
    jtag_intf.target jtag_intf_i
);

    // internal signals
    cdr_debug_intf cdbg_intf_i ();
    sram_debug_intf #(.N_mem_tiles(4)) sm_dbg_intf_i ();
    dcore_debug_intf ddbg_intf_i ();
    dsp_debug_intf dsp_dbg_intf_i();
    prbs_debug_intf pdbg_intf_i ();
    wme_debug_intf wdbg_intf_i ();

    
  //  wire logic ext_rstb;
    wire logic rstb;
    wire logic clk_avg;
    wire logic [Nadc-1:0] adcout_retimed [Nti-1:0];
    wire logic [Nti-1:0] adcout_sign_retimed;
    wire logic [Nadc-1:0] adcout_retimed_rep [Nti_rep-1:0];
    wire logic [Nti_rep-1:0] adcout_sign_retimed_rep;
    wire logic [Npi-1:0] pi_ctl_cdr[Nout-1:0];
    wire logic int_clk_cdr;
    wire logic clk_cdr_in;
    wire logic sram_rstb;
    wire logic cdr_rstb;
    wire logic prbs_rstb;
   // wire logic bufferend_signals[15:0];
    wire logic buffered_signals[15:0];
    wire logic signed [Nadc-1:0] adcout_unfolded [Nti+Nti_rep-1:0];

    wire logic signed [ffe_gpack::output_precision-1:0] estimated_bits [constant_gpack::channel_width-1:0];
    wire logic checked_bits [constant_gpack::channel_width-1:0];

    wire logic [Npi-1:0] scale_value [Nout-1:0];
    wire logic [Npi-1:0] unscaled_pi_ctl [Nout-1:0];
    wire logic [Npi+Npi-1:0] scaled_pi_ctl [Nout-1:0];
    
    initial begin
        $shm_probe(pi_ctl_cdr);
    end


    assign rstb             = ddbg_intf_i.int_rstb  && ext_rstb; //combine external reset with JTAG reset\
    assign sram_rstb        = ddbg_intf_i.sram_rstb && ext_rstb;
    assign cdr_rstb         = ddbg_intf_i.cdr_rstb  && ext_rstb;
    assign prbs_rstb        = ddbg_intf_i.prbs_rstb && ext_rstb;
    //assign adbg_intf_i.rstb = rstb;

    assign clk_cdr = clk_adc;

    assign buffered_signals[0]  = clk_adc;
    assign buffered_signals[1]  = adbg_intf_i.del_out_pi;
    assign buffered_signals[2]  = adbg_intf_i.pi_out_meas[0];
    assign buffered_signals[3]  = adbg_intf_i.pi_out_meas[1];
    assign buffered_signals[4]  = adbg_intf_i.pi_out_meas[2];
    assign buffered_signals[5]  = adbg_intf_i.pi_out_meas[3];
    assign buffered_signals[6]  = adbg_intf_i.del_out_rep[0];
    assign buffered_signals[7]  = adbg_intf_i.del_out_rep[1];
    assign buffered_signals[8]  = adbg_intf_i.inbuf_out_meas;
    assign buffered_signals[9]  = adbg_intf_i.pfd_inp_meas;
    assign buffered_signals[10] = adbg_intf_i.pfd_inn_meas;
    assign buffered_signals[11] = clk_cdr;
    assign buffered_signals[12] = clk_async;
    assign buffered_signals[13] = 0;
    assign buffered_signals[14] = 0;
    assign buffered_signals[15] = 0;

    //ADC Output Retimer

    ti_adc_retimer retimer_i (
        .clk_retimer(clk_adc),   // clock for serial to parallel retiming

        .in_data(adcout),   // serial data
        .in_sign(adcout_sign),                     // sign of serial data
        .in_data_rep(adcout_rep),
        .in_sign_rep(adcout_sign_rep),

        .out_data(adcout_retimed), // parallel data
        .out_sign(adcout_sign_retimed),
        .out_data_rep(adcout_retimed_rep), // parallel data
        .out_sign_rep(adcout_sign_retimed_rep) 
    );


    //PFD Offset Calibration

    //This generates a JTAG controled clock divider - divisble by 1 to 2^5 
    freq_divider #(.N(4)) average_clk_gen (.cki (clk_adc), .cko (clk_avg), .ndiv(ddbg_intf_i.Ndiv_clk_avg), .rstb(rstb));
    freq_divider #(.N(3)) cdr_inpt_clk_gen (.cki (clk_adc), .cko (clk_cdr_in), .ndiv(ddbg_intf_i.Ndiv_clk_cdr), .rstb(rstb));

    genvar k;

    generate
        for (k=0;k<Nti;k=k+1) begin : unfold_and_calibrate_PFD_by_slice
            adc_unfolding PFD_CALIB (
                //Inputs
                .clk_retimer(clk_adc),
                .rstb(rstb),
                .clk_avg(clk_avg),
                .din(adcout_retimed[k]),
                .sign_out(adcout_sign_retimed[k]),
                //Outputs
                .dout(adcout_unfolded[k]),
                //All of the following are JTAG related signals
                .en_pfd_cal(ddbg_intf_i.en_pfd_cal),
                .en_ext_pfd_offset(ddbg_intf_i.en_ext_pfd_offset),
                .ext_pfd_offset(ddbg_intf_i.ext_pfd_offset[k]),
                .Nbin(ddbg_intf_i.Nbin_adc),
                .Navg(ddbg_intf_i.Navg_adc),
                .DZ(ddbg_intf_i.DZ_hist_adc),
                .dout_avg(ddbg_intf_i.adcout_avg[k]),
                .dout_sum(ddbg_intf_i.adcout_sum[k]),
                .hist_center(ddbg_intf_i.adcout_hist_center[k]),
                .hist_side(ddbg_intf_i.adcout_hist_side[k]),
                .pfd_offset(ddbg_intf_i.pfd_offset[k])
            );
        end

        for (k=0;k<2;k=k+1) begin : replica_unfold_and_calib
            adc_unfolding PFD_CALIB_REP (
                //Inputs
                .clk_retimer(clk_adc),
                .rstb(rstb),
                .clk_avg(clk_avg),
                .din(adcout_retimed_rep[k]),
                .sign_out(adcout_sign_retimed_rep[k]),
                //Outputs
                .dout(adcout_unfolded[k+Nti]),
                //All of the following are JTAG related signals
                .en_pfd_cal(ddbg_intf_i.en_pfd_cal_rep),
                .en_ext_pfd_offset(ddbg_intf_i.en_ext_pfd_offset_rep),
                .ext_pfd_offset(ddbg_intf_i.ext_pfd_offset_rep[k]),
                .Nbin(ddbg_intf_i.Nbin_adc_rep),
                .Navg(ddbg_intf_i.Navg_adc_rep),
                .DZ(ddbg_intf_i.DZ_hist_adc_rep),
                .dout_avg(ddbg_intf_i.adcout_avg_rep[k]),
                .dout_sum(ddbg_intf_i.adcout_sum_rep[k]),
                .hist_center(ddbg_intf_i.adcout_hist_center_rep[k]),
                .hist_side(ddbg_intf_i.adcout_hist_side_rep[k]),
                .pfd_offset(ddbg_intf_i.pfd_offset_rep[k])
            );
        end
    endgenerate


    // CDR

    mm_cdr iMM_CDR (
        .din(adcout_unfolded[Nti-1:0]),
        .clk(clk_adc),
        .ext_rstb(cdr_rstb),
        .pi_ctl(pi_ctl_cdr),
        .cdbg_intf_i(cdbg_intf_i)
    );
    genvar j;
    generate
        for (j=0; j<Nout; j=j+1) begin
            assign scale_value[j]        = (ddbg_intf_i.en_ext_max_sel_mux ? ddbg_intf_i.ext_max_sel_mux[j] : adbg_intf_i.max_sel_mux[j])<<4;
            assign unscaled_pi_ctl[j]    = pi_ctl_cdr[j] + ddbg_intf_i.ext_pi_ctl_offset[j];
            assign scaled_pi_ctl[j]      = unscaled_pi_ctl[j]*scale_value[j];
            assign int_pi_ctl_cdr[j]     = scaled_pi_ctl[j] >> Npi;
        end
    endgenerate

    assign dsp_debug_intf.disable_product = ddbg_intf_i.disable_product;
    assign dsp_debug_intf.ffe_shift       = ddbg_intf_i.ffe_shift;
    assign dsp_debug_intf.mlsd_shift      = ddbg_intf_i.mlsd_shift;
    assign dsp_debug_intf.thresh          = ddbg_intf_i.cmp_thresh;

    weight_manager #(.width(Nti), .depth(10), .bitwidth(10)) wme_ffe_i (
        .data    (wdbg_intf_i.wme_ffe_data),
        .inst    (wdbg_intf_i.wme_ffe_inst),
        .exec    (wdbg_intf_i.wme_ffe_exec),
        .clk     (clk_adc),
        .rstb    (rstb),
        .read_reg(wdbg_intf_i.wme_ffe_read),
        .weights (dsp_dbg_intf_i.weights)
    );

    weight_manager #(.width(Nti), .depth(30), .bitwidth(8)) wme_channel_est_i (
        .data    (wdbg_intf_i.wme_mlsd_data),
        .inst    (wdbg_intf_i.wme_mlsd_inst),
        .exec    (wdbg_intf_i.wme_mlsd_exec),
        .clk     (clk_adc),
        .rstb    (rstb),
        .read_reg(wdbg_intf_i.wme_mlsd_read),
        .weights (dsp_dbg_intf_i.channel_est)
    );

    dsp_backend dsp_i(
        .codes(adcout_unfolded[Nti-1:0]),
        .clk(clk_adc),
        .rstb(rstb),
        .estimated_bits(estimated_bits),
        .checked_bits(checked_bits),
        .dsp_dbg_intf_i(dsp_dbg_intf_i)
    );

    // SRAM

    oneshot_multimemory #(
        .N_mem_tiles(4)
    ) oneshot_multimemory_i(
        .clk(clk_adc),
        .rstb(sram_rstb),
        
        .in_bytes(adcout_unfolded),

        .in_start_write(ext_dump_start),

        .in_addr(sm_dbg_intf_i.in_addr),

        .out_data(sm_dbg_intf_i.out_data),
        .addr(sm_dbg_intf_i.addr)
    );

    // PRBS
    // TODO: refine data decision from ADC (custom threshold, gain, invert option, etc.)
    // TODO: mux PRBS input between ADC, FFE, and MLSD
    logic [(Nti-1):0] prbs_rx_bits;
    generate
        for (k=0; k<Nti; k=k+1) begin
            assign prbs_rx_bits[k] = ~adcout_unfolded[k][Nadc-1];
        end
    endgenerate

    prbs_checker #(
        .n_prbs(Nprbs),
        .n_channels(Nti)
    ) prbs_checker_i (
        // clock and reset
        .clk(clk_adc),
        .rst(~prbs_rstb),
        // inputs
        .prbs_init_vals(pdbg_intf_i.prbs_init_vals),
        .rx_bits(prbs_rx_bits),
        .checker_mode(pdbg_intf_i.prbs_checker_mode),
        // outputs
        .correct_bits({pdbg_intf_i.prbs_correct_bits_upper, pdbg_intf_i.prbs_correct_bits_lower}),
        .total_bits({pdbg_intf_i.prbs_total_bits_upper, pdbg_intf_i.prbs_total_bits_lower}),
        .rx_shift(pdbg_intf_i.prbs_rx_shift)
    );

    output_buffer out_buff_i (
            .bufferend_signals(buffered_signals),
            .sel_outbuff(ddbg_intf_i.sel_outbuff),
            .sel_trigbuff(ddbg_intf_i.sel_trigbuff),
            .en_outbuff(ddbg_intf_i.en_outbuff),
            .en_trigbuff(ddbg_intf_i.en_trigbuff),
            .Ndiv_outbuff(ddbg_intf_i.Ndiv_outbuff),
            .Ndiv_trigbuff(ddbg_intf_i.Ndiv_trigbuff),
            .bypass_out_div(ddbg_intf_i.bypass_out),
            .bypass_trig_div(ddbg_intf_i.bypass_trig),

            .clock_out_p(clock_out_p),
            .clock_out_n(clock_out_n),
            .trigg_out_p(trigg_out_p),
            .trigg_out_n(trigg_out_n)
    );
    // JTAG

    jtag jtag_i (
        .clk(clk_adc),
        .rstb(ext_rstb),
        .ddbg_intf_i(ddbg_intf_i),
        .adbg_intf_i(adbg_intf_i),
        .cdbg_intf_i(cdbg_intf_i),
        .sdbg_intf_i(sm_dbg_intf_i),
        .pdbg_intf_i(pdbg_intf_i),
        .jtag_intf_i(jtag_intf_i)
    );

endmodule

`default_nettype wire
