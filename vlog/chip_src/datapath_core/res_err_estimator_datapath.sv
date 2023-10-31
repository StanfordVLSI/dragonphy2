`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

module res_err_estimator_datapath #(
    parameter integer channel_pipeline_depth      = 0,
    parameter integer sym_bitwidth = 2,
    parameter integer error_output_pipeline_depth = 0,
    parameter integer main_cursor_position        = 2,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
    input logic clk,
    input logic rstb,

    input logic signed [(2**sym_bitwidth-1)-1:0]               symbols_in [constant_gpack::channel_width-1:0],
    input logic signed [constant_gpack::code_precision-1:0]    act_codes_in [constant_gpack::channel_width-1:0],

    output logic signed [error_gpack::est_error_precision-1:0] res_err_out  [constant_gpack::channel_width-1:0],
    output logic signed [(2**sym_bitwidth-1)-1:0]              symbols_out [constant_gpack::channel_width-1:0],

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
    logic signed [(2**sym_bitwidth-1)-1:0]              symbols_buffer  [constant_gpack::channel_width-1:0][bits_pipeline_depth:0];
    logic signed [constant_gpack::code_precision-1:0]   act_codes_buffer    [constant_gpack::channel_width-1:0][code_pipeline_depth:0];
    logic signed [error_gpack::est_error_precision-1:0] est_error_buffer    [constant_gpack::channel_width-1:0][error_pipeline_depth:0];

    generate
        for(gi = 0; gi < constant_gpack::channel_width; gi += 1) begin
            assign res_err_out[gi]   = est_error_buffer[gi][error_pipeline_depth];
            assign symbols_out[gi]    = symbols_buffer[gi][bits_pipeline_end];
        end
    endgenerate

    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    ((2**sym_bitwidth-1)),
        .depth       (bits_pipeline_depth)
    ) sliced_bits_buff_i (
        .in      (symbols_in),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (symbols_buffer)
    );

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

    logic signed [(2**sym_bitwidth-1)-1:0] flat_symbols [total_channel_bit_depth-1:0];

    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   ((2**sym_bitwidth-1)),
        .buff_depth (bits_pipeline_depth),
        .slice_depth(2),
        .start      (0)
    ) sb_fb_i (
        .buffer    (symbols_buffer),
        .flat_slice(flat_symbols)
    );


    //Channel Filter
    logic signed [channel_gpack::est_code_precision-1:0] estimated_codes [constant_gpack::channel_width-1:0];
    logic signed [(2**sym_bitwidth-1)-1:0] section_of_flat_symbols [actual_channel_bit_depth:0];

    generate
        for(gi = 0; gi < actual_channel_bit_depth+1; gi += 1) begin
            assign section_of_flat_symbols[gi] = flat_symbols[gi + total_channel_bit_depth-1-actual_channel_bit_depth];
        end
    endgenerate

    channel_filter #(
        .sym_bitwidth(sym_bitwidth),
        .width(constant_gpack::channel_width),
        .depth(channel_gpack::est_channel_depth),
        .shift_bitwidth(channel_gpack::shift_precision),
        .est_channel_bitwidth(channel_gpack::est_channel_precision),
        .est_code_bitwidth(channel_gpack::est_code_precision)
    ) chan_filt_i (
        .symstream(section_of_flat_symbols),
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
    logic signed [constant_gpack::code_precision-1:0]   end_buffer_est_codes[constant_gpack::channel_width-1:0];

    always_comb begin
        for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            end_buffer_adc_codes[ii] = act_codes_buffer[ii][code_pipeline_depth];
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

endmodule // res_err_estimator_datapath