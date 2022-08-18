module testbench;

    localparam integer width = 16;
    localparam integer depth = 8;
    localparam integer bitwidth=8;

    logic clk, rstb;

    clock #(.period(1ns)) clk_gen (.clk(clk));

    logic signed [bitwidth-1:0] weights [depth-1:0];
    logic signed [bitwidth-1:0] init_weights [depth-1:0];

    logic signed [$clog2(depth)-1:0] cur_pos;
    logic signed [gainBitwidth-1:0] gain;
    logic signed [estBitwidth-1:0] target_level;

    logic signed [codeBitwidth-1:0] adc_codes [constant_gpack::channel_width-1:0],
    logic signed [estBitwidth-1:0]  est_bits  [3*constant_gpack::channel_width-1:0],
    logic signed [constant_gpack::code_precision-1:0] adc_codes_buffer    [constant_gpack::channel_width-1:0][code_pipeline_depth:0];
    logic                                             sliced_bits_buffer  [constant_gpack::channel_width-1:0][bits_pipeline_depth:0];


    logic signed [ffe_gpack::weight_precision-1:0] weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0];
    logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0];

    logic  disable_product [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0];

    logic signed [ffe_gpack::output_precision-1:0] estimated_bits [constant_gpack::channel_width-1:0];


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

    //FFE
    logic signed [constant_gpack::code_precision-1:0] flat_adc_codes [constant_gpack::channel_width*2-1:0];
    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (constant_gpack::code_precision),
        .buff_depth (1),
        .slice_depth(1),
        .start      (0)
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
        .numBuffers    (2),
        .t0_buff       (1)
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
        .depth      (3)
    ) ffe_reg_i (
        .in (estimated_bits),
        .clk(clk),
        .rstb(rstb),
        .buffer(estimated_bits_buffer)
    );

    logic signed [ffe_gpack::output_precision-1:0] flat_est_bits [constant_gpack::channel_width*(1+ffe_code_pipeline_depth)-1:0];
    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (ffe_gpack::output_precision),
        .buff_depth (3),
        .slice_depth(3),
        .start      (0)
    ) adc_codes_fb_i (
        .buffer    (estimated_bits_buffer),
        .flat_slice(flat_est_bits)
    );

    fir_adapter #(
        .codeBitwidth(bitwidth),
        .estBitwidth(estBitwidth),
        .weightBitwidth(weightBitwidth),
        .gainBitwidth(gainBitwidth),
        .ffeDepth(depth),
        .numChannels(width)
    ) fir_adapt_i (
        .clk(clk), 
        .rst_n(rstb), 
        .adc_codes(adc_codes_buffer[]), 
        .est_bits(est_bits), 
        .gain(0), 
        .target_level(256), 
        .cur_pos(7), 
        .weights(weights),
        .init_weights(),
        .load_init_weights()
    );

    initial begin
        
    end