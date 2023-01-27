`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

module symbol_adjust_reflector_datapath #(
    parameter integer error_channel_pipeline_depth = 0,
    parameter integer sym_bitwidth=2,
    parameter integer residual_error_output_pipeline_depth = 0,
    parameter integer main_cursor_position = 2
) (
    input logic clk,
    input logic rstb,

    input logic signed [sym_bitwidth-1:0]                      symbol_adjust_in  [constant_gpack::channel_width-1:0],
    input logic        [sym_bitwidth-1:0]                      symbols_in  [constant_gpack::channel_width-1:0],
    input logic signed [error_gpack::est_error_precision-1:0]  res_errors_in   [constant_gpack::channel_width-1:0],

    output logic       [sym_bitwidth-1:0]                      symbols_out  [constant_gpack::channel_width-1:0],
    output logic signed [error_gpack::est_error_precision-1:0] res_errors_out   [constant_gpack::channel_width-1:0],
    
    input logic signed [channel_gpack::est_channel_precision-1:0] channel_est            [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0],
    input logic        [channel_gpack::shift_precision-1:0]       channel_shift          [constant_gpack::channel_width-1:0]
); 
    genvar gi;

    localparam integer symbols_buffer_depth           = 2;
    localparam integer symbol_adjust_buffer_depth     = 2;
    localparam integer corrected_symbols_buffer_depth = error_channel_pipeline_depth + residual_error_output_pipeline_depth; 
    localparam integer rse_buffer_depth               = error_channel_pipeline_depth;

    logic signed  [sym_bitwidth-1:0]                    symbol_adjust_buffer     [constant_gpack::channel_width-1:0][symbol_adjust_buffer_depth:0];
    logic         [sym_bitwidth-1:0]                    symbols_buffer           [constant_gpack::channel_width-1:0][symbols_buffer_depth:0];
    logic signed [error_gpack::est_error_precision-1:0] rse_buffer               [constant_gpack::channel_width-1:0][rse_buffer_depth:0];

    logic         [sym_bitwidth-1:0]                    corrected_symbols_buffer [constant_gpack::channel_width-1:0][corrected_symbols_buffer_depth:0];


    logic signed [error_gpack::est_error_precision-1:0] inj_err_buffer           [constant_gpack::channel_width-1:0][error_channel_pipeline_depth:0];
    logic signed [error_gpack::est_error_precision-1:0] new_est_error_buffer     [constant_gpack::channel_width-1:0][residual_error_output_pipeline_depth:0];

    generate
        for(gi =0; gi < constant_gpack::channel_width; gi += 1) begin
            assign res_errors_out[gi]  = new_est_error_buffer[gi][residual_error_output_pipeline_depth];
            assign symbols_out[gi] = corrected_symbols_buffer[gi][corrected_symbols_buffer_depth];
        end
    endgenerate

    logic signed      [constant_gpack::sym_bitwidth:0]                    signed_corrected_symbols      [constant_gpack::channel_width-1:0];
    logic             [constant_gpack::sym_bitwidth-1:0]                  corrected_symbols            [constant_gpack::channel_width-1:0];



    //Update residual error trace
    always_comb begin
        for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            signed_corrected_symbols[ii] = symbol_adjust_in[ii] + $signed(symbols_in[ii]);
            corrected_symbols[ii] = $unsigned(signed_corrected_symbols[ii][sym_bitwidth-1:0]);
        end
    end

    //Detector pipeline
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (sym_bitwidth),
        .depth      (symbol_adjust_buffer_depth)
    )symbol_adjust_reg_i  (
        .in (symbol_adjust_in),
        .clk(clk),
        .rstb(rstb),
        .buffer(symbol_adjust_buffer)
    );

    //Detector pipeline
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (sym_bitwidth),
        .depth      (corrected_symbols_buffer_depth)
    ) corr_symbols_reg_i (
        .in (corrected_symbols),
        .clk(clk),
        .rstb(rstb),
        .buffer(corrected_symbols_buffer)
    );


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
    ) est_error_reg_i (
        .in (res_errors_in),
        .clk(clk),
        .rstb(rstb),
        .buffer(rse_buffer)
    );


    logic [sym_bitwidth-1:0] flat_symbols [constant_gpack::channel_width*3-1:0];

    flatten_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (sym_bitwidth),
        .depth (2)
    ) flag_out_fb_i (
        .buffer    (symbols_buffer),
        .flat_buffer(flat_symbols)
    );

    logic signed [sym_bitwidth-1:0] flat_symbol_adjust [constant_gpack::channel_width*3-1:0];
    signed_flatten_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (sym_bitwidth),
        .depth (2)
    ) flag_ener_out_fb_i (
        .buffer    (symbol_adjust_buffer),
        .flat_buffer(flat_symbol_adjust)
    );

    logic signed [error_gpack::est_error_precision-1:0] inj_error [constant_gpack::channel_width-1:0];


    localparam total_bit_depth = constant_gpack::channel_width*3;
    localparam actual_bit_depth = constant_gpack::channel_width + channel_gpack::est_channel_depth - main_cursor_position; // This minus two is covertly performing a bit alignment!

    //error channel filter
    symbol_adjust_channel_filter #(
        .width(constant_gpack::channel_width),
        .depth(channel_gpack::est_channel_depth),
        .sym_bitwidth(sym_bitwidth),
        .shift_bitwidth(channel_gpack::shift_precision),
        .est_channel_bitwidth(channel_gpack::est_channel_precision),
        .est_code_bitwidth(error_gpack::est_error_precision)
    ) err_chan_filt_i (
        .flpstream(flat_symbol_adjust[total_bit_depth-1:total_bit_depth-1-actual_bit_depth]),
        
        .channel(channel_est),
        .shift(channel_shift),
        .error_out(inj_error)
    );

    // Pipeline Stage
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .depth      (error_channel_pipeline_depth)
    ) ase_reg_i (
        .in (inj_error),
        .clk(clk),
        .rstb(rstb),
        .buffer(inj_err_buffer)
    );

    logic signed [error_gpack::est_error_precision-1:0] rflt_est_error [constant_gpack::channel_width-1:0];
    logic signed [error_gpack::est_error_precision-1:0] end_buffer_inj_error [constant_gpack::channel_width-1:0];
    logic signed [error_gpack::est_error_precision-1:0] end_buffer_res_error [constant_gpack::channel_width-1:0];

    //Update residual error trace
    always_comb begin
        for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            end_buffer_inj_error[ii] = inj_err_buffer[ii][error_channel_pipeline_depth];
            end_buffer_res_error[ii] = rse_buffer[ii][rse_buffer_depth];
            rflt_est_error[ii]       = end_buffer_res_error[ii] + end_buffer_inj_error[ii];
        end
    end

    //Pipeline Stage
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .depth      (residual_error_output_pipeline_depth)
    ) see_reg_i (
        .in (rflt_est_error),
        .clk(clk),
        .rstb(rstb),
        .buffer(new_est_error_buffer)
    );

    endmodule : symbol_adjust_reflector_datapath