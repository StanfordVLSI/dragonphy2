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
    output logic  [Npi-1:0] int_pi_ctl_cdr [Nout-1:0],
    output wire logic clock_out_p,
    output wire logic clock_out_n,
    output wire logic trigg_out_p,
    output wire logic trigg_out_n,
    output wire logic ctl_valid,
    output wire logic freq_lvl_cross,
    input wire logic ext_dump_start,

    input wire logic clk_tx,
    //output wire logic tx_rst,
    //output wire logic [(Nti-1):0] tx_data,
    //output wire logic [(Npi-1):0] tx_pi_ctl [(Nout-1):0],
    //output wire logic tx_ctl_valid,

    acore_debug_intf.dcore adbg_intf_i,
    jtag_intf.target jtag_intf_i,
    mdll_r1_debug_intf.jtag mdbg_intf_i,
    //tx_debug_intf.dcore tdbg_intf_i,

    output wire logic clk_cgra
);
    // interfaces

    cdr_debug_intf cdbg_intf_i ();
    sram_debug_intf #(.N_mem_tiles(2)) sm1_dbg_intf_i ();

    dcore_debug_intf ddbg_intf_i ();
    dsp_debug_intf dsp_dbg_intf_i();
    prbs_debug_intf pdbg_intf_i ();
    hist_debug_intf hdbg_intf_i ();
    error_tracker_debug_intf #(.addrwidth(10)) edbg_intf_i  ();
    //tx_data_intf odbg_intf_i ();


    // internal signals
    wire logic dcore_rstb;
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
    wire logic signed [Nadc-1:0] adcout_unfolded [Nti+Nti_rep-1:0];
    wire logic [constant_gpack::sym_bitwidth*Nti-1:0] prbs_flags;
    wire logic [constant_gpack::sym_bitwidth*Nti-1:0] prbs_flags_trigger;

    logic signed [ffe_gpack::output_precision-1:0] slice_levels [2:0];
    logic force_slicers;

    logic [constant_gpack::sym_bitwidth-1:0] decoded_raw_symbols [Nti-1:0];
    logic [constant_gpack::sym_bitwidth-1:0] decoded_symbols [Nti-1:0];
    logic [constant_gpack::sym_bitwidth-1:0] decoded_corrected_symbols [constant_gpack::channel_width-1:0];

    wire logic signed [(2**constant_gpack::sym_bitwidth-1)-1:0] encoded_raw_symbols [Nti-1:0];
    wire logic signed [(2**constant_gpack::sym_bitwidth-1)-1:0] encoded_symbols [Nti-1:0];
    wire logic signed [(2**constant_gpack::sym_bitwidth-1)-1:0] encoded_corrected_symbols [constant_gpack::channel_width-1:0];

    wire logic signed [error_gpack::est_error_precision-1:0] est_errors [Nti-1:0];
    wire logic        [$clog2(2*detector_gpack::num_of_trellis_patterns+1)-1:0] sd_flags [Nti-1:0];

    wire logic signed [ffe_gpack::output_precision-1:0] estimated_bits [constant_gpack::channel_width-1:0];

    wire logic signed [ffe_gpack::weight_precision-1:0] single_weights   [ffe_gpack::length-1:0];


    wire logic signed [7:0] trunc_est_bits [Nti-1:0];
    wire logic signed [7:0] trunc_est_bits_ext [Nti+Nti_rep-1:0];

    logic signed [constant_gpack::code_precision-1:0] act_codes [constant_gpack::channel_width-1:0];
    logic signed [(2**constant_gpack::sym_bitwidth-1)-1:0] tmp_sliced_est_bits [constant_gpack::channel_width-1:0];
    logic sliced_est_bits [constant_gpack::channel_width-1:0];


    //Sample the FFE output
    genvar gi, gj;
    generate
        for(gi=0; gi<constant_gpack::channel_width; gi = gi + 1 ) begin
            assign trunc_est_bits[gi] = estimated_bits[gi][9:2];
            assign trunc_est_bits_ext[gi] = estimated_bits[gi][9:2];

            always_comb begin
                unique case (encoded_raw_symbols[gi])
                    3: begin
                        decoded_raw_symbols[gi] = 2'b10;
                    end
                    1: begin
                        decoded_raw_symbols[gi] = 2'b11;
                    end
                    -1: begin
                        decoded_raw_symbols[gi] = 2'b01;
                    end
                    -3: begin
                        decoded_raw_symbols[gi] = 2'b00;
                    end
                endcase

                unique case (encoded_symbols[gi])
                    3: begin 
                        decoded_symbols[gi] = 2'b10;
                    end
                    1: begin 
                        decoded_symbols[gi] = 2'b11;
                    end
                    -1: begin 
                        decoded_symbols[gi] = 2'b01;
                    end
                    -3: begin 
                        decoded_symbols[gi] = 2'b00;
                    end
                endcase

                unique case(encoded_corrected_symbols[gi])
                    3: begin 
                        decoded_corrected_symbols[gi] = 2'b10;
                    end
                    1: begin 
                        decoded_corrected_symbols[gi] = 2'b11;
                    end
                    -1: begin 
                        decoded_corrected_symbols[gi] = 2'b01;
                    end
                    -3: begin 
                        decoded_corrected_symbols[gi] = 2'b00;
                    end
                endcase
            end

        end
    endgenerate

    assign trunc_est_bits_ext[Nti] =0;
    assign trunc_est_bits_ext[Nti+1] =0 ;
 //Sample the MLSD output

    wire logic [Npi-1:0] scale_value [Nout-1:0];


    //wire logic [(Npi-1):0] tx_scale_value [(Nout-1):0];
    //logic [(Npi-1):0] reg_tx_scale_value [(Nout-1):0];
    //wire logic [(Npi+Npi-1):0] tx_scaled_pi_ctl [(Nout-1):0];
    initial begin
        $dumpvars;
    end
