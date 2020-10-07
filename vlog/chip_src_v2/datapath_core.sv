module datapath_core #(
    parameter integer ffe_pipeline_depth=0,
    parameter integer channel_pipeline_depth=0,
    parameter integer additional_error_pipeline_depth=0,
    parameter integer sliding_detector_output_pipeline_depth=0
) (
    logic signed [constant_gpack::code_precision-1:0] adc_codes [constant_gpack::channel_width-1:0],

    input logic clk,
    input logic rstb,

    dsp_debug_intf.dsp dsp_dbg_intf_i //Stand in for Debug Interface
);
    integer ii, jj;
    genvar gi;

    localparam integer sliding_detector_input_pipeline_depth = 2;
    localparam integer error_pipeline_depth = sliding_detector_input_pipeline_depth+additional_error_pipeline_depth;

    localparam integer ffe_code_pipeline_depth = 2;
    localparam integer ffe_code_start          = 0;

    localparam integer channel_bits_pipeline_depth = 3;
    localparam integer channel_bits_start      = 0;

    localparam integer bits_pipeline_depth = channel_bits_pipeline_depth + channel_pipeline_depth + error_pipeline_depth + sliding_detector_input_pipeline_depth;
    localparam integer code_pipeline_depth = ffe_code_pipeline_depth + ffe_pipeline_depth + channel_bits_pipeline_depth + channel_pipeline_depth + sliding_detector_input_pipeline_depth;

    localparam integer sliding_detector_error_start = error_pipeline_depth - sliding_detector_input_pipeline_depth;
    localparam integer sliding_detector_bit_start   = bits_pipeline_depth - sliding_detector_input_pipeline_depth;

    logic signed [constant_gpack::code_precision-1:0] adc_codes_buffer    [constant_gpack::channel_width-1:0][code_pipeline_depth-1:0];
    logic                                             sliced_bits_buffer  [constant_gpack::channel_width-1:0][bits_pipeline_depth-1:0];


    //ADC Codes Pipeline
    buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (constant_gpack::code_precision),
        .depth       (code_pipeline_depth),
        .is_signed(1)
    ) adc_code_buff_i (
        .in      (adc_codes),
        .clk     (clk),
        .rstb    (rstb),
        .buffer(adc_codes_buffer)
    );


    //Bits Pipeline
    logic sliced_bits [constant_gpack::channel_width-1:0];
    buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (1),
        .depth       (bits_pipeline_depth),
        .is_signed(0)
    ) sliced_bits_buff_i (
        .in      (sliced_bits),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (sliced_bits_buffer)
    );

    //FFE
    logic signed [constant_gpack::code_precision-1:0] flat_adc_codes [constant_gpack::channel_width*ffe_code_pipeline_depth-1:0];
    flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (constant_gpack::code_precision),
        .buff_depth (code_pipeline_depth),
        .slice_depth(ffe_code_pipeline_depth),
        .start      (ffe_code_start)
    ) adc_codes_fb_i (
        .buffer    (adc_codes_buffer),
        .flat_slice(flat_adc_codes)
    );

    comb_ffe #(
        .codeBitwidth(ffe_gpack::input_precision),
        .weightBitwidth(ffe_gpack::weight_precision),
        .resultBitwidth(ffe_gpack::output_precision),
        .shiftBitwidth(ffe_gpack::shift_precision),
        .ffeDepth(ffe_gpack::length),
        .numChannels(constant_gpack::channel_width),
        .numBuffers    (ffe_code_pipeline_depth)
    ) cffe_i (
        .weights       (weights),
        .flat_codes    (flat_adc_codes),
        .disable_product(disable_product),
        .shift_index   (ffe_shift),
        .estimated_bits(estimated_bits)
    );

    //FFE pipeline
    logic signed [ffe_gpack::output_precision-1:0] estimated_bits_buffer [constant_gpack::channel_width-1:0][ffe_pipeline_depth-1:0];
    
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (ffe_gpack::output_precision),
        .depth      (ffe_pipeline_depth),
        .is_signed(1)
    ) ffe_reg_i (
        .in (estimated_bits),
        .clk(clk),
        .rstb(rstb),
        .buffer(estimated_bits_buffer)
    );

    logic signed [ffe_gpack::output_precision-1:0] buffered_estimated_bit [constant_gpack::channel_width-1:0];
    generate
        for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
            assign buffered_estimated_bit[gi] = estimated_bits_buffer[gi][ffe_pipeline_depth-1];
        end
    endgenerate

    //Slicer
    wire logic cmp_out [constant_gpack::channel_width-1:0];
    comb_comp #(
        .numChannels(cmp_gpack::width),
        .inputBitwidth(cmp_gpack::input_precision),
        .thresholdBitwidth (cmp_gpack::thresh_precision),
        .confidenceBitwidth(cmp_gpack::conf_precision)
    ) ccmp_i (
        .codes(buffered_estimated_bit),
        .thresh(thresh),
        .clk       (clk),
        .rstb      (rstb),
        .bit_out   (sliced_bits)
    );

    logic flat_sliced_bits [constant_gpack::channel_width*channel_bits_pipeline_depth-1:0];
    flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .buff_depth (bits_pipeline_depth),
        .slice_depth(channel_bits_pipeline_depth),
        .start      (channel_bits_start)
    ) sb_fb_i (
        .buffer    (sliced_bits_buffer),
        .flat_slice(flat_sliced_bits)
    );


    //Channel Filter
    logic signed [channel_gpack::est_code_precision-1:0] estimated_codes [constant_gpack::channel_width-1:0];
    channel_filter #(
        .width(constant_gpack::channel_width),
        .depth(channel_gpack::est_channel_depth),
        .shift_bitwidth(channel_gpack::shift_precision),
        .est_channel_bitwidth(channel_gpack::est_channel_precision),
        .est_code_bitwidth(channel_gpack::est_code_precision)
    ) chan_filt_i (
        .bitstream(flat_sliced_bits[(channel_gpack::est_channel_depth-1)+constant_gpack::channel_width-1:0]),
        .channel(channel),
        .shift(channel_shift),
        .est_code(estimated_codess)
    );

    //Channel pipeline
    logic signed [channel_gpack::est_code_precision-1:0] estimated_codes_buffer [constant_gpack::channel_width-1:0][channel_pipeline_depth-1:0];
    
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (channel_gpack::est_code_precision),
        .depth      (channel_pipeline_depth),
        .is_signed(1)
    ) chan_reg_i (
        .in (estimated_codes),
        .clk(clk),
        .rstb(rstb),
        .buffer(estimated_codes_buffer)
    );

    //Create Error by subtracting codes from channel filter
    logic signed [error_gpack::est_error_precision-1:0] est_error [constant_gpack::channel_width-1:0];

    always_comb begin
        for(ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            est_error[ii] = estimated_codes[ii][channel_pipeline_depth-1] - adc_codes[ii][code_pipeline_depth-1];
        end
    end

    //Error pipeline
    logic signed [error_gpack::est_error_precision-1:0] est_error_buffer [constant_gpack::channel_width-1:0][error_pipeline_depth-1:0];
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .depth      (error_pipeline_depth),
        .is_signed(1)
    ) error_reg_i (
        .in (est_error),
        .clk(clk),
        .rstb(rstb),
        .buffer(est_error_buffer)
    );

    //Flatten and slice bitstreams and errstreams
    logic signed [error_gpack::est_error_precision-1:0] sd_flat_errors [constant_gpack::channel_width*sliding_detector_input_pipeline_depth-1:0];
    logic sd_flat_sliced_bits [constant_gpack::channel_width*sliding_detector_input_pipeline_depth-1:0];

    flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .buff_depth (error_pipeline_depth),
        .slice_depth(sliding_detector_input_pipeline_depth),
        .start      (sliding_detector_error_start)
    ) sd_error_fb_i (
        .buffer    (est_error_buffer),
        .flat_slice(sd_flat_errors)
    );

    flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .buff_depth (bits_pipeline_depth),
        .slice_depth(sliding_detector_input_pipeline_depth),
        .start      (sliding_detector_bit_start)
    ) sd_sb_fb_i (
        .buffer    (sliced_bits_buffer),
        .flat_slice(sd_flat_sliced_bits)
    );

    //Sliding Detector
    logic [1:0] argmin_mmse [constant_gpack::channel_width-1:0];
    sliding_detector #(
        .seq_length(detector_gpack::seq_length),
        .width(constant_gpack::channel_width),
        .est_error_bitwidth(detector_gpack::est_error_precision),
        .est_channel_bitwidth(detector_gpack::est_channel_bitwidth),
        .sliding_detector_depth(sliding_detector_input_pipeline_depth)
    ) sld_dtct_i (
        .errstream(sd_flat_errors),
        .bitstream(sd_flat_sliced_bits),
        .channel(channel[detector_gpack::seq_length-1:0]),
        .sqr_inj_error(),
        .mmse_err_pos(argmin_mmse)
    );

    //Detector pipeline
    logic [1:0] argmin_mmse_buffer [constant_gpack::channel_width-1:0][sliding_detector_output_pipeline_depth-1:0];
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (2),
        .depth      (sliding_detector_output_pipeline_depth),
        .is_signed(1)
    ) argmin_reg_i (
        .in (argmin_mmse),
        .clk(clk),
        .rstb(rstb),
        .buffer(argmin_mmse_buffer)
    );

endmodule : datapath_core