`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

module error_checker_datapath #(
    parameter integer seq_length = 3,
    parameter integer sym_bitwidth = 2,
    parameter integer num_of_trellis_patterns = 4,
    parameter integer trellis_pattern_depth = 4,
    parameter integer sliding_detector_output_pipeline_depth = 0,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
    input logic clk,
    input logic rstb,


    input logic  [sym_bitwidth-1:0]                              symbols_in         [constant_gpack::channel_width-1:0],
    input logic signed [error_gpack::est_error_precision-1:0]    res_errors_in          [constant_gpack::channel_width-1:0],
    input logic [delay_width+width_width-1:0] sliced_bits_in_delay,
    input logic [delay_width+width_width-1:0] res_errors_in_delay,

    output logic        [error_gpack::ener_bitwidth-1:0]          sd_flags_ener          [constant_gpack::channel_width-1:0],
    output logic signed [error_gpack::est_error_precision-1:0]    res_errors_out         [constant_gpack::channel_width-1:0],
    output logic        [$clog2(2*num_of_trellis_patterns+1)-1:0]      sd_flags               [constant_gpack::channel_width-1:0],
    output logic  [sym_bitwidth-1:0]                              symbols_out        [constant_gpack::channel_width-1:0],

    output logic [delay_width+width_width-1:0] sd_flags_ener_delay,
    output logic [delay_width+width_width-1:0] res_errors_out_delay,
    output logic [delay_width+width_width-1:0] sd_flags_delay,
    output logic [delay_width+width_width-1:0] sliced_bits_out_delay,

    input logic signed [channel_gpack::est_channel_precision-1:0] channel_est            [channel_gpack::est_channel_depth-1:0],
    input logic        [channel_gpack::shift_precision-1:0]       channel_shift          ,
    input logic signed [1:0]                                      trellis_patterns       [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0]
);
    genvar gi;

    localparam integer flag_width = $clog2(2*num_of_trellis_patterns+1);

    localparam integer total_depth         = sliding_detector_output_pipeline_depth;

    localparam integer bits_pipeline_depth = sliding_detector_output_pipeline_depth;
    localparam integer bits_pipeline_end   = sliding_detector_output_pipeline_depth;

    localparam integer error_pipeline_depth = `MAX(1, sliding_detector_output_pipeline_depth);
    localparam integer error_pipeline_end   = sliding_detector_output_pipeline_depth;

    logic signed [error_gpack::est_error_precision-1:0]  res_error_buffer   [constant_gpack::channel_width-1:0][error_pipeline_depth:0]; 
    logic  [sym_bitwidth-1:0]                                              symbol_buffer [constant_gpack::channel_width-1:0][bits_pipeline_depth:0]; 
    logic [delay_width+width_width-1:0]                  res_error_buffer_delay[error_pipeline_depth:0];
    logic [delay_width+width_width-1:0]                  sliced_bits_buffer_delay[bits_pipeline_depth:0];

    logic [error_gpack::ener_bitwidth-1:0] mmse_vals_buffer          [constant_gpack::channel_width-1:0][sliding_detector_output_pipeline_depth:0];
    logic [flag_width-1:0]                 argmin_mmse_buffer        [constant_gpack::channel_width-1:0][sliding_detector_output_pipeline_depth:0];
    logic [delay_width+width_width-1:0]                  mmse_vals_buffer_delay[sliding_detector_output_pipeline_depth:0];
    logic [delay_width+width_width-1:0]                  argmin_mmse_buffer_delay[sliding_detector_output_pipeline_depth:0];

    //Flatten and slice bitstreams and errstreams
    // synthesis translate_off
    assign res_errors_out_delay   = res_error_buffer_delay[error_pipeline_end];
    assign sliced_bits_out_delay = sliced_bits_buffer_delay[bits_pipeline_end];
    // synthesis translate_on
    generate
        for(gi = 0; gi < constant_gpack::channel_width; gi += 1) begin
            assign res_errors_out[gi]   = res_error_buffer[gi][error_pipeline_end];
            assign symbols_out[gi] = symbol_buffer[gi][bits_pipeline_end];
        end
    endgenerate

    /*// synthesis translate_off
    always_ff @(posedge clk) begin
        $display("%m.res_errors_out_delay:     %p",res_errors_out_delay);
        $display("%m.sliced_bits_in_delay:    %p",sliced_bits_in_delay);
        $display("%m.sliced_bits_out_delay:    %p",sliced_bits_out_delay);
        $display("%m.sliced_bits_buffer_delay:    %p",sliced_bits_buffer_delay);
        $display("%m.sd_flags_delay:           %p",sd_flags_delay);
        $display("%m.argmin_mmse_buffer_delay: %p",argmin_mmse_buffer_delay);
        $display("%m.sd_flags_ener_delay:      %p",sd_flags_ener_delay);
        $display("%m.mmse_vals_buffer_delay:   %p",mmse_vals_buffer_delay);
    end
    // synthesis translate_on*/

    buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (sym_bitwidth),
        .depth       (bits_pipeline_depth)
    ) sliced_bits_buff_i (
        .in      (symbols_in),
        .in_delay(sliced_bits_in_delay),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (symbol_buffer),
        .buffer_delay(sliced_bits_buffer_delay)
    );

    //ADC Codes Pipeline
    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (error_gpack::est_error_precision),
        .depth       (error_pipeline_depth)
    ) res_err_buff_i (
        .in      (res_errors_in),
        .in_delay(res_errors_in_delay),
        .clk     (clk),
        .rstb    (rstb),
        .buffer(res_error_buffer),
        .buffer_delay(res_error_buffer_delay)
    );



    logic signed [error_gpack::est_error_precision-1:0] sd_flat_errors [constant_gpack::channel_width*2 - 1:0];
    logic [delay_width+width_width-1:0] sd_flat_errors_delay;
    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .buff_depth (error_pipeline_depth),
        .slice_depth(1),
        .start      (0)
    ) res_err_fb_i (
        .buffer    (res_error_buffer),
        .buffer_delay(res_error_buffer_delay),
        .flat_slice(sd_flat_errors),
        .flat_slice_delay(sd_flat_errors_delay)
    );

    //Trellis Neighbor Checker
    logic [flag_width-1:0] argmin_mmse [constant_gpack::channel_width-1:0];
    logic [error_gpack::ener_bitwidth-1:0] mmse_vals [constant_gpack::channel_width-1:0];

    logic [delay_width+width_width-1:0] argmin_mmse_delay;
    logic [delay_width+width_width-1:0] mmse_vals_delay;

    always @(posedge clk) begin
        test_pack::array_io#(logic signed [error_gpack::est_error_precision-1:0], 32)::write_array(sd_flat_errors);
    end

    trellis_neighbor_checker #(
        .est_channel_bitwidth(detector_gpack::est_channel_precision),
        .depth(channel_gpack::est_channel_depth),
        .width(constant_gpack::channel_width),
        .branch_bitwidth(2),
        .trellis_neighbor_checker_depth(2),
        .num_of_trellis_patterns(num_of_trellis_patterns),
        .trellis_pattern_depth(trellis_pattern_depth),
        .seq_length(seq_length),
        .ener_bitwidth(error_gpack::ener_bitwidth),
        .est_err_bitwidth(detector_gpack::est_error_precision)
    ) tnc_i (
        .channel(channel_est),
        .channel_shift(channel_shift),
        .trellis_patterns(trellis_patterns),
        .nrz_mode(0),
        .errstream(sd_flat_errors),
        .flag_eners(mmse_vals),
        .flags(argmin_mmse)
    );


    //Detector Pipelines
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::ener_bitwidth),
        .depth      (sliding_detector_output_pipeline_depth)
    ) mmse_reg_i (
        .in (mmse_vals),
        .in_delay(mmse_vals_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(mmse_vals_buffer),
        .buffer_delay(mmse_vals_buffer_delay)
    );


    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (flag_width),
        .depth      (sliding_detector_output_pipeline_depth)
    ) argmin_reg_i (
        .in (argmin_mmse),
        .in_delay(argmin_mmse_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(argmin_mmse_buffer),
        .buffer_delay(argmin_mmse_buffer_delay)
    );

    always_comb begin
        for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            sd_flags[ii]      = argmin_mmse_buffer[ii][sliding_detector_output_pipeline_depth];
            sd_flags_ener[ii] = mmse_vals_buffer[ii][sliding_detector_output_pipeline_depth];
        end
        // synthesis translate_off
        sd_flags_delay      = argmin_mmse_buffer_delay[sliding_detector_output_pipeline_depth];
        sd_flags_ener_delay = mmse_vals_buffer_delay[sliding_detector_output_pipeline_depth];
        // synthesis translate_on
    end

endmodule // error_checker_datapath