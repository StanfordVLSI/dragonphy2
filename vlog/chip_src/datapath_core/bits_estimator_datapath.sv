`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)
`default_nettype none
module bits_estimator_datapath #(
    parameter integer ffe_pipeline_depth = 0,
    parameter integer sym_bitwidth = 2,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
    input wire logic signed [constant_gpack::code_precision-1:0] act_codes_in [constant_gpack::channel_width-1:0],

    input wire logic clk,
    input wire logic rstb,

    output logic signed [ffe_gpack::output_precision-1:0]      est_syms_out   [constant_gpack::channel_width-1:0],
    output logic signed [(2**sym_bitwidth-1)-1:0]                      symbols_out [constant_gpack::channel_width-1:0],
    output logic signed [constant_gpack::code_precision-1:0]   act_codes_out [constant_gpack::channel_width-1:0],

    input wire logic signed [ffe_gpack::weight_precision-1:0]          weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0],
    input wire logic        [ffe_gpack::shift_precision-1:0]           ffe_shift [constant_gpack::channel_width-1:0],
    input wire logic signed [ffe_gpack::output_precision-1:0]          slice_levels [2:0],

    input wire logic [$clog2(constant_gpack::channel_width)-1:0] align_pos
);
    genvar gi;

    localparam integer total_depth             = `MAX(1, ffe_pipeline_depth)+1;
    localparam integer ffe_code_pipeline_depth = 1;

    localparam integer code_pipeline_depth     = total_depth;
    localparam integer est_bits_pipeline_depth = total_depth;
    localparam integer bits_pipeline_depth = 0;

    logic signed [constant_gpack::code_precision-1:0] act_codes_buffer    [constant_gpack::channel_width-1:0][code_pipeline_depth:0];

    //ADC Codes Pipeline
    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (constant_gpack::code_precision),
        .depth       (code_pipeline_depth)
    ) adc_code_buff_i (
        .in      (act_codes_in),
        .clk     (clk),
        .rstb    (rstb),
        .buffer(act_codes_buffer)
    );
    

    generate
        for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
            assign act_codes_out[gi]           = act_codes_buffer[gi][code_pipeline_depth];
        end
    endgenerate

    //FFE
    logic signed [constant_gpack::code_precision-1:0] flat_act_codes [constant_gpack::channel_width*(1+ffe_code_pipeline_depth)-1:0];
    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (constant_gpack::code_precision),
        .buff_depth (code_pipeline_depth),
        .slice_depth(ffe_code_pipeline_depth),
        .start      (0)
    ) adc_codes_fb_i (
        .buffer    (act_codes_buffer),
        .flat_slice(flat_act_codes)
    );

    logic signed [ffe_gpack::output_precision-1:0] estimated_bits [constant_gpack::channel_width-1:0];
    comb_ffe #(
        .codeBitwidth(ffe_gpack::input_precision),
        .weightBitwidth(ffe_gpack::weight_precision),
        .resultBitwidth(ffe_gpack::output_precision),
        .shiftBitwidth(ffe_gpack::shift_precision),
        .ffeDepth(ffe_gpack::length),
        .numChannels(constant_gpack::channel_width),
        .numBuffers    (ffe_code_pipeline_depth+1),
        .t0_buff       (ffe_code_pipeline_depth)
    ) cffe_i (
        .weights       (weights),
        .flat_codes    (flat_act_codes),
        .shift_index   (ffe_shift),
        .estimated_bits(estimated_bits)
    );

    //FFE pipeline
    logic signed [ffe_gpack::output_precision-1:0] estimated_bits_buffer [constant_gpack::channel_width-1:0][est_bits_pipeline_depth:0];
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (ffe_gpack::output_precision),
        .depth      (est_bits_pipeline_depth)
    ) ffe_reg_i (
        .in (estimated_bits),
        .clk(clk),
        .rstb(rstb),
        .buffer(estimated_bits_buffer)
    );

    logic signed [ffe_gpack::output_precision-1:0] buffered_estimated_bit [constant_gpack::channel_width-1:0];
    generate
        for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
            assign buffered_estimated_bit[gi] = estimated_bits_buffer[gi][ffe_pipeline_depth];
            assign est_syms_out[gi]           = estimated_bits_buffer[gi][total_depth];
        end
    endgenerate



    //Slicer
    wire logic signed [(2**sym_bitwidth-1)-1:0] cmp_out [constant_gpack::channel_width-1:0];

    comb_comp #(
        .numChannels(cmp_gpack::width),
        .inputBitwidth(cmp_gpack::input_precision),
        .thresholdBitwidth(cmp_gpack::input_precision)
    ) ccmp_i (
        .codes(buffered_estimated_bit),
        .slice_levels(slice_levels),
        .sym_out   (cmp_out)
    );


    //Bits Pipeline
    logic signed [(2**sym_bitwidth-1)-1:0] cmp_out_buffer  [constant_gpack::channel_width-1:0][1:0];
    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    ((2**sym_bitwidth-1)),
        .depth       (1)
    ) cmp_out_buff_i (
        .in      (cmp_out),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (cmp_out_buffer)
    );

    logic signed [(2**sym_bitwidth-1)-1:0] flat_cmp_out_bits [constant_gpack::channel_width*2-1:0];
    signed_flatten_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   ((2**sym_bitwidth-1)),
        .depth (1)
    ) cmp_out_fb_i (
        .buffer    (cmp_out_buffer),
        .flat_buffer(flat_cmp_out_bits)
    );

    signed_data_aligner #(
        .width (constant_gpack::channel_width),
        .bitwidth((2**sym_bitwidth-1)),
        .depth(2)
    ) b_algn_i (
        .data_segment(flat_cmp_out_bits),
        .align_pos(align_pos),
        .aligned_data(symbols_out)
    );


endmodule // bits_estimator_datapath
`default_nettype wire
