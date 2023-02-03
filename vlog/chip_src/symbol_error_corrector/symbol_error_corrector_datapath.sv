`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

module symbol_error_corrector_datapath #(
        parameter integer seq_length = 3,
        parameter integer sym_bitwidth = 2,
        parameter integer branch_bitwidth = 2,
        parameter integer num_of_trellis_patterns = 4,
        parameter integer trellis_pattern_depth = 4,
        parameter integer main_cursor_position = 2,
        parameter integer error_channel_pipeline_depth = 0,
        parameter integer residual_error_output_pipeline_depth = 0,
        parameter integer symbol_adjust_output_pipeline_depth = 0
    ) (
    input logic clk,
    input logic rstb,

    input logic        [$clog2(2*num_of_trellis_patterns+1)-1:0]    sd_flags        [constant_gpack::channel_width-1:0],
    input logic        [error_gpack::ener_bitwidth-1:0]        sd_flags_ener   [constant_gpack::channel_width-1:0],
    input logic signed [(2**sym_bitwidth-1)-1:0]                      symbols_in      [constant_gpack::channel_width-1:0],
    input logic signed [error_gpack::est_error_precision-1:0]  res_errors_in   [constant_gpack::channel_width-1:0],

    output logic signed [(2**sym_bitwidth-1)-1:0]                     symbols_out      [constant_gpack::channel_width-1:0],
    output logic signed [error_gpack::est_error_precision-1:0] res_errors_out   [constant_gpack::channel_width-1:0],

    input logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0],
    input logic        [channel_gpack::shift_precision-1:0]       channel_shift [constant_gpack::channel_width-1:0],
    input logic signed [branch_bitwidth-1:0]                      trellis_patterns       [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0]
); 


    genvar gi;
    localparam integer flag_width = $clog2(2*num_of_trellis_patterns+1);
    localparam integer total_depth = 1 + symbol_adjust_output_pipeline_depth + error_channel_pipeline_depth + residual_error_output_pipeline_depth;

    logic signed  [(2**sym_bitwidth-1)-1:0]               sub_stage_1_symbols_out  [constant_gpack::channel_width-1:0];
    logic signed  [(2**sym_bitwidth-1)-1:0]               sub_stage_1_symbol_adjust_out  [constant_gpack::channel_width-1:0];
    logic signed  [error_gpack::est_error_precision-1:0]  sub_stage_1_res_errors_out   [constant_gpack::channel_width-1:0];


    symbol_adjust_locator_datapath #(
        .seq_length                     (seq_length),
        .sym_bitwidth(sym_bitwidth),
        .symbol_adjust_output_pipeline_depth(symbol_adjust_output_pipeline_depth)
    ) fb_loc_sub_stage_1_i (
        .clk(clk),
        .rstb(rstb),

        .sd_flags(sd_flags),
        .sd_flags_ener(sd_flags_ener),
        .symbols_in(symbols_in),
        .res_errors_in(res_errors_in),

        .symbols_out(sub_stage_1_symbols_out),
        .res_errors_out(sub_stage_1_res_errors_out),
        .symbol_adjust_out(sub_stage_1_symbol_adjust_out),

        .trellis_patterns(trellis_patterns)
    );

    symbol_adjust_reflector_datapath #(
        .sym_bitwidth(sym_bitwidth),
        .error_channel_pipeline_depth(error_channel_pipeline_depth),
        .residual_error_output_pipeline_depth(residual_error_output_pipeline_depth),
        .main_cursor_position                (main_cursor_position)

    ) fb_rflt_sub_stage_2_i (
        .clk(clk),
        .rstb(rstb),

        .symbols_in(sub_stage_1_symbols_out),
        .res_errors_in(sub_stage_1_res_errors_out),
        .symbol_adjust_in(sub_stage_1_symbol_adjust_out),

        .res_errors_out(res_errors_out),
        .symbols_out(symbols_out),

        .channel_est(channel_est),
        .channel_shift(channel_shift)
    );

endmodule : symbol_error_corrector_datapath