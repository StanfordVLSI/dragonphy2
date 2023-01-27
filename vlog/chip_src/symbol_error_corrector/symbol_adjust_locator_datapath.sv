`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

module symbol_adjust_locator_datapath #(
    parameter integer seq_length=4,
    parameter integer branch_bitwidth = 2,
    parameter integer sym_bitwidth=2,
    parameter integer symbol_adjust_output_pipeline_depth = 0,
    parameter integer num_of_trellis_patterns = 4,
    parameter integer trellis_pattern_depth = 4
) (
    input logic clk,
    input logic rstb,

    input logic        [$clog2(2*num_of_trellis_patterns+1)-1:0]    sd_flags        [constant_gpack::channel_width-1:0],
    input logic        [error_gpack::ener_bitwidth-1:0]        sd_flags_ener   [constant_gpack::channel_width-1:0],
    input logic        [sym_bitwidth-1:0]                      symbols_in      [constant_gpack::channel_width-1:0],
    input logic signed [error_gpack::est_error_precision-1:0]  res_errors_in   [constant_gpack::channel_width-1:0],

    output logic        [sym_bitwidth-1:0]                     symbols_out     [constant_gpack::channel_width-1:0],
    output logic signed [error_gpack::est_error_precision-1:0] res_errors_out  [constant_gpack::channel_width-1:0],
    output logic signed [sym_bitwidth-1:0]                     symbol_adjust_out[constant_gpack::channel_width-1:0],

    input  logic signed [branch_bitwidth-1:0]  trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0]
); 

    localparam integer flag_width = $clog2(2*num_of_trellis_patterns+1);

    genvar gi;
    localparam flags_buffer_depth = 2;

    localparam total_depth = flags_buffer_depth + symbol_adjust_output_pipeline_depth;

    localparam symbols_buffer_depth         = 1 + 2;
    localparam aligned_symbols_buffer_depth = symbol_adjust_output_pipeline_depth;
    localparam aligned_symbols_buffer_end   = symbol_adjust_output_pipeline_depth;

    localparam rse_buffer_depth                 = 1 + 2;
    localparam aligned_rse_buffer_depth         = symbol_adjust_output_pipeline_depth;
    localparam aligned_rse_buffer_end           = symbol_adjust_output_pipeline_depth;

    logic [flag_width-1:0]                              flags_buffer             [constant_gpack::channel_width-1:0][flags_buffer_depth:0];
    logic [error_gpack::ener_bitwidth-1:0]              flag_ener_buffer         [constant_gpack::channel_width-1:0][flags_buffer_depth:0];
    logic signed [sym_bitwidth-1:0]                     symbol_adjust_buffer         [constant_gpack::channel_width-1:0][symbol_adjust_output_pipeline_depth:0];
    logic [sym_bitwidth-1:0]                            symbols_buffer       [constant_gpack::channel_width-1:0][symbols_buffer_depth:0];
    logic signed [error_gpack::est_error_precision-1:0] rse_buffer               [constant_gpack::channel_width-1:0][rse_buffer_depth:0];

    logic [sym_bitwidth-1:0]                            aligned_symbols_buffer       [constant_gpack::channel_width-1:0][aligned_symbols_buffer_depth:0];
    logic signed [error_gpack::est_error_precision-1:0] aligned_rse_buffer               [constant_gpack::channel_width-1:0][aligned_rse_buffer_depth:0];


    generate
        for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
            assign symbols_out[gi]        = aligned_symbols_buffer[gi][aligned_symbols_buffer_end];
            assign res_errors_out[gi]     = aligned_rse_buffer[gi][aligned_rse_buffer_end];
            assign symbol_adjust_out[gi]  = symbol_adjust_buffer[gi][symbol_adjust_output_pipeline_depth];
        end
    endgenerate

    //Detector pipeline
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (sym_bitwidth),
        .depth      (symbols_buffer_depth)
    ) symbols_reg_i (
        .in (symbols_in),
        .clk(clk),
        .rstb(rstb),
        .buffer(symbols_buffer)
    );

    //Main Estimated Error Buffer
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .depth      (rse_buffer_depth)
    ) res_err_reg_i (
        .in (res_errors_in),
        .clk(clk),
        .rstb(rstb),
        .buffer(rse_buffer)
    );

    logic [sym_bitwidth-1:0] flat_u_symbols [constant_gpack::channel_width*(3)-1:0];
    flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (sym_bitwidth),
        .buff_depth (symbols_buffer_depth),
        .slice_depth(2),
        .start(0)
    ) u_bits_fb_i (
        .buffer    (symbols_buffer),
        .flat_slice(flat_u_symbols)
    );

    logic [sym_bitwidth-1:0] aligned_symbols [constant_gpack::channel_width-1:0];
    data_aligner #(
        .width(constant_gpack::channel_width),
        .depth(3),
        .bitwidth(sym_bitwidth)
    ) symbols_aligner_i (
        .data_segment(flat_u_symbols),
        .align_pos   (32-seq_length-8-2),
        .aligned_data(aligned_symbols)
    );

    logic signed [error_gpack::est_error_precision-1:0] flat_u_res [constant_gpack::channel_width*(3)-1:0];
    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .buff_depth (rse_buffer_depth),
        .slice_depth(2),
        .start(0)
    ) u_res_fb_i (
        .buffer    (rse_buffer),
        .flat_slice(flat_u_res)
    );

    logic signed [error_gpack::est_error_precision-1:0] aligned_rse [constant_gpack::channel_width-1:0];
    signed_data_aligner #(
        .width(constant_gpack::channel_width),
        .depth(3),
        .bitwidth(error_gpack::est_error_precision)
    ) res_errors_aligner_i (
        .data_segment(flat_u_res),
        .align_pos   (32-seq_length-8-2),
        .aligned_data(aligned_rse)
    );

    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (sym_bitwidth),
        .depth      (aligned_symbols_buffer_depth)
    ) aligned_symbols_reg_i (
        .in (aligned_symbols),
        .clk(clk),
        .rstb(rstb),
        .buffer(aligned_symbols_buffer)
    );

    //Main Estimated Error Buffer
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .depth      (aligned_rse_buffer_depth)
    ) aligned_res_err_reg_i (
        .in (aligned_rse),
        .clk(clk),
        .rstb(rstb),
        .buffer(aligned_rse_buffer)
    );

    //Detector pipeline
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (flag_width),
        .depth      (flags_buffer_depth)
    ) flag_reg_i (
        .in (sd_flags),
        .clk(clk),
        .rstb(rstb),
        .buffer(flags_buffer)
    );

    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::ener_bitwidth),
        .depth      (flags_buffer_depth)
    ) flag_ener_reg_i (
        .in (sd_flags_ener),
        .clk(clk),
        .rstb(rstb),
        .buffer(flag_ener_buffer)
    );

    logic [flag_width-1:0] flat_flags [constant_gpack::channel_width*(1+flags_buffer_depth)-1:0];
    flatten_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (flag_width),
        .depth (flags_buffer_depth)
    ) flag_fb_i (
        .buffer    (flags_buffer),
        .flat_buffer(flat_flags)
    );

    logic [error_gpack::ener_bitwidth-1:0] flat_flags_ener [constant_gpack::channel_width*(1+flags_buffer_depth)-1:0];
    flatten_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::ener_bitwidth),
        .depth (flags_buffer_depth)
    ) flag_ener_fb_i (
        .buffer    (flag_ener_buffer),
        .flat_buffer(flat_flags_ener)
    );

    logic signed [sym_bitwidth-1:0] symbol_adjusts [constant_gpack::channel_width-1:0];
    //subframe_flip_bit_locator -- unfortunately incurs a delay of 1 :( to borrow from future
    logic [flag_width-1:0] flat_flags_slice [constant_gpack::channel_width*(1+flags_buffer_depth)-8-1:0];
    logic [error_gpack::ener_bitwidth-1:0] flat_flags_ener_slice [constant_gpack::channel_width*(1+flags_buffer_depth)-8-1:0];

    generate
        for(gi = 0; gi < 3*constant_gpack::channel_width-8; gi += 1) begin
            assign flat_flags_slice[gi] = flat_flags[gi + 8];
            assign flat_flags_ener_slice[gi] = flat_flags_ener[gi + 8];
        end
    endgenerate


    wide_subframe_symbol_adjust_locator #(
        .width(constant_gpack::channel_width),
        .subframe_width(8),
        .ener_bitwidth(error_gpack::ener_bitwidth),
        .branch_bitwidth(branch_bitwidth),
        .num_of_trellis_patterns(num_of_trellis_patterns),
        .trellis_pattern_depth(trellis_pattern_depth)
    ) subframe_fp_loc_i (
        .clk            (clk),
        .flags(flat_flags_slice),
        .flag_ener(flat_flags_ener_slice),

        .symbol_adjust(symbol_adjusts),

        .trellis_patterns(trellis_patterns)
    );

    // Pipeline Stage
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (2),
        .depth      (symbol_adjust_output_pipeline_depth)
    ) symbol_adjust_reg_i (
        .in (symbol_adjusts),
        .clk(clk),
        .rstb(rstb),
        .buffer(symbol_adjust_buffer)
    );


endmodule : symbol_adjust_locator_datapath