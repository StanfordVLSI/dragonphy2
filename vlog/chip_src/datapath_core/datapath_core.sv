`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)
`default_nettype none

module datapath_core #(
        parameter integer delay_width=4,
        parameter integer width_width=4,
        parameter integer sym_bitwidth=2,
        parameter integer branch_bitwidth=2,
        parameter integer num_of_trellis_patterns=4,
        parameter integer trellis_pattern_depth=4
)(
    input wire logic signed [constant_gpack::code_precision-1:0] adc_codes [constant_gpack::channel_width-1:0],

    input wire logic clk,
    input wire logic rstb,

    //Stage 1
    output logic signed [ffe_gpack::output_precision-1:0]      stage1_est_bits_out    [constant_gpack::channel_width-1:0],
    output logic signed [(2**sym_bitwidth-1)-1:0]              stage1_symbols_out [constant_gpack::channel_width-1:0],
    output logic signed [constant_gpack::code_precision-1:0]   stage1_act_codes_out [constant_gpack::channel_width-1:0],

    //Stage 2
    output logic signed [error_gpack::est_error_precision-1:0] stage2_res_errors_out  [constant_gpack::channel_width-1:0],
    output logic signed [(2**sym_bitwidth-1)-1:0]              stage2_symbols_out [constant_gpack::channel_width-1:0],
    // Stage 3
    output logic        [error_gpack::ener_bitwidth-1:0]       stage3_sd_flags_ener   [constant_gpack::channel_width-1:0],
    output logic        [$clog2(2*detector_gpack::num_of_trellis_patterns+1)-1:0]                                  stage3_sd_flags        [constant_gpack::channel_width-1:0],
    // Stage 4
    output logic signed [(2**sym_bitwidth-1)-1:0]              stage4_symbols_out [constant_gpack::channel_width-1:0],
    output logic signed [error_gpack::est_error_precision-1:0] stage4_res_errors_out  [constant_gpack::channel_width-1:0],
  
    output logic signed [error_gpack::est_error_precision-1:0] stage4_aligned_stage2_res_errors_out  [constant_gpack::channel_width-1:0],
    output logic signed [(2**sym_bitwidth-1)-1:0]              stage4_aligned_stage2_symbols_out [constant_gpack::channel_width-1:0],
    output logic        [$clog2(2*detector_gpack::num_of_trellis_patterns+1)-1:0]                                  stage4_aligned_stage3_sd_flags        [constant_gpack::channel_width-1:0],

    dsp_debug_intf.dsp dsp_dbg_intf_i //Stand in for Debug Interface
);

    parameter integer stage1_depth = `MAX(1, constant_gpack::stage1_ffe_pipeline_depth + 1);
    parameter integer stage2_depth = stage1_depth + constant_gpack::stage2_chan_pipeline_depth  + constant_gpack::stage2_err_out_pipeline_depth;
    parameter integer stage3_depth = stage2_depth + constant_gpack::stage3_sld_dtct_out_pipeline_depth;
    parameter integer stage4_depth = stage3_depth + 1+constant_gpack::stage4_fp_bits_out_pipeline_depth+constant_gpack::stage4_err_chan_out_pipeline_depth + constant_gpack::stage4_res_err_out_pipeline_depth;

    parameter integer total_depth  = stage4_depth; //stage6_depth;

    logic signed [(2**sym_bitwidth-1)-1:0]                         stage2_symbols_buffer  [constant_gpack::channel_width-1:0][stage4_depth-stage2_depth+2:0];
    logic signed [error_gpack::est_error_precision-1:0]     stage2_res_error_buffer    [constant_gpack::channel_width-1:0][stage4_depth-stage2_depth+2:0];
    logic        [$clog2(2*detector_gpack::num_of_trellis_patterns+1)-1:0]                                      stage3_sd_flags_buffer     [constant_gpack::channel_width-1:0][stage4_depth-stage3_depth+2:0];

    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    ((2**sym_bitwidth-1)),
        .depth       (stage4_depth-stage2_depth+2)
    ) s2_sliced_bits_buff_i (
        .in      (stage2_symbols_out),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (stage2_symbols_buffer)
    );

    //ADC Codes Pipeline
    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (error_gpack::est_error_precision),
        .depth       (stage4_depth-stage2_depth+2)
    ) s2_res_err_buff_i (
        .in      (stage2_res_errors_out),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (stage2_res_error_buffer)
    );

    buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    ($clog2(2*detector_gpack::num_of_trellis_patterns+1)),
        .depth       (stage4_depth-stage3_depth+2)
    ) s3_flags_buff_i (
        .in      (stage3_sd_flags),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (stage3_sd_flags_buffer)
    );

    always_comb begin
        for(int ii = 0; ii < constant_gpack::channel_width; ii += 1) begin
            stage4_aligned_stage2_res_errors_out[ii]    = stage2_res_error_buffer[ii][stage4_depth-stage2_depth];
            stage4_aligned_stage2_symbols_out[ii]       = stage2_symbols_buffer[ii][stage4_depth-stage2_depth];
            stage4_aligned_stage3_sd_flags[ii]          = stage3_sd_flags_buffer[ii][stage4_depth-stage3_depth];
        end
    end

    wire logic signed [ffe_gpack::weight_precision-1:0]           weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0];
    wire logic        [ffe_gpack::shift_precision-1:0]            ffe_shift [constant_gpack::channel_width-1:0];
    wire logic signed [ffe_gpack::output_precision-1:0]           bit_level;
    wire logic signed [channel_gpack::est_channel_precision-1:0]  channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0];
    wire logic        [channel_gpack::shift_precision-1:0]        channel_shift [constant_gpack::channel_width-1:0];
    wire logic        [$clog2(constant_gpack::channel_width)-1:0] align_pos;
    wire logic signed [branch_bitwidth-1:0]                       trellis_patterns       [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0];

    simplify_dsp_dbg_intf simp_dsp_i (
        //Input 
        .dsp_dbg_intf_i(dsp_dbg_intf_i),
        //Output
        .align_pos(align_pos),
        .weights(weights),
        .ffe_shift(ffe_shift),
        .bit_level(bit_level),
        .channel_est(channel_est),
        .trellis_patterns(trellis_patterns),
        .channel_shift(channel_shift)
    );

    bits_estimator_datapath  #(
        .ffe_pipeline_depth(constant_gpack::stage1_ffe_pipeline_depth)
    )bit_est_stage_1_i(
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .act_codes_in(adc_codes),
        // Outputs
        .est_syms_out(stage1_est_bits_out),    
        .symbols_out(stage1_symbols_out),
        .act_codes_out(stage1_act_codes_out),

        // JTAG Registers
        .weights(weights),
        .ffe_shift(ffe_shift),
        .bit_level(bit_level),
        .align_pos(align_pos)
    );

    res_err_estimator_datapath  #(
        .channel_pipeline_depth(constant_gpack::stage2_chan_pipeline_depth),
        .error_output_pipeline_depth(constant_gpack::stage2_err_out_pipeline_depth),
        .main_cursor_position(2)
    ) res_err_stage_2_i (
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .symbols_in(stage1_symbols_out),
        .act_codes_in(stage1_act_codes_out), 

        // Outputs
        .symbols_out(stage2_symbols_out),
        .res_err_out(stage2_res_errors_out),

        // JTAG Registers
        .channel_est(channel_est),
        .channel_shift(channel_shift)
    );

    logic signed [(2**sym_bitwidth-1)-1:0]              stage3_symbols_out [constant_gpack::channel_width-1:0];
    logic signed [error_gpack::est_error_precision-1:0] stage3_res_errors_out  [constant_gpack::channel_width-1:0];

    error_checker_datapath  #(
        .seq_length(4),
        .sym_bitwidth(sym_bitwidth),
        .branch_bitwidth(2),
        .num_of_trellis_patterns(4),
        .trellis_pattern_depth(4),
        .sliding_detector_output_pipeline_depth(constant_gpack::stage3_sld_dtct_out_pipeline_depth)
    ) err_chk_stage_3_i (
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .symbols_in(stage2_symbols_out),
        .res_errors_in(stage2_res_errors_out),

        // Outputs
        .sd_flags(stage3_sd_flags),       
        .sd_flags_ener(stage3_sd_flags_ener),
        .symbols_out(stage3_symbols_out),
        .res_errors_out(stage3_res_errors_out),

        //JTAG Registers
        .channel_est(channel_est[0]),
        .channel_shift(channel_shift[0]),
        .trellis_patterns(trellis_patterns)
    );

    symbol_error_corrector_datapath #(
        .seq_length(4),
        .sym_bitwidth(sym_bitwidth),
        .branch_bitwidth(2),
        .num_of_trellis_patterns(4),
        .trellis_pattern_depth(4),
        .main_cursor_position(2),
        .error_channel_pipeline_depth(constant_gpack::stage4_err_chan_out_pipeline_depth),
        .residual_error_output_pipeline_depth(constant_gpack::stage4_res_err_out_pipeline_depth),
        .symbol_adjust_output_pipeline_depth(constant_gpack::stage4_fp_bits_out_pipeline_depth)
    ) err_corr_stage_4_i (
        .clk(clk),
        .rstb(rstb),

        .sd_flags(stage3_sd_flags),
        .sd_flags_ener(stage3_sd_flags_ener),
        .symbols_in(stage3_symbols_out),
        .res_errors_in(stage3_res_errors_out),

        .symbols_out(stage4_symbols_out),
        .res_errors_out(stage4_res_errors_out),

        .channel_est(channel_est),
        .channel_shift(channel_shift),
        .trellis_patterns(trellis_patterns)
    ); 
endmodule : datapath_core
`default_nettype wire
