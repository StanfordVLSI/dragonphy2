`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

module flip_bit_locator_datapath #(
    parameter integer seq_length=4,
    parameter integer flip_bits_output_pipeline_depth = 0,
    parameter integer num_of_flip_patterns = 4,
    parameter integer flip_pattern_depth   = 3,
    parameter integer flip_patterns[num_of_flip_patterns-1:0][flip_pattern_depth-1:0] = '{'{0,1,0}, '{0,1,1}, '{1,1,1},'{1,0,1}},
    parameter integer delay_width=4,
    parameter integer width_width=4
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
    output logic                                               flip_bits_out    [constant_gpack::channel_width-1:0],
    
    output logic [delay_width+width_width-1:0] sliced_bits_out_delay,
    output logic [delay_width+width_width-1:0] res_errors_out_delay,
    output logic [delay_width+width_width-1:0] flip_bits_out_delay


); 

    localparam integer flag_width = $clog2(num_of_flip_patterns+1);

    genvar gi;
    localparam flags_buffer_depth = 2;

    localparam total_depth = flags_buffer_depth + flip_bits_output_pipeline_depth;

    localparam sliced_bits_buffer_depth         = 1 + 2;
    localparam aligned_sliced_bits_buffer_depth = flip_bits_output_pipeline_depth;
    localparam aligned_sliced_bits_buffer_end   = flip_bits_output_pipeline_depth;

    localparam rse_buffer_depth                 = 1 + 2;
    localparam aligned_rse_buffer_depth         = flip_bits_output_pipeline_depth;
    localparam aligned_rse_buffer_end           = flip_bits_output_pipeline_depth;

    logic [flag_width-1:0]                              flags_buffer             [constant_gpack::channel_width-1:0][flags_buffer_depth:0];
    logic [error_gpack::ener_bitwidth-1:0]              flag_ener_buffer         [constant_gpack::channel_width-1:0][flags_buffer_depth:0];
    logic                                               flip_bits_buffer         [constant_gpack::channel_width-1:0][flip_bits_output_pipeline_depth:0];
    logic                                               sliced_bits_buffer       [constant_gpack::channel_width-1:0][sliced_bits_buffer_depth:0];
    logic signed [error_gpack::est_error_precision-1:0] rse_buffer               [constant_gpack::channel_width-1:0][rse_buffer_depth:0];

    logic                                               aligned_sliced_bits_buffer       [constant_gpack::channel_width-1:0][aligned_sliced_bits_buffer_depth:0];
    logic signed [error_gpack::est_error_precision-1:0] aligned_rse_buffer               [constant_gpack::channel_width-1:0][aligned_rse_buffer_depth:0];


    logic [delay_width + width_width -1 : 0] flags_buffer_delay                         [flags_buffer_depth:0];
    logic [delay_width + width_width -1 : 0] flag_ener_buffer_delay                         [flags_buffer_depth:0];
    logic [delay_width + width_width -1 : 0] flip_bits_buffer_delay                         [flip_bits_output_pipeline_depth:0];
    logic [delay_width + width_width -1 : 0] sliced_bits_buffer_delay                      [sliced_bits_buffer_depth:0];
    logic [delay_width + width_width -1 : 0] rse_buffer_delay                       [rse_buffer_depth:0];
    logic [delay_width + width_width -1 : 0] aligned_sliced_bits_buffer_delay                       [aligned_sliced_bits_buffer_depth:0];
    logic [delay_width + width_width -1 : 0] aligned_rse_buffer_delay                       [aligned_rse_buffer_depth:0];

    generate
        for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
            assign sliced_bits_out[gi]        = aligned_sliced_bits_buffer[gi][aligned_sliced_bits_buffer_end];
            assign res_errors_out[gi]         = aligned_rse_buffer[gi][aligned_rse_buffer_end];
            assign flip_bits_out[gi]          = flip_bits_buffer[gi][flip_bits_output_pipeline_depth];
        end
    endgenerate

    assign sliced_bits_out_delay        = aligned_sliced_bits_buffer_delay[aligned_sliced_bits_buffer_end];
    assign res_errors_out_delay         = aligned_rse_buffer_delay[aligned_rse_buffer_end];
    assign flip_bits_out_delay          = flip_bits_buffer_delay[flip_bits_output_pipeline_depth];
    // synthesis translate_off

    //always_ff @(posedge clk) begin
    //    $display("%m.sliced_bits_out_delay : %p", sliced_bits_out_delay);
    //    $display("%m.res_errors_out_delay : %p", res_errors_out_delay);
    //    $display("%m.flip_bits_out_delay : %p", flip_bits_out_delay);
//
    //    $display("%m.aligned_sliced_bits_buffer_delay : %p", aligned_sliced_bits_buffer_delay);
    //    $display("%m.aligned_rse_buffer_delay : %p", aligned_rse_buffer_delay);
    //    $display("%m.flip_bits_buffer_delay : %p", flip_bits_buffer_delay);
//
    //    $display("%m.sd_flags_delay : %p", sd_flags_delay);
    //    $display("%m.sd_flags_ener_delay : %p", sd_flags_ener_delay);
    //    $display("%m.sliced_bits_in_delay : %p", sliced_bits_in_delay);
    //    $display("%m.res_errors_in_delay : %p", res_errors_in_delay);
    //end
    // synthesis translate_on

    //Detector pipeline
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .depth      (sliced_bits_buffer_depth)
    ) sliced_bits_reg_i (
        .in (sliced_bits_in),
        .in_delay(sliced_bits_in_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(sliced_bits_buffer),
        .buffer_delay(sliced_bits_buffer_delay)
    );

    //Main Estimated Error Buffer
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .depth      (rse_buffer_depth)
    ) res_err_reg_i (
        .in (res_errors_in),
        .in_delay(res_errors_in_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(rse_buffer),
        .buffer_delay(rse_buffer_delay)
    );

    logic  flat_u_bits [constant_gpack::channel_width*(3)-1:0];
    logic [delay_width+width_width-1:0] flat_u_bits_delay;
    flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .buff_depth (sliced_bits_buffer_depth),
        .slice_depth(2),
        .start(0)
    ) u_bits_fb_i (
        .buffer    (sliced_bits_buffer),
        .buffer_delay(sliced_bits_buffer_delay),
        .flat_slice(flat_u_bits),
        .flat_slice_delay(flat_u_bits_delay)
    );

    logic  aligned_bits [constant_gpack::channel_width-1:0];
    logic [delay_width+width_width-1:0] aligned_bits_delay;
    bit_aligner #(
        .width(constant_gpack::channel_width),
        .depth(3)
    ) sliced_bits_aligner_i (
        .bit_segment(flat_u_bits),
        .bit_segment_delay(flat_u_bits_delay),
        .align_pos   (32-seq_length-8-2),
        .aligned_bits(aligned_bits),
        .aligned_bits_delay(aligned_bits_delay)
    );

    logic signed [error_gpack::est_error_precision-1:0] flat_u_res [constant_gpack::channel_width*(3)-1:0];
    logic [delay_width+width_width-1:0] flat_u_res_delay;
    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .buff_depth (rse_buffer_depth),
        .slice_depth(2),
        .start(0)
    ) u_res_fb_i (
        .buffer    (rse_buffer),
        .buffer_delay(rse_buffer_delay),
        .flat_slice(flat_u_res),
        .flat_slice_delay(flat_u_res_delay)
    );

    logic signed [error_gpack::est_error_precision-1:0] aligned_rse [constant_gpack::channel_width-1:0];
    logic [delay_width+width_width-1:0] aligned_rse_delay;
    signed_data_aligner #(
        .width(constant_gpack::channel_width),
        .depth(3),
        .bitwidth(error_gpack::est_error_precision)
    ) res_errors_aligner_i (
        .data_segment(flat_u_res),
        .data_segment_delay(flat_u_res_delay),
        .align_pos   (32-seq_length-8-2),
        .aligned_data(aligned_rse),
        .aligned_data_delay(aligned_rse_delay)
    );

    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .depth      (aligned_sliced_bits_buffer_depth)
    ) aligned_sliced_bits_reg_i (
        .in (aligned_bits),
        .in_delay(aligned_bits_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(aligned_sliced_bits_buffer),
        .buffer_delay(aligned_sliced_bits_buffer_delay)
    );

    //Main Estimated Error Buffer
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .depth      (aligned_rse_buffer_depth)
    ) aligned_res_err_reg_i (
        .in (aligned_rse),
        .in_delay(aligned_rse_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(aligned_rse_buffer),
        .buffer_delay(aligned_rse_buffer_delay)
    );

    //Detector pipeline
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (flag_width),
        .depth      (flags_buffer_depth)
    ) flag_reg_i (
        .in (sd_flags),
        .in_delay(sd_flags_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(flags_buffer),
        .buffer_delay(flags_buffer_delay)
    );

    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::ener_bitwidth),
        .depth      (flags_buffer_depth)
    ) flag_ener_reg_i (
        .in (sd_flags_ener),
        .in_delay(sd_flags_ener_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(flag_ener_buffer),
        .buffer_delay(flag_ener_buffer_delay)
    );

    logic [flag_width-1:0] flat_flags [constant_gpack::channel_width*(1+flags_buffer_depth)-1:0];
    logic [delay_width+width_width-1:0] flat_flags_delay;
    flatten_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (flag_width),
        .depth (flags_buffer_depth)
    ) flag_fb_i (
        .buffer    (flags_buffer),
        .buffer_delay(flags_buffer_delay),
        .flat_buffer(flat_flags),
        .flat_buffer_delay(flat_flags_delay)
    );

    logic [error_gpack::ener_bitwidth-1:0] flat_flags_ener [constant_gpack::channel_width*(1+flags_buffer_depth)-1:0];
    logic [delay_width+width_width-1:0] flat_flags_ener_delay;
    flatten_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::ener_bitwidth),
        .depth (flags_buffer_depth)
    ) flag_ener_fb_i (
        .buffer    (flag_ener_buffer),
        .buffer_delay(flag_ener_buffer_delay),
        .flat_buffer(flat_flags_ener),
        .flat_buffer_delay(flat_flags_ener_delay)
    );

    logic  flip_bits [constant_gpack::channel_width-1:0];
    logic [delay_width+width_width-1:0] flip_bits_delay;
    //subframe_flip_bit_locator -- unfortunately incurs a delay of 1 :( to borrow from future
    logic [flag_width-1:0] flat_flags_slice [constant_gpack::channel_width*(1+flags_buffer_depth)-8-1:0];
    logic [error_gpack::ener_bitwidth-1:0] flat_flags_ener_slice [constant_gpack::channel_width*(1+flags_buffer_depth)-8-1:0];

    generate
        for(gi = 0; gi < 3*constant_gpack::channel_width-8; gi += 1) begin
            assign flat_flags_slice[gi] = flat_flags[gi + 8];
            assign flat_flags_ener_slice[gi] = flat_flags_ener[gi + 8];
        end
    endgenerate


    wide_subframe_flip_bit_locator #(
        .width(constant_gpack::channel_width),
        .subframe_width(8),
        .ener_bitwidth(error_gpack::ener_bitwidth),
        .num_of_flip_patterns(num_of_flip_patterns),
        .flip_pattern_depth(flip_pattern_depth),
        .flip_patterns(flip_patterns)
    ) subframe_fp_loc_i (
    .clk            (clk),
        .flags(flat_flags_slice),
        .flags_delay(flat_flags_delay),
        .flag_ener(flat_flags_ener_slice),
        .flag_ener_delay(flat_flags_ener_delay),

        .flip_bits(flip_bits),
        .flip_bits_delay(flip_bits_delay)
    );

    // Pipeline Stage
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .depth      (flip_bits_output_pipeline_depth)
    ) flip_bits_reg_i (
        .in (flip_bits),
        .in_delay    (flip_bits_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(flip_bits_buffer),
        .buffer_delay(flip_bits_buffer_delay)
    );


endmodule : flip_bit_locator_datapath