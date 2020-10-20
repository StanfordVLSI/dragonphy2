`default_nettype none

module digital_core import const_pack::*; (
    input wire logic clk_adc,                           
    input wire logic [Nadc-1:0] adcout [Nti-1:0],
    input wire logic [Nti-1:0]  adcout_sign ,
    input wire logic [Nadc-1:0] adcout_rep [Nti_rep-1:0],
    input wire logic [Nti_rep-1:0] adcout_sign_rep,
    input wire logic ext_rstb,
    input wire logic clk_async,
    input wire logic ramp_clock,
    input wire logic mdll_clk,
    input wire logic mdll_jm_clk,
	
    output wire logic disable_ibuf_async,
	output wire logic disable_ibuf_main,   
    output wire logic disable_ibuf_mdll_ref, 
	output wire logic disable_ibuf_mdll_mon, 
    output wire logic  [Npi-1:0] int_pi_ctl_cdr [Nout-1:0],
    output wire logic clock_out_p,
    output wire logic clock_out_n,
    output wire logic trigg_out_p,
    output wire logic trigg_out_n,
    output wire logic ctl_valid,
    output wire logic freq_lvl_cross,
    input wire logic ext_dump_start,

    input wire logic clk_tx,
    output wire logic tx_rst,
    output wire logic [(Nti-1):0] tx_data,
    output wire logic [(Npi-1):0] tx_pi_ctl [(Nout-1):0],
    output wire logic tx_ctl_valid,

    acore_debug_intf.dcore adbg_intf_i,
    jtag_intf.target jtag_intf_i,
    mdll_r1_debug_intf.jtag mdbg_intf_i,
    tx_debug_intf.dcore tdbg_intf_i,

    output wire logic clk_cgra
);
    // interfaces

    cdr_debug_intf cdbg_intf_i ();
    sram_debug_intf #(.N_mem_tiles(4)) sm1_dbg_intf_i ();
    sram_debug_intf #(.N_mem_tiles(4)) sm2_dbg_intf_i ();

    dcore_debug_intf ddbg_intf_i ();
    dsp_debug_intf dsp_dbg_intf_i();
    prbs_debug_intf pdbg_intf_i ();
    wme_debug_intf wdbg_intf_i ();
    hist_debug_intf hdbg_intf_i ();
    tx_data_intf odbg_intf_i ();
    
    // internal signals

    wire logic rstb;
    wire logic adc_unfolding_update;
    wire logic [Nadc-1:0] adcout_retimed [Nti-1:0];
    wire logic [Nti-1:0] adcout_sign_retimed;
    wire logic [Nadc-1:0] adcout_retimed_rep [Nti_rep-1:0];
    wire logic [Nti_rep-1:0] adcout_sign_retimed_rep;
    wire logic [Npi-1:0] pi_ctl_cdr[Nout-1:0];
    wire logic sram_rstb;
    wire logic cdr_rstb;
    wire logic prbs_rstb;
    wire logic prbs_gen_rstb;
    wire logic tx_data_rstb;
    wire logic signed [Nadc-1:0] adcout_unfolded [Nti+Nti_rep-1:0];

    wire logic signed [ffe_gpack::output_precision-1:0] estimated_bits [constant_gpack::channel_width-1:0];
    wire logic signed [7:0] trunc_est_bits [Nti+Nti_rep-1:0];

    //Sample the FFE output
    genvar gi, gj;
    generate
        for(gi=0; gi<constant_gpack::channel_width; gi = gi + 1 ) begin
            assign trunc_est_bits[gi] = estimated_bits[gi][9:2];
        end
    endgenerate

    wire logic checked_bits [constant_gpack::channel_width-1:0];
    //Sample the MLSD output
    generate
        for(gi=0; gi<8; gi = gi + 1) begin
            for(gj=0; gj<2; gj = gj + 1 ) begin
                assign trunc_est_bits[16+gj][gi] = checked_bits[gi + gj*8];
            end
        end
    endgenerate

    wire logic [Npi-1:0] scale_value [Nout-1:0];
    wire logic [Npi-1:0] unscaled_pi_ctl [Nout-1:0];
    wire logic [Npi+Npi-1:0] scaled_pi_ctl [Nout-1:0];

    wire logic [(Npi-1):0] tx_scale_value [(Nout-1):0];
    wire logic [(Npi+Npi-1):0] tx_scaled_pi_ctl [(Nout-1):0];

//    initial begin
//        $shm_open("waves.shm");
//        $shm_probe("ACT"); 
//        $shm_probe(pi_ctl_cdr);
//        $shm_probe(ddbg_intf_i.disable_product);
//        $shm_probe(dsp_i.disable_product);
//    end

    // derived reset signals
    // these combine external reset with JTAG reset

    assign rstb             = ddbg_intf_i.int_rstb  && ext_rstb;
    assign sram_rstb        = ddbg_intf_i.sram_rstb && ext_rstb;
    assign cdr_rstb         = ddbg_intf_i.cdr_rstb  && ext_rstb;
    assign prbs_rstb        = ddbg_intf_i.prbs_rstb && ext_rstb;
    assign prbs_gen_rstb    = ddbg_intf_i.prbs_gen_rstb && ext_rstb;
    assign tx_data_rstb     = ddbg_intf_i.tx_data_rstb && ext_rstb;

    // the dump_start signal can be set internally or externally

    logic dump_start;
    assign dump_start = (ddbg_intf_i.en_int_dump_start ?
                         ddbg_intf_i.int_dump_start :
                         ext_dump_start);

    // ADC Output Reordering
    // used to do retiming as well, but now that is handled in the analog core

    ti_adc_reorder reorder_i (
        // inputs
        .in_data(adcout),
        .in_sign(adcout_sign),
        .in_data_rep(adcout_rep),
        .in_sign_rep(adcout_sign_rep),

        // outputs
        .out_data(adcout_retimed),
        .out_sign(adcout_sign_retimed),
        .out_data_rep(adcout_retimed_rep),
        .out_sign_rep(adcout_sign_retimed_rep) 
    );

    // PFD Offset Calibration

    // The averaging pulse occurs once every 2**Ndiv_clk_avg pulses.  With the
    // default setting of Nrange=4, the averaging period can vary from 1 cycle
    // to 32,768 cycles.  Ndiv_clk_avg defaults to "10", or 1,024 cycles.

    avg_pulse_gen #(
        .N(Nrange)
    ) unfolding_pulse_inst (
        .clk(clk_adc),
        .rstb(rstb),
        .ndiv(ddbg_intf_i.Ndiv_clk_avg),
        .out(adc_unfolding_update)
    );

    genvar k;
    generate
        for (k=0; k<Nti; k=k+1) begin : unfold_and_calibrate_PFD_by_slice
            adc_unfolding #(
                .Nadc(Nadc),
                .Nrange(Nrange)
            ) PFD_CALIB (
                // Inputs
                .clk(clk_adc),
                .rstb(rstb),
                .update(adc_unfolding_update),
                .din(adcout_retimed[k]),
                .sign_out(adcout_sign_retimed[k]),

                // Outputs
                .dout(adcout_unfolded[k]),

                // All of the following are JTAG related signals
                .en_pfd_cal(ddbg_intf_i.en_pfd_cal),
                .en_ext_pfd_offset(ddbg_intf_i.en_ext_pfd_offset),
                .ext_pfd_offset(ddbg_intf_i.ext_pfd_offset[k]),
                .Nbin(ddbg_intf_i.Nbin_adc),
                .Navg(ddbg_intf_i.Navg_adc),
                .DZ(ddbg_intf_i.DZ_hist_adc),
                .flip_feedback(ddbg_intf_i.pfd_cal_flip_feedback),
                .en_ext_ave(ddbg_intf_i.en_pfd_cal_ext_ave),
                .ext_ave(ddbg_intf_i.pfd_cal_ext_ave),
                .dout_avg(ddbg_intf_i.adcout_avg[k]),
                .dout_sum(ddbg_intf_i.adcout_sum[k]),
                .hist_center(ddbg_intf_i.adcout_hist_center[k]),
                .hist_side(ddbg_intf_i.adcout_hist_side[k]),
                .pfd_offset(ddbg_intf_i.pfd_offset[k])
            );
        end

        for (k=0; k<2; k=k+1) begin : replica_unfold_and_calib
            adc_unfolding #(
                .Nadc(Nadc),
                .Nrange(Nrange)
            ) PFD_CALIB_REP (
                // Inputs
                .clk(clk_adc),
                .rstb(rstb),
                .update(adc_unfolding_update),
                .din(adcout_retimed_rep[k]),
                .sign_out(adcout_sign_retimed_rep[k]),

                // Outputs
                .dout(adcout_unfolded[k+Nti]),

                // All of the following are JTAG related signals
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

    // Select ADC signals (Nti-1) down through 0.  For some reason, passing the slice
    // adcout_unfolded[15:0] directly into the comparator or DSP block does not work;
    // some entries are X or high-Z (possible Vivado bug)

    logic signed [(Nadc-1):0] adcout_unfolded_non_rep [(Nti-1):0];

    generate
        for (k=0; k<Nti; k=k+1) begin
            assign adcout_unfolded_non_rep[k] = adcout_unfolded[k];
        end
    endgenerate

    // CDR

    logic signed [Nadc-1:0] mm_cdr_input [Nti-1:0];

    generate
        for(k = 0; k < Nti; k = k + 1) begin
            assign mm_cdr_input[k] = cdbg_intf_i.sel_inp_mux ? estimated_bits[k][ffe_gpack::output_precision-1:(ffe_gpack::output_precision-Nadc)] : adcout_unfolded[k];
        end
    endgenerate


    mm_cdr iMM_CDR (
        .din(mm_cdr_input),
        .clk(clk_adc),
        .ext_rstb(cdr_rstb),
        .ramp_clock(ramp_clock),
        .freq_lvl_cross(freq_lvl_cross),
        .pi_ctl(pi_ctl_cdr),
        .wait_on_reset_b(ctl_valid),
        .cdbg_intf_i(cdbg_intf_i)
    );

    ////////////////////////////
    // Calculate PI CTL codes //
    ////////////////////////////

    // for analog_core

    genvar j;

    generate
        for (j=0; j<Nout; j=j+1) begin
            assign scale_value[j]        = (((ddbg_intf_i.en_ext_max_sel_mux ? ddbg_intf_i.ext_max_sel_mux[j]: adbg_intf_i.max_sel_mux[j]) + 1)<<4) -1;
            assign unscaled_pi_ctl[j]    = pi_ctl_cdr[j] + ddbg_intf_i.ext_pi_ctl_offset[j];
            assign scaled_pi_ctl[j]      = unscaled_pi_ctl[j]*scale_value[j];
            assign int_pi_ctl_cdr[j]     = ddbg_intf_i.en_bypass_pi_ctl[j] ?  ddbg_intf_i.bypass_pi_ctl[j] : (scaled_pi_ctl[j] >> Npi);
        end
    endgenerate

    // for tx_top

    generate
        for (j=0; j<Nout; j=j+1) begin
            assign tx_scale_value[j] = (((ddbg_intf_i.tx_en_ext_max_sel_mux ?
                                          ddbg_intf_i.tx_ext_max_sel_mux[j] :
                                          tdbg_intf_i.max_sel_mux[j]) + 1) << 4) - 1;

            assign tx_scaled_pi_ctl[j] = ddbg_intf_i.tx_pi_ctl[j]*tx_scale_value[j];

            assign tx_pi_ctl[j] = (ddbg_intf_i.tx_en_bypass_pi_ctl[j] ?
                                   ddbg_intf_i.tx_bypass_pi_ctl[j] :
                                   (tx_scaled_pi_ctl[j] >> Npi));
        end
    endgenerate

    assign dsp_dbg_intf_i.disable_product = ddbg_intf_i.disable_product;
    assign dsp_dbg_intf_i.ffe_shift       = ddbg_intf_i.ffe_shift;
    assign dsp_dbg_intf_i.mlsd_shift      = ddbg_intf_i.mlsd_shift;
    assign dsp_dbg_intf_i.thresh          = ddbg_intf_i.cmp_thresh;

    weight_manager #(
        .width(Nti),
        .depth(ffe_gpack::length),
        .bitwidth(ffe_gpack::weight_precision)
    ) wme_ffe_i (
        .data(wdbg_intf_i.wme_ffe_data),
        .inst(wdbg_intf_i.wme_ffe_inst),
        .exec(wdbg_intf_i.wme_ffe_exec),
        .clk(clk_adc),
        .rstb(rstb),
        .read_reg(wdbg_intf_i.wme_ffe_read),
        .weights (dsp_dbg_intf_i.weights)
    );

    weight_manager #(
        .width(Nti),
        .depth(mlsd_gpack::estimate_depth),
        .bitwidth(mlsd_gpack::estimate_precision)
    ) wme_channel_est_i (
        .data(wdbg_intf_i.wme_mlsd_data),
        .inst(wdbg_intf_i.wme_mlsd_inst),
        .exec(wdbg_intf_i.wme_mlsd_exec),
        .clk(clk_adc),
        .rstb(rstb),
        .read_reg(wdbg_intf_i.wme_mlsd_read),
        .weights (dsp_dbg_intf_i.channel_est)
    );

    dsp_backend dsp_i(
        .codes(adcout_unfolded_non_rep),
        .clk(clk_adc),
        .rstb(rstb),
        .estimated_bits_q(estimated_bits),
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

        .in_start_write(dump_start),

        .in_addr(sm1_dbg_intf_i.in_addr),

        .out_data(sm1_dbg_intf_i.out_data),
        .addr(sm1_dbg_intf_i.addr)
    );

    oneshot_multimemory #(
        .N_mem_tiles(4)
    ) omm_ffe_i(
        .clk(clk_adc),
        .rstb(sram_rstb),
        
        .in_bytes(trunc_est_bits),

        .in_start_write(dump_start),

        .in_addr(sm2_dbg_intf_i.in_addr),

        .out_data(sm2_dbg_intf_i.out_data),
        .addr(sm2_dbg_intf_i.addr)
    );

    // PRBS
    // TODO: refine data decision from ADC (custom threshold, gain, invert option, etc.)
    // TODO: mux PRBS input between ADC, FFE, and MLSD

    logic [Nti-1:0]   mux_prbs_rx_bits [3:0];
    logic [(Nti-1):0] prbs_rx_bits;

    logic bits_adc [Nti-1:0];
    logic bits_ffe [Nti-1:0];

    comb_comp #(.numChannels(16), .inputBitwidth(Nadc), .thresholdBitwidth(Nadc)) dig_comp_adc_i (
        .codes     (adcout_unfolded_non_rep),
        .thresh    (ddbg_intf_i.adc_thresh),
        .clk       (clk_adc),
        .rstb      (rstb),
        .bit_out   (bits_adc)
    );

    comb_comp #(.numChannels(16), .inputBitwidth(ffe_gpack::output_precision), .thresholdBitwidth(ffe_gpack::output_precision)) dig_comp_ffe_i (
        .codes     (estimated_bits),
        .thresh    (ddbg_intf_i.ffe_thresh),
        .clk       (clk_adc),
        .rstb      (rstb),
        .bit_out   (bits_ffe)
    );


    logic [Nti-1:0] bits_adc_r;
    logic [Nti-1:0] bits_ffe_r;
    logic [Nti-1:0] bits_mlsd_r;
    logic bit_bist_r;

    assign mux_prbs_rx_bits[0] = bits_adc_r;
    assign mux_prbs_rx_bits[1] = bits_ffe_r;
    assign mux_prbs_rx_bits[2] = bits_mlsd_r;
    assign mux_prbs_rx_bits[3] = {Nti{bit_bist_r}};

    generate
        for (k=0; k<Nti; k=k+1) begin
            assign bits_adc_r[k] = bits_adc[k];
            assign bits_ffe_r[k] = bits_ffe[k];
            assign bits_mlsd_r[k] = checked_bits[k];
        end
    endgenerate

    assign prbs_rx_bits = mux_prbs_rx_bits[ddbg_intf_i.sel_prbs_mux];

    // PRBS generator for BIST

    prbs_generator_syn #(
        .n_prbs(Nprbs)
    ) prbs_generator_syn_i (
        // clock and reset
        .clk(clk_adc),
        .rst(~prbs_gen_rstb),
        // clock gating
        .cke(pdbg_intf_i.prbs_gen_cke),
        // define the PRBS initialization
        .init_val(pdbg_intf_i.prbs_gen_init),
        // define the PRBS equation
        .eqn(pdbg_intf_i.prbs_gen_eqn),
        // signal for injecting errors
        .inj_err(pdbg_intf_i.prbs_gen_inj_err),
        // "chicken" bits for flipping the sign of various bits
        .inv_chicken(pdbg_intf_i.prbs_gen_chicken),
        // output bit
        .out(bit_bist_r)
    );

    // PRBS checker

    logic [63:0] prbs_err_bits;
    assign pdbg_intf_i.prbs_err_bits_upper = prbs_err_bits[63:32];
    assign pdbg_intf_i.prbs_err_bits_lower = prbs_err_bits[31:0];

    logic [63:0] prbs_total_bits;
    assign pdbg_intf_i.prbs_total_bits_upper = prbs_total_bits[63:32];
    assign pdbg_intf_i.prbs_total_bits_lower = prbs_total_bits[31:0];

    prbs_checker #(
        .n_prbs(Nprbs),
        .n_channels(Nti)
    ) prbs_checker_i (
        // clock and reset
        .clk(clk_adc),
        .rst(~prbs_rstb),
        // clock gating
        .cke(pdbg_intf_i.prbs_cke),
        // define the PRBS equation
        .eqn(pdbg_intf_i.prbs_eqn),
        // bits for selecting / de-selecting certain channels from the PRBS test
        .chan_sel(pdbg_intf_i.prbs_chan_sel),
        // "chicken" bits for flipping the sign of various bits
        .inv_chicken(pdbg_intf_i.prbs_inv_chicken),
        // recovered data from ADC, FFE, MLSD, etc.
        .rx_bits(prbs_rx_bits),
        // checker mode
        .checker_mode(pdbg_intf_i.prbs_checker_mode),
        // outputs
        .err_bits(prbs_err_bits),
        .total_bits(prbs_total_bits)
    );

    // Histogram data generator for BIST

    logic [(Nadc-1):0] data_gen_out;

    histogram_data_gen #(
        .n(Nadc)
    ) data_gen_inst (
        .clk(clk_adc),
        .mode(hdbg_intf_i.data_gen_mode),
        .in0(hdbg_intf_i.data_gen_in_0),
        .in1(hdbg_intf_i.data_gen_in_1),
        .out(data_gen_out)
    );

    // Histogram
    // TODO: is there an MLSD output that should be included?

    logic [(Nadc-1):0] hist_data_in;

    logic [63:0] hist_count;
    assign hdbg_intf_i.hist_count_upper = hist_count[63:32];
    assign hdbg_intf_i.hist_count_lower = hist_count[31:0];

    logic [63:0] hist_total;
    assign hdbg_intf_i.hist_total_upper = hist_total[63:32];
    assign hdbg_intf_i.hist_total_lower = hist_total[31:0];

    histogram_mux #(
        .Nti(Nti),
        .Nti_rep(Nti_rep),
        .Nadc(Nadc)
    ) hist_mux_inst (
        .clk(clk_adc),
        .source(hdbg_intf_i.hist_source),
        .index(hdbg_intf_i.hist_src_idx),
        .adc_data(adcout_unfolded),
        .ffe_data(trunc_est_bits),
        .bist_data(data_gen_out),
        .out(hist_data_in)
    );

    histogram #(
        .n_data(Nadc),
        .n_count(64)
    ) histogram_inst (
        .clk(clk_adc),
        .sram_ceb(hdbg_intf_i.hist_sram_ceb),
        .mode(hdbg_intf_i.hist_mode),
        .data(hist_data_in),
        .addr(hdbg_intf_i.hist_addr),
        .count(hist_count),
        .total(hist_total)
    );

    // Output buffer

    // wire out PI measurement signals separately 
    // this is a work-around for a low-level Vivado bug
    // in which the tool seg-faults inexplicably when the
    // pi_out_meas signals are directly assigned into 
    // buffered_signals.
    logic pi_out_meas_0, pi_out_meas_1, pi_out_meas_2, pi_out_meas_3;
    assign pi_out_meas_0 = adbg_intf_i.pi_out_meas[0];
    assign pi_out_meas_1 = adbg_intf_i.pi_out_meas[1];
    assign pi_out_meas_2 = adbg_intf_i.pi_out_meas[2];
    assign pi_out_meas_3 = adbg_intf_i.pi_out_meas[3];

    // mapping for signals that can be selected
    // through the output buffer
    logic [15:0] buffered_signals;
    assign buffered_signals[0]  = clk_adc;
    assign buffered_signals[1]  = adbg_intf_i.del_out_pi;
    assign buffered_signals[2]  = pi_out_meas_0;
    assign buffered_signals[3]  = pi_out_meas_1;
    assign buffered_signals[4]  = pi_out_meas_2;
    assign buffered_signals[5]  = pi_out_meas_3;
    assign buffered_signals[6]  = adbg_intf_i.del_out_rep[0];
    assign buffered_signals[7]  = adbg_intf_i.del_out_rep[1];
    assign buffered_signals[8]  = adbg_intf_i.inbuf_out_meas;
    assign buffered_signals[9]  = 0;
    assign buffered_signals[10] = 0;
    assign buffered_signals[11] = ctl_valid;
    assign buffered_signals[12] = clk_async;
    assign buffered_signals[13] = mdll_clk;
    assign buffered_signals[14] = mdll_jm_clk;
    assign buffered_signals[15] = 0;

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
        .disable_ibuf_async(disable_ibuf_async),
	    .disable_ibuf_main(disable_ibuf_main),
        .disable_ibuf_mdll_ref(disable_ibuf_mdll_ref),
	    .disable_ibuf_mdll_mon(disable_ibuf_mdll_mon),
        .ddbg_intf_i(ddbg_intf_i),
        .adbg_intf_i(adbg_intf_i),
        .cdbg_intf_i(cdbg_intf_i),
        .sdbg1_intf_i(sm1_dbg_intf_i),
        .sdbg2_intf_i(sm2_dbg_intf_i),
        .pdbg_intf_i(pdbg_intf_i),
        .wdbg_intf_i(wdbg_intf_i),
        .mdbg_intf_i(mdbg_intf_i),
        .hdbg_intf_i(hdbg_intf_i),
        .tdbg_intf_i(tdbg_intf_i),
        .odbg_intf_i(odbg_intf_i),
        .jtag_intf_i(jtag_intf_i)
    );

    // clock going out to CGRA
    // ref: https://stackoverflow.com/questions/24977925/how-to-use-clock-gating-in-rtl

    logic en_cgra_clk_latch;

    always_latch begin
        if (~clk_adc) begin
            en_cgra_clk_latch <= ddbg_intf_i.en_cgra_clk;
        end
    end

    assign clk_cgra = (clk_adc & en_cgra_clk_latch);

    // transmitter control signals

    assign tx_rst = ddbg_intf_i.tx_rst;
    assign tx_ctl_valid = ddbg_intf_i.tx_ctl_valid;

    // TX data generator

    tx_data_gen #(
        .Nprbs(Nprbs),
        .Nti(Nti)
    ) tx_data_gen_i (
        .clk(clk_tx),
        .rstb(tx_data_rstb),
        .cke(odbg_intf_i.tx_data_gen_cke),
        .semaphore(odbg_intf_i.tx_data_gen_semaphore),

        .data_mode(odbg_intf_i.tx_data_gen_mode),
        .data_per(odbg_intf_i.tx_data_gen_per),
        .data_in(odbg_intf_i.tx_data_gen_register),

        .prbs_init(odbg_intf_i.tx_prbs_gen_init),
        .prbs_eqn(odbg_intf_i.tx_prbs_gen_eqn),
        .prbs_inj_err(odbg_intf_i.tx_prbs_gen_inj_err),
        .prbs_chicken(odbg_intf_i.tx_prbs_gen_chicken),

        .data_out(tx_data)
    );

endmodule

`default_nettype wire
