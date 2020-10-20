`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

module datapath_core #(
    parameter integer ffe_pipeline_depth=0,
    parameter integer channel_pipeline_depth=0,
    parameter integer error_output_pipeline_depth=0,
    parameter integer sliding_detector_output_pipeline_depth=0
) (
    input logic signed [constant_gpack::code_precision-1:0] adc_codes [constant_gpack::channel_width-1:0],

    input logic clk,
    input logic rstb,

    output logic signed [ffe_gpack::output_precision-1:0]   estimated_bits_out [constant_gpack::channel_width-1:0],
    output logic                                               sliced_bits_out [constant_gpack::channel_width-1:0],
    output logic signed [constant_gpack::code_precision-1:0]   est_codes_out [constant_gpack::channel_width-1:0],
    output logic signed [error_gpack::est_error_precision-1:0] est_errors_out [constant_gpack::channel_width-1:0],
    output logic        [1:0] sd_flags [constant_gpack::channel_width-1:0],

    dsp_debug_intf.dsp dsp_dbg_intf_i //Stand in for Debug Interface
);
    integer ii, jj;
    genvar gi;

    localparam integer sliding_detector_input_pipeline_depth = 1;
    localparam integer error_pipeline_depth = `MAX(sliding_detector_input_pipeline_depth, sliding_detector_output_pipeline_depth) + error_output_pipeline_depth + 1;
    localparam integer error_code_pipeline_depth = 1+ffe_pipeline_depth + channel_pipeline_depth;
    
    localparam integer ffe_code_pipeline_depth = 1;
    localparam integer ffe_code_start          = 0;

    localparam integer channel_bits_pipeline_depth = 2;
    localparam integer channel_bits_start      = 0;

    localparam integer ffe_exit_depth   = ffe_pipeline_depth; // This is unnecessary but it is useful to understanding
    localparam integer chan_exit_depth  = channel_pipeline_depth;
    localparam integer bits_exit_depth  = channel_pipeline_depth
                                        + error_output_pipeline_depth
                                        + sliding_detector_output_pipeline_depth+1;
    localparam integer error_exit_depth = error_output_pipeline_depth
                                        + sliding_detector_output_pipeline_depth+1;

    localparam integer bits_pipeline_depth          = `MAX(channel_bits_pipeline_depth, 
                                                           `MAX(sliding_detector_input_pipeline_depth,
                                                                sliding_detector_output_pipeline_depth
                                                           ) 
                                                           + error_output_pipeline_depth
                                                           + channel_pipeline_depth
                                                    )
                                                    +1;

    localparam integer code_pipeline_depth          = `MAX(error_code_pipeline_depth, 1+ffe_code_pipeline_depth);


    localparam integer sliding_detector_error_start = error_output_pipeline_depth;
    localparam integer sliding_detector_bit_start   = channel_pipeline_depth + error_output_pipeline_depth;

    logic signed [constant_gpack::code_precision-1:0] adc_codes_buffer    [constant_gpack::channel_width-1:0][code_pipeline_depth:0];
    logic                                             sliced_bits_buffer  [constant_gpack::channel_width-1:0][bits_pipeline_depth:0];
    logic signed [error_gpack::est_error_precision-1:0] est_error_buffer [constant_gpack::channel_width-1:0][error_pipeline_depth:0];


    logic signed [ffe_gpack::weight_precision-1:0] weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0];
    logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0];
    logic signed [cmp_gpack::thresh_precision-1:0] thresh  [constant_gpack::channel_width-1:0];
    logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0];
    logic [channel_gpack::shift_precision-1:0] channel_shift [constant_gpack::channel_width-1:0];
    logic  disable_product [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0];
    logic signed [ffe_gpack::output_precision-1:0] buffered_estimated_bit [constant_gpack::channel_width-1:0];
    logic signed [channel_gpack::est_code_precision-1:0]   end_buffer_est_codes[constant_gpack::channel_width-1:0];
    logic [1:0] argmin_mmse_buffer [constant_gpack::channel_width-1:0][sliding_detector_output_pipeline_depth:0];

    always_comb begin
        integer ii, jj;
        for(ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
                thresh[ii]     <= dsp_dbg_intf_i.thresh[ii];
                ffe_shift[ii]  <= dsp_dbg_intf_i.ffe_shift[ii];
                channel_shift[ii] <= dsp_dbg_intf_i.channel_shift[ii];

                for(jj=0; jj<channel_gpack::est_channel_depth; jj=jj+1) begin
                    channel_est[ii][jj] <= dsp_dbg_intf_i.channel_est[ii][jj];
                end

                for(jj=0; jj<ffe_gpack::length; jj=jj+1) begin
                    weights[jj][ii] <= dsp_dbg_intf_i.weights[ii][jj];
                    disable_product[jj][ii] <= dsp_dbg_intf_i.disable_product[jj][ii]; //Packed to Unpacked Conversion I think requires this
                end
            end
    end

    generate 
        for(gi = 0; gi < constant_gpack::channel_width; gi = gi + 1) begin
            assign estimated_bits_out[gi]   = estimated_bits[gi];
            assign est_codes_out[gi]   = end_buffer_est_codes[gi];
            //The following assignments are aligned
            assign est_errors_out[gi]  = est_error_buffer[gi][error_exit_depth];
            assign sliced_bits_out[gi] = sliced_bits_buffer[gi][bits_exit_depth];
            assign sd_flags[gi]        = argmin_mmse_buffer[gi][sliding_detector_output_pipeline_depth];
        end
    endgenerate
    
    //ADC Codes Pipeline
    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (constant_gpack::code_precision),
        .depth       (code_pipeline_depth)
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
        .depth       (bits_pipeline_depth)
    ) sliced_bits_buff_i (
        .in      (sliced_bits),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (sliced_bits_buffer)
    );

    //FFE
    logic signed [constant_gpack::code_precision-1:0] flat_adc_codes [constant_gpack::channel_width*(1+ffe_code_pipeline_depth)-1:0];
    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (constant_gpack::code_precision),
        .buff_depth (code_pipeline_depth),
        .slice_depth(ffe_code_pipeline_depth),
        .start      (ffe_code_start)
    ) adc_codes_fb_i (
        .buffer    (adc_codes_buffer),
        .flat_slice(flat_adc_codes)
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
        .flat_codes    (flat_adc_codes),
        .disable_product(disable_product),
        .shift_index   (ffe_shift),
        .estimated_bits(estimated_bits)
    );

    //FFE pipeline
    logic signed [ffe_gpack::output_precision-1:0] estimated_bits_buffer [constant_gpack::channel_width-1:0][ffe_pipeline_depth:0];
    
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (ffe_gpack::output_precision),
        .depth      (ffe_pipeline_depth)
    ) ffe_reg_i (
        .in (estimated_bits),
        .clk(clk),
        .rstb(rstb),
        .buffer(estimated_bits_buffer)
    );

    generate
        for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
            assign buffered_estimated_bit[gi] = estimated_bits_buffer[gi][ffe_pipeline_depth];
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
        .bit_out   (cmp_out)
    );

    //Bits Pipeline
    logic   cmp_out_buffer  [constant_gpack::channel_width-1:0][1:0];

    buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (1),
        .depth       (1)
    ) cmp_out_buff_i (
        .in      (cmp_out),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (cmp_out_buffer)
    );

    logic flat_cmp_out_bits [constant_gpack::channel_width*2-1:0];
    flatten_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .depth (1)
    ) cmp_out_fb_i (
        .buffer    (cmp_out_buffer),
        .flat_buffer(flat_cmp_out_bits)
    );

    bit_aligner #(
        .width (constant_gpack::channel_width),
        .depth(2)
    ) b_algn_i (
        .bit_segment(flat_cmp_out_bits),
        .align_pos(dsp_dbg_intf_i.align_pos),
        .aligned_bits(sliced_bits)
    );

    localparam total_channel_bit_depth = constant_gpack::channel_width*(1+channel_bits_pipeline_depth);
    localparam actual_channel_bit_depth = constant_gpack::channel_width + channel_gpack::est_channel_depth - 2;

    logic flat_sliced_bits [total_channel_bit_depth-1:0];
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
        .bitstream(flat_sliced_bits[total_channel_bit_depth-1:total_channel_bit_depth-1 - actual_channel_bit_depth]),
        .channel(channel_est),
        .shift(channel_shift),
        .est_code(estimated_codes)
    );

    //Channel pipeline
    logic signed [channel_gpack::est_code_precision-1:0] estimated_codes_buffer [constant_gpack::channel_width-1:0][channel_pipeline_depth:0];
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (channel_gpack::est_code_precision),
        .depth      (channel_pipeline_depth)
    ) chan_reg_i (
        .in (estimated_codes),
        .clk(clk),
        .rstb(rstb),
        .buffer(estimated_codes_buffer)
    );

    //Create Error by subtracting codes from channel filter
    logic signed [error_gpack::est_error_precision-1:0] est_error [constant_gpack::channel_width-1:0];
    logic signed [constant_gpack::code_precision-1:0]   end_buffer_adc_codes[constant_gpack::channel_width-1:0];

    always_comb begin
        for(ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            end_buffer_adc_codes[ii] = adc_codes_buffer[ii][error_code_pipeline_depth];
            end_buffer_est_codes[ii] = estimated_codes_buffer[ii][channel_pipeline_depth];
            est_error[ii] = end_buffer_est_codes[ii] - end_buffer_adc_codes[ii];
        end
    end

    //Error pipeline
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .depth      (error_pipeline_depth)
    ) error_reg_i (
        .in (est_error),
        .clk(clk),
        .rstb(rstb),
        .buffer(est_error_buffer)
    );

    //Flatten and slice bitstreams and errstreams
    logic signed [error_gpack::est_error_precision-1:0] sd_flat_errors [constant_gpack::channel_width*(1+sliding_detector_input_pipeline_depth) - 1:0];
    logic sd_flat_sliced_bits [constant_gpack::channel_width*(1+sliding_detector_input_pipeline_depth) - 1:0];

    signed_flatten_buffer_slice #(
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
        .depth(channel_gpack::est_channel_depth),
        .est_error_bitwidth(detector_gpack::est_error_precision),
        .est_channel_bitwidth(detector_gpack::est_channel_precision),
        .sliding_detector_depth(sliding_detector_input_pipeline_depth+1)
    ) sld_dtct_i (
        .errstream(sd_flat_errors),
        .bitstream(sd_flat_sliced_bits),
        .channel(channel_est),
        .sqr_inj_error(),
        .mmse_err_pos(argmin_mmse)
    );

    //Detector pipeline
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (2),
        .depth      (sliding_detector_output_pipeline_depth)
    ) argmin_reg_i (
        .in (argmin_mmse),
        .clk(clk),
        .rstb(rstb),
        .buffer(argmin_mmse_buffer)
    );

endmodule : datapath_core
