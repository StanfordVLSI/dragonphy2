`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

module flip_bit_reflector_datapath #(
    parameter integer error_channel_pipeline_depth = 0,
    parameter integer residual_error_output_pipeline_depth = 0,
    parameter integer main_cursor_position = 2,
    parameter integer num_of_flip_patterns = 4,
    parameter integer flip_pattern_depth   = 3,
    parameter integer flip_patterns[num_of_flip_patterns-1:0][flip_pattern_depth-1:0] = '{'{0,1,0}, '{0,1,1}, '{1,1,1},'{1,0,1}},
    parameter integer delay_width=4,
    parameter integer width_width=4
) (
    input logic clk,
    input logic rstb,

    input logic                                                flip_bits_in   [constant_gpack::channel_width-1:0],
    input logic                                                sliced_bits_in  [constant_gpack::channel_width-1:0],
    input logic signed [error_gpack::est_error_precision-1:0]  res_errors_in   [constant_gpack::channel_width-1:0],
    
    input logic [delay_width+width_width-1:0] flip_bits_in_delay,    
    input logic [delay_width+width_width-1:0] sliced_bits_in_delay,  
    input logic [delay_width+width_width-1:0] res_errors_in_delay,   

    output logic                                               sliced_bits_out  [constant_gpack::channel_width-1:0],
    output logic signed [error_gpack::est_error_precision-1:0] res_errors_out   [constant_gpack::channel_width-1:0],
    
    output logic [delay_width+width_width-1:0] sliced_bits_out_delay, 
    output logic [delay_width+width_width-1:0] res_errors_out_delay,  

    input logic signed [channel_gpack::est_channel_precision-1:0] channel_est            [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0],
    input logic        [channel_gpack::shift_precision-1:0]       channel_shift          [constant_gpack::channel_width-1:0]
); 
    genvar gi;

    localparam integer sliced_bits_buffer_depth = 2;
    localparam integer flip_bits_buffer_depth   = 2;
    localparam integer corrected_sliced_bits_buffer_depth = error_channel_pipeline_depth + residual_error_output_pipeline_depth; 
    localparam integer rse_buffer_depth                   = error_channel_pipeline_depth;

    logic                                               flip_bits_buffer             [constant_gpack::channel_width-1:0][flip_bits_buffer_depth:0];
    logic                                               sliced_bits_buffer           [constant_gpack::channel_width-1:0][sliced_bits_buffer_depth:0];
    logic signed [error_gpack::est_error_precision-1:0] rse_buffer               [constant_gpack::channel_width-1:0][rse_buffer_depth:0];

    logic                                               corrected_sliced_bits_buffer [constant_gpack::channel_width-1:0][corrected_sliced_bits_buffer_depth:0];


    logic signed [error_gpack::est_error_precision-1:0] inj_err_buffer           [constant_gpack::channel_width-1:0][error_channel_pipeline_depth:0];
    logic signed [error_gpack::est_error_precision-1:0] new_est_error_buffer     [constant_gpack::channel_width-1:0][residual_error_output_pipeline_depth:0];


    logic [delay_width + width_width -1 :0] flip_bits_buffer_delay [flip_bits_buffer_depth:0];
    logic [delay_width + width_width -1 :0] sliced_bits_buffer_delay [sliced_bits_buffer_depth:0];
    logic [delay_width + width_width -1 :0] rse_buffer_delay [rse_buffer_depth:0];
    logic [delay_width + width_width -1 :0] corrected_sliced_bits_buffer_delay [corrected_sliced_bits_buffer_depth:0];
    logic [delay_width + width_width -1 :0] inj_err_buffer_delay [error_channel_pipeline_depth:0];
    logic [delay_width + width_width -1 :0] new_est_error_buffer_delay [residual_error_output_pipeline_depth:0];

    generate
        for(gi =0; gi < constant_gpack::channel_width; gi += 1) begin
            assign res_errors_out[gi] =new_est_error_buffer[gi][residual_error_output_pipeline_depth];
            assign sliced_bits_out[gi] = corrected_sliced_bits_buffer[gi][corrected_sliced_bits_buffer_depth];
        end
    endgenerate
// synthesis translate_off
    assign res_errors_out_delay  = new_est_error_buffer_delay[residual_error_output_pipeline_depth];
    assign sliced_bits_out_delay = corrected_sliced_bits_buffer_delay[corrected_sliced_bits_buffer_depth];
// synthesis translate_on
    logic                                       corrected_bits            [constant_gpack::channel_width-1:0];
    logic    [delay_width+width_width-1:0]      corrected_bits_delay;

    /*    // synthesis translate_off

    always_ff @(posedge clk) begin
        $display("%m.flip_bits_in_delay: %p", flip_bits_in_delay); 
        $display("%m.sliced_bits_in_delay: %p", sliced_bits_in_delay   );
        $display("%m.res_errors_in_delay: %p", res_errors_in_delay   ); 

        $display("%m.sliced_bits_out_delay: %p", sliced_bits_out_delay   );
        $display("%m.res_errors_out_delay:  %p", res_errors_out_delay   );
        $display("%m.new_est_error_buffer_delay: %p", new_est_error_buffer_delay   );
        $display("%m.corrected_sliced_bits_buffer_delay:  %p", corrected_sliced_bits_buffer_delay   ); 
    end
    // synthesis translate_on*/


    //Update residual error trace
    always_comb begin
        for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            corrected_bits[ii] = flip_bits_in[ii] ^ sliced_bits_in[ii];
        end
        //assert (flip_bits_in_delay == sliced_bits_in_delay) else $error("Timing Mismatch Between %s: %d and %s: %d", "flip_bits_in_delay","sliced_bits_in_delay");
        // synthesis translate_off
        corrected_bits_delay = flip_bits_in_delay;
        // synthesis translate_on
    end

    //Detector pipeline
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .depth      (flip_bits_buffer_depth)
    )flip_bits_reg_i  (
        .in (flip_bits_in),
        .in_delay(flip_bits_in_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(flip_bits_buffer),
        .buffer_delay(flip_bits_buffer_delay)
    );

    //Detector pipeline
    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .depth      (corrected_sliced_bits_buffer_depth)
    ) corr_sliced_bits_reg_i (
        .in (corrected_bits),
        .in_delay(corrected_bits_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(corrected_sliced_bits_buffer),
        .buffer_delay(corrected_sliced_bits_buffer_delay)
    );


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
    ) est_error_reg_i (
        .in (res_errors_in),
        .in_delay(res_errors_in_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(rse_buffer),
        .buffer_delay(rse_buffer_delay)
    );


    logic flat_slcd_bits [constant_gpack::channel_width*3-1:0];
    logic [delay_width+width_width-1:0] flat_slcd_bits_delay;   

    flatten_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .depth (2)
    ) flag_out_fb_i (
        .buffer    (sliced_bits_buffer),
        .buffer_delay(sliced_bits_buffer_delay),
        .flat_buffer(flat_slcd_bits),
        .flat_buffer_delay(flat_slcd_bits_delay)
    );

    logic flat_flip_bits [constant_gpack::channel_width*3-1:0];
    logic [delay_width+width_width-1:0] flat_flip_bits_delay;   
    flatten_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .depth (2)
    ) flag_ener_out_fb_i (
        .buffer    (flip_bits_buffer),
        .buffer_delay(flip_bits_buffer_delay),
        .flat_buffer(flat_flip_bits),
        .flat_buffer_delay(flat_flip_bits_delay)
    );

    logic signed [error_gpack::est_error_precision-1:0] inj_error [constant_gpack::channel_width-1:0];
    logic [delay_width+width_width-1:0] inj_error_delay;


    localparam total_bit_depth = constant_gpack::channel_width*3;
    localparam actual_bit_depth = constant_gpack::channel_width + channel_gpack::est_channel_depth - main_cursor_position; // This minus two is covertly performing a bit alignment!

    //error channel filter
    error_channel_filter #(
        .width(constant_gpack::channel_width),
        .depth(channel_gpack::est_channel_depth),
        .shift_bitwidth(channel_gpack::shift_precision),
        .est_channel_bitwidth(channel_gpack::est_channel_precision),
        .est_code_bitwidth(error_gpack::est_error_precision)
    ) err_chan_filt_i (
        .bitstream(flat_slcd_bits[total_bit_depth-1:total_bit_depth-1-actual_bit_depth]),
        .bitstream_delay(flat_slcd_bits_delay),
        .flpstream(flat_flip_bits[total_bit_depth-1:total_bit_depth-1-actual_bit_depth]),
        .flpstream_delay(flat_flip_bits_delay),
        
        .channel(channel_est),
        .shift(channel_shift),
        .error_out(inj_error),
        .error_out_delay(inj_error_delay)
    );

    // Pipeline Stage
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .depth      (error_channel_pipeline_depth)
    ) ase_reg_i (
        .in (inj_error),
        .in_delay(inj_error_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(inj_err_buffer),
        .buffer_delay(inj_err_buffer_delay)
    );

    logic signed [error_gpack::est_error_precision-1:0] rflt_est_error [constant_gpack::channel_width-1:0];
    logic signed [error_gpack::est_error_precision-1:0] end_buffer_inj_error [constant_gpack::channel_width-1:0];
    logic signed [error_gpack::est_error_precision-1:0] end_buffer_res_error [constant_gpack::channel_width-1:0];

    logic [delay_width+width_width-1:0] rflt_est_error_delay;
    logic [delay_width+width_width-1:0] end_buffer_inj_error_delay;
    logic [delay_width+width_width-1:0] end_buffer_res_error_delay;

    //Update residual error trace
    always_comb begin
        for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            end_buffer_inj_error[ii] = inj_err_buffer[ii][error_channel_pipeline_depth];
            end_buffer_res_error[ii] = rse_buffer[ii][rse_buffer_depth];
            rflt_est_error[ii]       = end_buffer_res_error[ii] + end_buffer_inj_error[ii];
        end
        end_buffer_inj_error_delay = inj_err_buffer_delay[error_channel_pipeline_depth];
        end_buffer_res_error_delay = rse_buffer_delay[rse_buffer_depth];
        rflt_est_error_delay       = end_buffer_res_error_delay;
    end

    /*
    initial begin
        $monitor("%m.flat_scld_bits: %p", flat_slcd_bits);
        $monitor("%m.flat_flip_bits: %p", flat_flip_bits);
        $monitor("%m.inj_error: %p", inj_error);
        $monitor("%m.end_buffer_inj_error: %p", end_buffer_inj_error);
        $monitor("%m.end_buffer_res_error: %p", end_buffer_res_error);
        $monitor("%m.rflt_est_error: %p", rflt_est_error);
    end*/

    //Pipeline Stage
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .depth      (residual_error_output_pipeline_depth)
    ) see_reg_i (
        .in (rflt_est_error),
        .in_delay(rflt_est_error_delay),
        .clk(clk),
        .rstb(rstb),
        .buffer(new_est_error_buffer),
        .buffer_delay(new_est_error_buffer_delay)
    );

    endmodule // flip_bit_reflector_datapath