//    initial begin
//        $shm_open("waves.shm");
//        $shm_probe("ACT"); 
//        $shm_probe(pi_ctl_cdr);
//        $shm_probe(ddbg_intf_i.disable_product);
//        $shm_probe(dsp_i.disable_product);
//    end

    // derived reset signals
    // these combine external reset with JTAG reset




    assign dcore_rstb       = ddbg_intf_i.int_rstb     ;
    assign sram_rstb        = ddbg_intf_i.sram_rstb    ;
    assign cdr_rstb         = ddbg_intf_i.cdr_rstb     ;
    assign prbs_rstb        = ddbg_intf_i.prbs_rstb    ;
    assign prbs_gen_rstb    = ddbg_intf_i.prbs_gen_rstb;

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
        .rstb(dcore_rstb),
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
                .rstb(dcore_rstb),
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
                .rstb(dcore_rstb),
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
            assign mm_cdr_input[k] = cdbg_intf_i.sel_inp_mux ? estimated_bits[k] : act_codes[k];
        end
    endgenerate


    //Move reset logic out of loop of CDR :)
    logic [4:0] wait_on_reset_ii;
    logic ctl_valid_reg;
    assign ctl_valid = ctl_valid_reg;
    //Wait 32 cycles on each reset
    always_ff @(posedge clk_adc or negedge cdr_rstb) begin
        if(~cdr_rstb) begin
            ctl_valid_reg <= 0;
            wait_on_reset_ii <= 0;
        end else begin
            wait_on_reset_ii <=  (wait_on_reset_ii == 5'b11111) ? wait_on_reset_ii : wait_on_reset_ii + 1;
            ctl_valid_reg        <=   (wait_on_reset_ii == 5'b11111) ? 1 : 0;
        end
    end

    mm_cdr iMM_CDR (
        .codes(trunc_est_bits),
        .bits(sliced_est_bits),
        .clk(clk_adc),
        .ext_rstb(ctl_valid),
        .ramp_clock(ramp_clock),
        .freq_lvl_cross(freq_lvl_cross),
        .pi_ctl(pi_ctl_cdr),
        .cdbg_intf_i(cdbg_intf_i)
    );

    ////////////////////////////
    // Calculate PI CTL codes //
    ////////////////////////////

    // for analog_core

    genvar j;

    generate
        for (j=0; j<Nout; j=j+1) begin
            assign scale_value[j]        = ddbg_intf_i.en_ext_max_sel_mux ? ddbg_intf_i.ext_max_sel_mux[j] : ((((adbg_intf_i.max_sel_mux[j]) + 1)<<4) -1);

            always_comb begin
                int_pi_ctl_cdr[j] =  (pi_ctl_cdr[j] % scale_value[j]) + ddbg_intf_i.ext_pi_ctl_offset[j];
            end
        end
    endgenerate


    logic [Npi-1:0] pi_ctl_0;
    logic [Npi-1:0] pi_ctl_1;
    logic [Npi-1:0] pi_ctl_2;
    logic [Npi-1:0] pi_ctl_3;

    assign pi_ctl_0 = int_pi_ctl_cdr[0];
    assign pi_ctl_1 = int_pi_ctl_cdr[1];
    assign pi_ctl_2 = int_pi_ctl_cdr[2];
    assign pi_ctl_3 = int_pi_ctl_cdr[3];

    trellis_pattern_manager tpm_i (
        .clk(clk_adc),
        .rstb(dcore_rstb),
        .new_trellis_pattern     (ddbg_intf_i.new_trellis_pattern),
        .new_trellis_pattern_idx (ddbg_intf_i.new_trellis_pattern_idx),
        .update_trellis_pattern  (ddbg_intf_i.update_trellis_pattern),
        .trellis_patterns        (dsp_dbg_intf_i.trellis_patterns)
    );

    assign dsp_dbg_intf_i.ffe_shift       = ddbg_intf_i.ffe_shift;
    assign dsp_dbg_intf_i.slice_levels    = slice_levels;
    assign dsp_dbg_intf_i.channel_shift   = ddbg_intf_i.channel_shift;
    assign dsp_dbg_intf_i.align_pos       = ddbg_intf_i.align_pos;


    logic signed [8:0] stage2_est_errors [15:0];
    logic signed [8:0] stage2_est_errors_buffer [15:0][2:0];
    logic signed [8:0] flat_stage2_est_errors [31:0];
    logic signed [(2**constant_gpack::sym_bitwidth-1)-1:0]   stage2_slcd_bits [15:0];
    logic signed [(2**constant_gpack::sym_bitwidth-1)-1:0]   stage2_slcd_bits_buffer [15:0][2:0];

    logic signed [channel_gpack::est_channel_precision-1:0] single_chan_est [channel_gpack::est_channel_depth-1:0];


    datapath_core datapath_i (
        .adc_codes(adcout_unfolded_non_rep),
        .clk(clk_adc),
        .rstb(dcore_rstb),

        //Stage 1
        .stage1_est_bits_out(estimated_bits),
        .stage1_symbols_out(tmp_sliced_est_bits),
        .stage1_act_codes_out(act_codes),

        //Stage 2
        .stage2_res_errors_out  (stage2_est_errors),
        .stage2_symbols_out (stage2_slcd_bits),

        // Stage 3
        .stage3_sd_flags_ener   (),
        .stage3_sd_flags        (),

        // Stage 4
        .stage4_symbols_out (encoded_corrected_symbols),
        .stage4_res_errors_out  (),

        //Aligned to Stage 4:
        .stage4_aligned_stage2_res_errors_out(est_errors),
        .stage4_aligned_stage2_symbols_out(encoded_symbols),
        .stage4_aligned_stage3_sd_flags(sd_flags),

        .dsp_dbg_intf_i(dsp_dbg_intf_i)
    );

    slice_estimator #(
        .num_of_channels(constant_gpack::channel_width),
        .est_bit_bitwidth(ffe_gpack::output_precision),
        .adapt_bitwidth(16)
    ) slice_est_i (
        .clk(clk_adc),
        .rst_n(dcore_rstb),

        .symbols(tmp_sliced_est_bits),
        .est_symbols(estimated_bits),
        .gain(ddbg_intf_i.se_gain),

        .force_slicers(ddbg_intf_i.force_slicers),
        .fe_bit_target_level(ddbg_intf_i.fe_bit_target_level),

        .slice_levels(slice_levels)
    );


    logic signed [9:0] sec_est_bits [ffe_gpack::length-1:0];

    always_comb begin
        for(int ii=0; ii<ffe_gpack::length; ii=ii+1) begin
            sec_est_bits[ii] = estimated_bits[ii];
        end
        for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            sliced_est_bits[ii] = tmp_sliced_est_bits[ii][1];
        end
    end

    ffe_estimator #(
        .est_depth(ffe_gpack::length),
        .ffe_bitwidth(ffe_gpack::weight_precision), 
        .adapt_bitwidth(22), 
        .code_bitwidth(constant_gpack::code_precision),
        .est_bit_bitwidth(ffe_gpack::output_precision)
    ) ffe_est_i (
        .clk(clk_adc),
        .rst_n(dcore_rstb),
        .est_bits(sec_est_bits),
        .current_code(act_codes[0]),

        .fe_nrz_mode(0),

        .gain(ddbg_intf_i.fe_adapt_gain),
        .bit_target_level(ddbg_intf_i.fe_bit_target_level),
        .slice_levels(slice_levels),
        .exec_inst(ddbg_intf_i.fe_exec_inst),
        .inst(ddbg_intf_i.fe_inst),

        .ffe_init(ddbg_intf_i.init_ffe_taps),
        .ffe_est(single_weights)
    );
    
    signed_buffer #(
        .numChannels (16),
        .bitwidth    (2**constant_gpack::sym_bitwidth-1),
        .depth       (2)
    ) sb_buff_i (
        .in      (stage2_slcd_bits),
        .clk     (clk_adc),
        .rstb    (dcore_rstb),
        .buffer  (stage2_slcd_bits_buffer)
    );

    signed_buffer #(
        .numChannels (16),
        .bitwidth    (9),
        .depth       (2)
    ) est_err_buff_i (
        .in      (stage2_est_errors),
        .clk     (clk_adc),
        .rstb    (dcore_rstb),
        .buffer  (stage2_est_errors_buffer)
    );

    signed_flatten_buffer_slice #(
        .numChannels(16),
        .bitwidth   (9),
        .buff_depth (2),
        .slice_depth(1),
        .start      (1)
    ) est_err_fb_i (
        .buffer    (stage2_est_errors_buffer),
        .flat_slice(flat_stage2_est_errors)
    );



    channel_estimator #( 
        .est_depth(channel_gpack::est_channel_depth),
        .est_bitwidth(channel_gpack::est_channel_precision), 
        .adapt_bitwidth(21), 
        .err_bitwidth(detector_gpack::est_error_precision)
    ) chan_est_i (
        .clk(clk_adc),
        .rst_n(dcore_rstb),
        .error(flat_stage2_est_errors),
        .current_bit(stage2_slcd_bits_buffer[0][2]),

        .gain(ddbg_intf_i.ce_gain),
        .inst(ddbg_intf_i.ce_inst),
        .exec_inst(ddbg_intf_i.ce_exec_inst),
        .load_addr(ddbg_intf_i.ce_addr),
        .load_val(ddbg_intf_i.ce_val),
        .est_chan(single_chan_est)
    );

    always_ff @(posedge clk_adc or negedge dcore_rstb) begin
        if(~dcore_rstb) begin
            ddbg_intf_i.ce_sampled_value <= 0;
            ddbg_intf_i.fe_sampled_value <= 0;
        end else begin
            if(ddbg_intf_i.sample_fir_est) begin
                ddbg_intf_i.ce_sampled_value <= (chan_est_i.int_chan_est[ddbg_intf_i.sample_pos] >>> 21);
                ddbg_intf_i.fe_sampled_value <= single_weights[ddbg_intf_i.sample_pos];
            end
        end
    end

    generate
        for(gj=0; gj < ffe_gpack::length; gj = gj + 1) begin
            for(gi=0; gi<channel_gpack::width; gi = gi + 1) begin
                assign dsp_dbg_intf_i.weights[gi][gj] = single_weights[gj];
            end
        end
        for(gj =0; gj < channel_gpack::est_channel_depth; gj = gj + 1) begin
            assign dsp_dbg_intf_i.channel_est[0][gj] = single_chan_est[gj]; 
        end
    endgenerate

    // Add a downclocked oneshot multimemory!


    // SRAM
    /*
    oneshot_multimemory #(
        .N_mem_tiles(2)
    ) oneshot_multimemory_i(
        .clk(clk_adc),
        .rstb(sram_rstb),
        
        .in_bytes(adcout_unfolded),

        .in_start_write(dump_start),

        .in_addr(sm1_dbg_intf_i.in_addr),

        .out_data(sm1_dbg_intf_i.out_data),
        .addr(sm1_dbg_intf_i.addr)
    );*/

    // PRBS
    // TODO: refine data decision from ADC (custom threshold, gain, invert option, etc.)

    logic [constant_gpack::sym_bitwidth-1:0] mux_prbs_rx_syms       [3:0][Nti-1:0] ;
    logic [constant_gpack::sym_bitwidth-1:0] prbs_rx_syms           [Nti-1:0];
    logic [constant_gpack::sym_bitwidth-1:0] mux_prbs_trig_rx_syms  [3:0][Nti-1:0];
    logic [constant_gpack::sym_bitwidth-1:0] prbs_trig_rx_syms      [Nti-1:0];

    comb_comp #(.numChannels(16), .inputBitwidth(Nadc), .thresholdBitwidth(Nadc+2)) dig_comp_adc_i (
        .codes     (adcout_unfolded_non_rep),
        .slice_levels (slice_levels),
        .sym_out   (encoded_raw_symbols)
    );





    logic bit_bist_r;

    assign mux_prbs_rx_syms[0] = decoded_raw_symbols;
    assign mux_prbs_rx_syms[1] = decoded_symbols;
    assign mux_prbs_rx_syms[2] = decoded_corrected_symbols;
    //assign mux_prbs_rx_bits[3] = {Nti{bit_bist_r}};


    assign mux_prbs_trig_rx_syms[0] = decoded_raw_symbols;
    assign mux_prbs_trig_rx_syms[1] = decoded_symbols;
    assign mux_prbs_trig_rx_syms[2] = decoded_corrected_symbols;
    //assign mux_prbs_trig_rx_bits[3] = {Nti{bit_bist_r}};


    assign prbs_rx_syms       = mux_prbs_rx_syms      [ddbg_intf_i.sel_prbs_mux];

    assign prbs_trig_rx_syms  = mux_prbs_trig_rx_syms      [ddbg_intf_i.sel_trig_prbs_mux];
    // PRBS generator for BIST
    initial begin
        $dumpvars(0, prbs_checker_i);
        $dumpvars(0, prbs_checker_trigger_i);
    end
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

    logic [63:0] prbs_err_bits, prbs_err_bits_trigger;
    assign pdbg_intf_i.prbs_err_bits_upper = ddbg_intf_i.sel_prbs_bits ? prbs_err_bits_trigger[63:32] : prbs_err_bits[63:32];
    assign pdbg_intf_i.prbs_err_bits_lower = ddbg_intf_i.sel_prbs_bits ? prbs_err_bits_trigger[31:0] : prbs_err_bits[31:0];

    logic [63:0] prbs_total_bits, prbs_total_bits_trigger;
    assign pdbg_intf_i.prbs_total_bits_upper = ddbg_intf_i.sel_prbs_bits ? prbs_total_bits_trigger[63:32] : prbs_total_bits[63:32];
    assign pdbg_intf_i.prbs_total_bits_lower = ddbg_intf_i.sel_prbs_bits ? prbs_total_bits_trigger[31:0] : prbs_total_bits[31:0];

    sym_prbs_checker #(
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
        .rx_syms(prbs_rx_syms),
        // checker mode
        .checker_mode(pdbg_intf_i.prbs_checker_mode),
        // outputs
        .err_bits(prbs_err_bits),
        .total_bits(prbs_total_bits),
        .prbs_flags(prbs_flags)
    );

    sym_prbs_checker #(
        .n_prbs(Nprbs),
        .n_channels(Nti)
    ) prbs_checker_trigger_i (
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
        .rx_syms(prbs_trig_rx_syms),
        // checker mode
        .checker_mode(pdbg_intf_i.prbs_checker_mode),
        // outputs
        .err_bits(prbs_err_bits_trigger),
        .total_bits(prbs_total_bits_trigger),
        .prbs_flags(prbs_flags_trigger)
    );

    
    error_tracker #(
        .width(Nti),
        .error_bitwidth(error_gpack::est_error_precision),
        .addrwidth(10),
        .flag_width(4)
    ) errt_i (
        .prbs_flags_trigger(prbs_flags_trigger),
        .prbs_flags(prbs_flags),
        .est_error(est_errors),
        .encoded_symbols(encoded_symbols),
        .sd_flags(sd_flags),
        .clk(clk_adc),
        .rstb(dcore_rstb),
        .errt_dbg_intf_i(edbg_intf_i)
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
        .ffe_data(trunc_est_bits_ext),
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
    assign buffered_signals[7]  = 0; //adbg_intf_i.del_out_rep[1];
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
        .pdbg_intf_i(pdbg_intf_i),
        .mdbg_intf_i(mdbg_intf_i),
        .hdbg_intf_i(hdbg_intf_i),
        .edbg_intf_i(edbg_intf_i),
        //.tdbg_intf_i(tdbg_intf_i),
        //.odbg_intf_i(odbg_intf_i),
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



endmodule

`default_nettype wire
