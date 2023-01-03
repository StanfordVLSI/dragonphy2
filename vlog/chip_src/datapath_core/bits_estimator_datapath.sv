`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)
`default_nettype none
module bits_estimator_datapath #(
    parameter integer ffe_pipeline_depth = 0,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
    input wire logic signed [constant_gpack::code_precision-1:0] act_codes_in [constant_gpack::channel_width-1:0],
    input wire logic [delay_width+width_width-1:0] act_codes_in_delay ,

    input wire logic clk,
    input wire logic rstb,

    output logic signed [ffe_gpack::output_precision-1:0]      est_bits_out   [constant_gpack::channel_width-1:0],
    output logic                                               slcd_bits_out [constant_gpack::channel_width-1:0],
    output logic signed [constant_gpack::code_precision-1:0]   act_codes_out [constant_gpack::channel_width-1:0],

    output  logic       [delay_width+width_width-1:0]          est_bits_out_delay,    
    output  logic       [delay_width+width_width-1:0]          slcd_bits_out_delay, 
    output  logic       [delay_width+width_width-1:0]          act_codes_out_delay,

    input wire logic signed [ffe_gpack::weight_precision-1:0]          weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0],
    input wire logic        [ffe_gpack::shift_precision-1:0]           ffe_shift [constant_gpack::channel_width-1:0],
    input wire logic signed [ffe_gpack::output_precision-1:0]          bit_level,

    input wire logic                                                   disable_product [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0],
    input wire logic [$clog2(constant_gpack::channel_width)-1:0] align_pos
);
    genvar gi;

    localparam integer total_depth             = `MAX(1, ffe_pipeline_depth)+1;
    localparam integer ffe_code_pipeline_depth = 1;

    localparam integer code_pipeline_depth     = total_depth;
    localparam integer est_bits_pipeline_depth = total_depth;
    localparam integer bits_pipeline_depth = 0;


    logic [delay_width+width_width-1:0] curs_pos;

    always_comb begin
        curs_pos[delay_width+width_width-1:width_width] = 0;
        curs_pos[width_width-1:0] = align_pos;
    end

    logic signed [constant_gpack::code_precision-1:0] act_codes_buffer    [constant_gpack::channel_width-1:0][code_pipeline_depth:0];
    logic [delay_width+width_width-1:0]    act_codes_buffer_delay [code_pipeline_depth:0];
    //ADC Codes Pipeline
    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (constant_gpack::code_precision),
        .depth       (code_pipeline_depth)
    ) adc_code_buff_i (
        .in      (act_codes_in),
        .in_delay(act_codes_in_delay),
        .clk     (clk),
        .rstb    (rstb),
        .buffer(act_codes_buffer),
        .buffer_delay(act_codes_buffer_delay)
    );
    
    // synthesis translate_off
    assign act_codes_out_delay         = act_codes_buffer_delay[code_pipeline_depth];
    // synthesis translate_on
    generate
        for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
            assign act_codes_out[gi]           = act_codes_buffer[gi][code_pipeline_depth];
        end
    endgenerate

    //FFE
    logic signed [constant_gpack::code_precision-1:0] flat_act_codes [constant_gpack::channel_width*(1+ffe_code_pipeline_depth)-1:0];
    logic [delay_width+width_width-1:0]    flat_act_codes_delay;
    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (constant_gpack::code_precision),
        .buff_depth (code_pipeline_depth),
        .slice_depth(ffe_code_pipeline_depth),
        .start      (0)
    ) adc_codes_fb_i (
        .buffer    (act_codes_buffer),
        .buffer_delay(act_codes_buffer_delay),
        .flat_slice(flat_act_codes),
        .flat_slice_delay(flat_act_codes_delay)
    );

    logic signed [ffe_gpack::output_precision-1:0] estimated_bits [constant_gpack::channel_width-1:0];
    logic [delay_width+width_width-1:0]    estimated_bits_delay;
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
        .flat_codes_delay(flat_act_codes_delay),
        .disable_product(disable_product),
        .shift_index   (ffe_shift),
        .estimated_bits(estimated_bits),
        .estimated_bits_delay(estimated_bits_delay),
        .curs_pos(curs_pos)
    );

    //FFE pipeline
    logic signed [ffe_gpack::output_precision-1:0] estimated_bits_buffer [constant_gpack::channel_width-1:0][est_bits_pipeline_depth:0];
        logic [delay_width+width_width-1:0]    estimated_bits_buffer_delay[est_bits_pipeline_depth:0];
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (ffe_gpack::output_precision),
        .depth      (est_bits_pipeline_depth)
    ) ffe_reg_i (
        .in (estimated_bits),
        .in_delay(estimated_bits_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(estimated_bits_buffer),
        .buffer_delay(estimated_bits_buffer_delay)
    );

    logic signed [ffe_gpack::output_precision-1:0] buffered_estimated_bit [constant_gpack::channel_width-1:0];
    logic [delay_width+width_width-1:0]    buffered_estimated_bit_delay;
    generate
        for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
            assign buffered_estimated_bit[gi] = estimated_bits_buffer[gi][ffe_pipeline_depth];
            assign est_bits_out[gi]           = estimated_bits_buffer[gi][total_depth];
        end
    endgenerate

    assign buffered_estimated_bit_delay = estimated_bits_buffer_delay[ffe_pipeline_depth];
    assign est_bits_out_delay           = estimated_bits_buffer_delay[total_depth];

    //Slicer
    wire logic cmp_out [constant_gpack::channel_width-1:0];
    wire logic [1:0] tmp_cmp_out [constant_gpack::channel_width-1:0];

    generate
        for(gi =0; gi < constant_gpack::channel_width; gi = gi + 1) begin
            assign cmp_out[gi] = tmp_cmp_out[gi][1];
        end
    endgenerate


    logic [delay_width+width_width-1:0]    cmp_out_delay;
    comb_comp #(
        .numChannels(cmp_gpack::width),
        .inputBitwidth(cmp_gpack::input_precision),
        .thresholdBitwidth (cmp_gpack::thresh_precision)
    ) ccmp_i (
        .codes(buffered_estimated_bit),
        .codes_delay(buffered_estimated_bit_delay),
        .bit_level(bit_level),
        .sym_out   (tmp_cmp_out),
        .bit_out_delay(cmp_out_delay)
    );


    //Bits Pipeline
    logic  cmp_out_buffer  [constant_gpack::channel_width-1:0][1:0];
    logic [delay_width+width_width-1:0]    cmp_out_buffer_delay [1:0];
    buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (1),
        .depth       (1)
    ) cmp_out_buff_i (
        .in      (cmp_out),
        .in_delay(cmp_out_delay),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (cmp_out_buffer),
        .buffer_delay(cmp_out_buffer_delay)
    );

    logic flat_cmp_out_bits [constant_gpack::channel_width*2-1:0];
    logic [delay_width+width_width-1:0]    flat_cmp_out_bits_delay;
    flatten_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .depth (1)
    ) cmp_out_fb_i (
        .buffer    (cmp_out_buffer),
        .buffer_delay(cmp_out_buffer_delay),
        .flat_buffer(flat_cmp_out_bits),
        .flat_buffer_delay(flat_cmp_out_bits_delay)
    );

    bit_aligner #(
        .width (constant_gpack::channel_width),
        .depth(2)
    ) b_algn_i (
        .bit_segment(flat_cmp_out_bits),
        .bit_segment_delay(flat_cmp_out_bits_delay),
        .align_pos(align_pos),
        .aligned_bits(slcd_bits_out),
        .aligned_bits_delay(slcd_bits_out_delay)
    );


endmodule // bits_estimator_datapath
`default_nettype wire
