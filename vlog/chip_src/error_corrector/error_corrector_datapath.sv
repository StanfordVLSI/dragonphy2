`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

module error_corrector_datapath #(
    parameter integer seq_length=4,
        parameter integer num_of_flip_patterns = 4,
        parameter integer flip_pattern_depth   = 3,
        parameter integer flip_patterns[num_of_flip_patterns-1:0][flip_pattern_depth-1:0] = '{'{0,1,0}, '{0,1,1}, '{1,1,1},'{1,0,1}},
        parameter integer flip_bits_output_pipeline_depth = 0,
        parameter integer main_cursor_position = 2,
        parameter integer error_channel_pipeline_depth = 0,
        parameter integer residual_error_output_pipeline_depth = 0,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
    ) (
    input logic clk,
    input logic rstb,

    input logic        [$clog2(num_of_flip_patterns+1)-1:0]    sd_flags        [constant_gpack::channel_width-1:0],
    input logic        [error_gpack::ener_bitwidth-1:0]        sd_flags_ener   [constant_gpack::channel_width-1:0],
    input logic                                                sliced_bits_in  [constant_gpack::channel_width-1:0],
    input logic signed [error_gpack::est_error_precision-1:0]  res_errors_in   [constant_gpack::channel_width-1:0],


    input logic [delay_width+width_width-1:0] sd_flags_delay,
    input logic [delay_width+width_width-1:0] sd_flags_ener_delay,
    input logic [delay_width+width_width-1:0] sliced_bits_in_delay,
    input logic [delay_width+width_width-1:0] res_errors_in_delay,

    output logic                                               sliced_bits_out  [constant_gpack::channel_width-1:0],
    output logic signed [error_gpack::est_error_precision-1:0] res_errors_out   [constant_gpack::channel_width-1:0],

    output logic [delay_width+width_width-1:0] sliced_bits_out_delay,
    output logic [delay_width+width_width-1:0] res_errors_out_delay,


    input logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0],
    input logic        [channel_gpack::shift_precision-1:0]       channel_shift [constant_gpack::channel_width-1:0]
); 


    genvar gi;
    localparam integer flag_width = $clog2(num_of_flip_patterns+1);
    localparam integer total_depth = 1 + flip_bits_output_pipeline_depth + error_channel_pipeline_depth + residual_error_output_pipeline_depth;

    logic                                                sub_stage_1_slcd_bits_out  [constant_gpack::channel_width-1:0];
    logic                                                sub_stage_1_flip_bits_out  [constant_gpack::channel_width-1:0];
    logic signed [error_gpack::est_error_precision-1:0]  sub_stage_1_res_errors_out   [constant_gpack::channel_width-1:0];

    logic [delay_width+width_width-1:0] sub_stage_1_slcd_bits_out_delay;
    logic [delay_width+width_width-1:0] sub_stage_1_flip_bits_out_delay;
    logic [delay_width+width_width-1:0] sub_stage_1_res_errors_out_delay;
    /*// synthesis translate_off


    always_ff @(posedge clk) begin
        $display("%m.sd_flags_delay :                   %p", sd_flags_delay);
        $display("%m.sd_flags_ener_delay :              %p", sd_flags_ener_delay);
        $display("%m.sliced_bits_in_delay :             %p", sliced_bits_in_delay);
        $display("%m.res_errors_in_delay :              %p", res_errors_in_delay);
        $display("%m.sub_stage_1_slcd_bits_out_delay :  %p", sub_stage_1_slcd_bits_out_delay);
        $display("%m.sub_stage_1_res_errors_out_delay : %p", sub_stage_1_res_errors_out_delay);
        $display("%m.sub_stage_1_flip_bits_out_delay :  %p", sub_stage_1_flip_bits_out_delay);
        $display("%m.res_errors_out_delay :             %p", res_errors_out_delay);
        $display("%m.sliced_bits_out_delay :            %p", sliced_bits_out_delay);


    end
    // synthesis translate_on*/

    flip_bit_locator_datapath #(
        .seq_length                     (seq_length),
        .flip_bits_output_pipeline_depth(flip_bits_output_pipeline_depth),
        .num_of_flip_patterns(num_of_flip_patterns),
        .flip_pattern_depth(flip_pattern_depth),
        .flip_patterns(flip_patterns)
    ) fb_loc_sub_stage_1_i (
        .clk(clk),
        .rstb(rstb),

        .sd_flags(sd_flags),
        .sd_flags_ener(sd_flags_ener),
        .sliced_bits_in(sliced_bits_in),
        .res_errors_in(res_errors_in),

        .sd_flags_delay(sd_flags_delay),
        .sd_flags_ener_delay(sd_flags_ener_delay),
        .sliced_bits_in_delay(sliced_bits_in_delay),
        .res_errors_in_delay(res_errors_in_delay),

        .sliced_bits_out(sub_stage_1_slcd_bits_out),
        .res_errors_out(sub_stage_1_res_errors_out),
        .flip_bits_out(sub_stage_1_flip_bits_out),

        .sliced_bits_out_delay(sub_stage_1_slcd_bits_out_delay),
        .res_errors_out_delay(sub_stage_1_res_errors_out_delay),
        .flip_bits_out_delay(sub_stage_1_flip_bits_out_delay)
    );

    flip_bit_reflector_datapath #(
        .error_channel_pipeline_depth(error_channel_pipeline_depth),
        .residual_error_output_pipeline_depth(residual_error_output_pipeline_depth),
        .main_cursor_position                (main_cursor_position),
        .num_of_flip_patterns(num_of_flip_patterns),
        .flip_pattern_depth(flip_pattern_depth),
        .flip_patterns(flip_patterns)
    ) fb_rflt_sub_stage_2_i (
        .clk(clk),
        .rstb(rstb),

        .sliced_bits_in(sub_stage_1_slcd_bits_out),
        .res_errors_in(sub_stage_1_res_errors_out),
        .flip_bits_in(sub_stage_1_flip_bits_out),

        .sliced_bits_in_delay(sub_stage_1_slcd_bits_out_delay),
        .res_errors_in_delay(sub_stage_1_res_errors_out_delay),
        .flip_bits_in_delay(sub_stage_1_flip_bits_out_delay),

        .res_errors_out(res_errors_out),
        .sliced_bits_out(sliced_bits_out),

        .res_errors_out_delay(res_errors_out_delay),
        .sliced_bits_out_delay(sliced_bits_out_delay),

        .channel_est(channel_est),
        .channel_shift(channel_shift)
    );

endmodule : error_corrector_datapath