`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

module res_err_estimator_datapath #(
    parameter integer channel_pipeline_depth      = 0,
    parameter integer error_output_pipeline_depth = 0,
    parameter integer main_cursor_position        = 2,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
    input logic clk,
    input logic rstb,

    input logic                                               slcd_bits_in [constant_gpack::channel_width-1:0],
    input logic signed [constant_gpack::code_precision-1:0]   act_codes_in [constant_gpack::channel_width-1:0],

    input logic [delay_width+width_width-1:0]                 slcd_bits_in_delay,
    input logic [delay_width+width_width-1:0]                 act_codes_in_delay,    

    output logic signed [error_gpack::est_error_precision-1:0] res_err_out  [constant_gpack::channel_width-1:0],
    output logic                                               slcd_bits_out [constant_gpack::channel_width-1:0],


    output logic [delay_width+width_width-1:0] res_err_out_delay ,
    output logic [delay_width+width_width-1:0] slcd_bits_out_delay,


    input logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0],
    input logic        [channel_gpack::shift_precision-1:0]       channel_shift [constant_gpack::channel_width-1:0]
);
    
    
    genvar gi;

    localparam integer total_depth = channel_pipeline_depth  + error_output_pipeline_depth;

    localparam integer bits_pipeline_depth  = `MAX(channel_pipeline_depth + error_output_pipeline_depth, 2);
    localparam integer bits_pipeline_end    =  channel_pipeline_depth  + error_output_pipeline_depth;

    localparam integer code_pipeline_depth  = `MAX(channel_pipeline_depth, 1);
    localparam integer error_pipeline_depth = error_output_pipeline_depth;

    localparam total_channel_bit_depth  = constant_gpack::channel_width*3;
    localparam actual_channel_bit_depth = constant_gpack::channel_width + channel_gpack::est_channel_depth - main_cursor_position; // This minus two is covertly performing a bit alignment!

    //Bits Pipeline
    logic                                               sliced_bits_buffer  [constant_gpack::channel_width-1:0][bits_pipeline_depth:0];
    logic signed [constant_gpack::code_precision-1:0]   act_codes_buffer    [constant_gpack::channel_width-1:0][code_pipeline_depth:0];
    logic signed [error_gpack::est_error_precision-1:0] est_error_buffer    [constant_gpack::channel_width-1:0][error_pipeline_depth:0];

    logic [delay_width+width_width-1:0]                 sliced_bits_buffer_delay  [bits_pipeline_depth:0];
    logic [delay_width+width_width-1:0]                 act_codes_buffer_delay    [code_pipeline_depth:0];
    logic [delay_width+width_width-1:0]                 est_error_buffer_delay    [error_pipeline_depth:0];
// synthesis translate_off
    assign res_err_out_delay = est_error_buffer_delay[error_pipeline_depth];
    assign slcd_bits_out_delay = sliced_bits_buffer_delay[bits_pipeline_end];
// synthesis translate_on
    generate
        for(gi = 0; gi < constant_gpack::channel_width; gi += 1) begin
            assign res_err_out[gi]   = est_error_buffer[gi][error_pipeline_depth];
            assign slcd_bits_out[gi] = sliced_bits_buffer[gi][bits_pipeline_end];
        end
    endgenerate

    buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (1),
        .depth       (bits_pipeline_depth),
        .delay_width(delay_width),
        .width_width(width_width)
    ) sliced_bits_buff_i (
        .in      (slcd_bits_in),
        .in_delay      (slcd_bits_in_delay),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (sliced_bits_buffer),
        .buffer_delay  (sliced_bits_buffer_delay)
    );

    //ADC Codes Pipeline
    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (constant_gpack::code_precision),
        .depth       (code_pipeline_depth),
        .delay_width(delay_width),
        .width_width(width_width)
    ) adc_code_buff_i (
        .in      (act_codes_in),
        .in_delay      (act_codes_in_delay),
        .clk     (clk),
        .rstb    (rstb),
        .buffer(act_codes_buffer),
        .buffer_delay(act_codes_buffer_delay)

    );

    logic flat_sliced_bits [total_channel_bit_depth-1:0];
    logic [delay_width+width_width-1:0] flat_sliced_bits_delay;

    flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .buff_depth (bits_pipeline_depth),
        .slice_depth(2),
        .start      (0),
        .delay_width(delay_width),
        .width_width(width_width)
    ) sb_fb_i (
        .buffer    (sliced_bits_buffer),
        .buffer_delay (sliced_bits_buffer_delay),
        .flat_slice(flat_sliced_bits),
        .flat_slice_delay(flat_sliced_bits_delay)
    );


    //Channel Filter
    logic signed [channel_gpack::est_code_precision-1:0] estimated_codes [constant_gpack::channel_width-1:0];
    logic [delay_width+width_width-1:0] estimated_codes_delay ;
    channel_filter #(
        .width(constant_gpack::channel_width),
        .depth(channel_gpack::est_channel_depth),
        .shift_bitwidth(channel_gpack::shift_precision),
        .est_channel_bitwidth(channel_gpack::est_channel_precision),
        .est_code_bitwidth(channel_gpack::est_code_precision),
        .delay_width(delay_width),
        .width_width(width_width)
    ) chan_filt_i (
        .bitstream(flat_sliced_bits[total_channel_bit_depth-1:total_channel_bit_depth-1 - actual_channel_bit_depth]),
        .bitstream_delay(flat_sliced_bits_delay),
        .channel(channel_est),
        .shift(channel_shift),
        .est_code(estimated_codes),
        .est_code_delay(estimated_codes_delay)
    );


    //Channel pipeline
    logic signed [channel_gpack::est_code_precision-1:0] estimated_codes_buffer [constant_gpack::channel_width-1:0][channel_pipeline_depth:0];
    logic [delay_width+width_width-1:0] estimated_codes_buffer_delay [channel_pipeline_depth:0];

    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (channel_gpack::est_code_precision),
        .depth      (channel_pipeline_depth),
        .delay_width(delay_width),
        .width_width(width_width)
    ) chan_reg_i (
        .in (estimated_codes),
        .in_delay(estimated_codes_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(estimated_codes_buffer),
        .buffer_delay(estimated_codes_buffer_delay)
    );

    //Create Error by subtracting codes from channel filter
    logic signed [error_gpack::est_error_precision-1:0] est_error [constant_gpack::channel_width-1:0];
    logic signed [constant_gpack::code_precision-1:0]   end_buffer_adc_codes[constant_gpack::channel_width-1:0];
    logic signed [constant_gpack::code_precision-1:0]   end_buffer_est_codes[constant_gpack::channel_width-1:0];

    logic [delay_width+width_width-1:0]   est_error_delay  ;
    logic [delay_width+width_width-1:0]   end_buffer_adc_codes_delay ;
    logic [delay_width+width_width-1:0]   end_buffer_est_codes_delay ;

    always_comb begin
        for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            end_buffer_adc_codes[ii] = act_codes_buffer[ii][code_pipeline_depth];
            end_buffer_est_codes[ii] = estimated_codes_buffer[ii][channel_pipeline_depth];
            est_error[ii] = end_buffer_est_codes[ii] - end_buffer_adc_codes[ii];
        end

        end_buffer_adc_codes_delay = act_codes_buffer_delay[code_pipeline_depth];
        end_buffer_est_codes_delay = estimated_codes_buffer_delay[channel_pipeline_depth];
        est_error_delay = end_buffer_adc_codes_delay;
    end


    // synthesis translate_off
    always_ff @(posedge clk) begin
        $display("###### end_buffer_adc_codes: %p", end_buffer_adc_codes);
    end
    // synthesis translate_on

    //Error pipeline
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .depth      (error_pipeline_depth),
        .delay_width(delay_width),
        .width_width(width_width)
    ) error_reg_i (
        .in (est_error),
        .in_delay(est_error_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(est_error_buffer),
        .buffer_delay(est_error_buffer_delay)
    );

endmodule // res_err_estimator_datapath