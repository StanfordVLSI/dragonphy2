`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)
`default_nettype none

module datapath_core #(
        parameter integer delay_width=4,
        parameter integer width_width=4
)(
    input wire logic signed [constant_gpack::code_precision-1:0] adc_codes [constant_gpack::channel_width-1:0],

    input wire logic clk,
    input wire logic rstb,

    //Stage 1
    output logic signed [ffe_gpack::output_precision-1:0]      stage1_est_bits_out    [constant_gpack::channel_width-1:0],
    output logic                                               stage1_sliced_bits_out [constant_gpack::channel_width-1:0],
    output logic signed [constant_gpack::code_precision-1:0]   stage1_act_codes_out [constant_gpack::channel_width-1:0],

    output logic        [delay_width+width_width-1:0]          stage1_est_bits_out_delay       ,
    output logic        [delay_width+width_width-1:0]          stage1_sliced_bits_out_delay        ,
    //Stage 2
    output logic signed [error_gpack::est_error_precision-1:0] stage2_res_errors_out  [constant_gpack::channel_width-1:0],
    output logic                                               stage2_sliced_bits_out [constant_gpack::channel_width-1:0],
    output logic        [delay_width+width_width-1:0]          stage2_res_errors_out_delay         ,
    output logic        [delay_width+width_width-1:0]          stage2_sliced_bits_out_delay        ,
    // Stage 3
    output logic        [error_gpack::ener_bitwidth-1:0]       stage3_sd_flags_ener   [constant_gpack::channel_width-1:0],
    output logic        [2:0]                                  stage3_sd_flags        [constant_gpack::channel_width-1:0],
    output logic        [delay_width+width_width-1:0]          stage3_sd_flags_ener_delay      ,
    output logic        [delay_width+width_width-1:0]          stage3_sd_flags_delay       ,
    // Stage 4
    output logic                                               stage4_sliced_bits_out [constant_gpack::channel_width-1:0],
    output logic signed [error_gpack::est_error_precision-1:0] stage4_res_errors_out  [constant_gpack::channel_width-1:0],
    output logic        [delay_width+width_width-1:0]          stage4_sliced_bits_out_delay        ,
    output logic        [delay_width+width_width-1:0]          stage4_res_errors_out_delay         ,
    // Stage 5
    output logic        [error_gpack::ener_bitwidth-1:0]       stage5_sd_flags_ener   [constant_gpack::channel_width-1:0],
    output logic        [1:0]                                  stage5_sd_flags        [constant_gpack::channel_width-1:0],
    output logic        [delay_width+width_width-1:0]          stage5_sd_flags_ener_delay      ,
    output logic        [delay_width+width_width-1:0]          stage5_sd_flags_delay       ,
    // Stage 6
    output logic                                               stage6_sliced_bits_out [constant_gpack::channel_width-1:0],
    output logic signed [error_gpack::est_error_precision-1:0] stage6_res_errors_out  [constant_gpack::channel_width-1:0],
    output logic        [delay_width+width_width-1:0]          stage6_sliced_bits_out_delay        ,
    output logic        [delay_width+width_width-1:0]          stage6_res_errors_out_delay         ,
    // Stage 7
    output logic        [error_gpack::ener_bitwidth-1:0]       stage7_sd_flags_ener   [constant_gpack::channel_width-1:0],
    output logic        [0:0]                                  stage7_sd_flags        [constant_gpack::channel_width-1:0],
    output logic        [delay_width+width_width-1:0]          stage7_sd_flags_ener_delay      ,
    output logic        [delay_width+width_width-1:0]          stage7_sd_flags_delay       ,
    // Stage 8
    output logic                                               stage8_sliced_bits_out [constant_gpack::channel_width-1:0],
    output logic signed [error_gpack::est_error_precision-1:0] stage8_res_errors_out  [constant_gpack::channel_width-1:0],
    output logic        [delay_width+width_width-1:0]          stage8_sliced_bits_out_delay        ,
    output logic        [delay_width+width_width-1:0]          stage8_res_errors_out_delay         ,
    //Aligned Outputs
    output logic signed [error_gpack::est_error_precision-1:0] stage8_aligned_stage2_res_errors_out  [constant_gpack::channel_width-1:0],
    output logic                                               stage8_aligned_stage2_sliced_bits_out [constant_gpack::channel_width-1:0],
    output logic        [1:0]                                  stage8_aligned_stage5_sd_flags        [constant_gpack::channel_width-1:0],

    output logic        [delay_width+width_width-1:0]          stage8_aligned_stage2_res_errors_out_delay      ,
    output logic        [delay_width+width_width-1:0]          stage8_aligned_stage2_sliced_bits_out_delay         ,
    output logic        [delay_width+width_width-1:0]          stage8_aligned_stage5_sd_flags_delay       , 

    dsp_debug_intf.dsp dsp_dbg_intf_i //Stand in for Debug Interface
);
    
    // synthesis translate_off
    //always_ff @(posedge clk) begin
    //    $display("stage1_est_bits_out:    %p",stage1_est_bits_out);
    //    $display("stage1_sliced_bits_out: %p",stage1_sliced_bits_out);
    //    $display("stage2_res_errors_out:  %p",stage2_res_errors_out);
    //    $display("stage2_sliced_bits_out: %p",stage2_sliced_bits_out);
    //    $display("stage3_sd_flags_ener:   %p",stage3_sd_flags_ener);
    //    $display("stage3_sd_flags:        %p",stage3_sd_flags);
    //    $display("stage4_sliced_bits_out: %p",stage4_sliced_bits_out);
    //    $display("stage4_res_errors_out:  %p",stage4_res_errors_out);
    //    $display("stage5_sd_flags_ener:   %p",stage5_sd_flags_ener);
    //    $display("stage5_sd_flags:        %p",stage5_sd_flags);
    //    $display("stage6_sliced_bits_out: %p",stage6_sliced_bits_out);
    //    $display("stage6_res_errors_out:  %p",stage6_res_errors_out);
    //    $display("stage8_sliced_bits_out: %p",stage8_sliced_bits_out);
    //    $display("stage8_res_errors_out:  %p",stage8_res_errors_out);
    //    $display("stage8_aligned_stage2_res_errors_out: %p",stage8_aligned_stage2_res_errors_out);
    //    $display("stage8_aligned_stage2_sliced_bits_out:  %p",stage8_aligned_stage2_sliced_bits_out);
    //    $display("stage8_aligned_stage5_sd_flags: %p",stage8_aligned_stage5_sd_flags);
//
    //    $display("stage1_est_bits_out_delay:    %p",stage1_est_bits_out_delay);
    //    $display("stage1_sliced_bits_out_delay: %p",stage1_sliced_bits_out_delay);
    //    $display("stage1_act_codes_out_delay:   %p",stage1_act_codes_out_delay);
    //    $display("stage2_res_errors_out_delay:  %p",stage2_res_errors_out_delay);
    //    $display("stage2_sliced_bits_out_delay: %p",stage2_sliced_bits_out_delay);
    //    $display("stage3_sd_flags_ener_delay:   %p",stage3_sd_flags_ener_delay);
    //    $display("stage3_sd_flags_delay:        %p",stage3_sd_flags_delay);
    //    $display("stage4_sliced_bits_out_delay: %p",stage4_sliced_bits_out_delay);
    //    $display("stage4_res_errors_out_delay:  %p",stage4_res_errors_out_delay);
    //    $display("stage5_sd_flags_ener_delay:   %p",stage5_sd_flags_ener_delay);
    //    $display("stage5_sd_flags_delay:        %p",stage5_sd_flags_delay);
    //    $display("stage6_sliced_bits_out_delay: %p",stage6_sliced_bits_out_delay);
    //    $display("stage6_res_errors_out_delay:  %p",stage6_res_errors_out_delay);
    //    $display("stage8_sliced_bits_out_delay: %p",stage8_sliced_bits_out_delay);
    //    $display("stage8_res_errors_out_delay:  %p",stage8_res_errors_out_delay);
    //    $display("stage8_aligned_stage2_res_errors_out_delay: %p",stage8_aligned_stage2_res_errors_out_delay);
    //    $display("stage8_aligned_stage2_sliced_bits_out_delay:  %p",stage8_aligned_stage2_sliced_bits_out_delay);
    //    $display("stage8_aligned_stage5_sd_flags_delay: %p",stage8_aligned_stage5_sd_flags_delay);
    //end
    // synthesis translate_on

    parameter integer stage1_depth = `MAX(1, constant_gpack::stage1_ffe_pipeline_depth + 1);
    parameter integer stage2_depth = stage1_depth + constant_gpack::stage2_chan_pipeline_depth  + constant_gpack::stage2_err_out_pipeline_depth;
    parameter integer stage3_depth = stage2_depth + constant_gpack::stage3_sld_dtct_out_pipeline_depth;
    parameter integer stage4_depth = stage3_depth + 1+constant_gpack::stage4_fp_bits_out_pipeline_depth+constant_gpack::stage4_err_chan_out_pipeline_depth + constant_gpack::stage4_res_err_out_pipeline_depth;
    parameter integer stage5_depth = stage4_depth + constant_gpack::stage5_sld_dtct_out_pipeline_depth;
    parameter integer stage6_depth = stage5_depth + 1+constant_gpack::stage6_fp_bits_out_pipeline_depth+constant_gpack::stage6_err_chan_out_pipeline_depth + constant_gpack::stage6_res_err_out_pipeline_depth;
    parameter integer stage7_depth = stage6_depth + constant_gpack::stage5_sld_dtct_out_pipeline_depth;
    parameter integer stage8_depth = stage7_depth + 1+constant_gpack::stage6_fp_bits_out_pipeline_depth+constant_gpack::stage6_err_chan_out_pipeline_depth + constant_gpack::stage6_res_err_out_pipeline_depth;

    parameter integer total_depth  = stage6_depth;

    logic                                                   stage2_sliced_bits_buffer  [constant_gpack::channel_width-1:0][stage8_depth-stage2_depth+2:0];
    logic signed [error_gpack::est_error_precision-1:0]     stage2_res_error_buffer    [constant_gpack::channel_width-1:0][stage8_depth-stage2_depth+2:0];
    logic        [1:0]                                      stage5_sd_flags_buffer     [constant_gpack::channel_width-1:0][stage8_depth-stage5_depth+2:0];

    logic        [delay_width+width_width-1:0]              stage2_sliced_bits_buffer_delay  [stage8_depth-stage2_depth+2:0];
    logic        [delay_width+width_width-1:0]              stage2_res_error_buffer_delay    [stage8_depth-stage2_depth+2:0];
    logic        [delay_width+width_width-1:0]              stage5_sd_flags_buffer_delay     [stage8_depth-stage5_depth+2:0];

    buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (1),
        .depth       (stage8_depth-stage2_depth+2)
    ) s2_sliced_bits_buff_i (
        .in      (stage2_sliced_bits_out),
        .in_delay(stage2_sliced_bits_out_delay),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (stage2_sliced_bits_buffer),
        .buffer_delay(stage2_sliced_bits_buffer_delay)
    );

    //ADC Codes Pipeline
    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (error_gpack::est_error_precision),
        .depth       (stage8_depth-stage2_depth+2)
    ) s2_res_err_buff_i (
        .in      (stage2_res_errors_out),
        .in_delay(stage2_res_errors_out_delay),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (stage2_res_error_buffer),
        .buffer_delay(stage2_res_error_buffer_delay)
    );

    buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (2),
        .depth       (stage8_depth-stage5_depth+2)
    ) s5_flags_buff_i (
        .in      (stage5_sd_flags),
        .in_delay(stage5_sd_flags_delay),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (stage5_sd_flags_buffer),
        .buffer_delay(stage5_sd_flags_buffer_delay)
    );


    always_comb begin
        for(int ii = 0; ii < constant_gpack::channel_width; ii += 1) begin
            stage8_aligned_stage2_res_errors_out[ii]    = stage2_res_error_buffer[ii][stage8_depth-stage2_depth-1];
            stage8_aligned_stage2_sliced_bits_out[ii]   = stage2_sliced_bits_buffer[ii][stage8_depth-stage2_depth-1];
            stage8_aligned_stage5_sd_flags[ii]          = stage5_sd_flags_buffer[ii][stage8_depth-stage5_depth-1];
        end
        // synthesis translate_off
        stage8_aligned_stage2_res_errors_out_delay    = stage2_res_error_buffer_delay[stage8_depth-stage2_depth-1];
        stage8_aligned_stage2_sliced_bits_out_delay   = stage2_sliced_bits_buffer_delay[stage8_depth-stage2_depth-1];
        stage8_aligned_stage5_sd_flags_delay          = stage5_sd_flags_buffer_delay[stage8_depth-stage5_depth-1];
        // synthesis translate_on
    end

    wire logic signed [ffe_gpack::weight_precision-1:0] weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0];
    wire logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0];
    wire logic signed [cmp_gpack::thresh_precision-1:0] thresh  [constant_gpack::channel_width-1:0];
    wire logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0];
    wire logic [channel_gpack::shift_precision-1:0] channel_shift [constant_gpack::channel_width-1:0];
    wire logic  disable_product [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0];
    wire logic [$clog2(constant_gpack::channel_width)-1:0] align_pos;

    simplify_dsp_dbg_intf simp_dsp_i (
        //Input 
        .dsp_dbg_intf_i(dsp_dbg_intf_i),
        //Output
        .align_pos(align_pos),
        .weights(weights),
        .ffe_shift(ffe_shift),
        .thresh(thresh),
        .channel_est(channel_est),
        .channel_shift(channel_shift),
        .disable_product(disable_product)
    );

    logic [delay_width+width_width-1:0] stage1_act_codes_out_delay;
    bits_estimator_datapath  #(
        .ffe_pipeline_depth(constant_gpack::stage1_ffe_pipeline_depth)
    )bit_est_stage_1_i(
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .act_codes_in(adc_codes),
        .act_codes_in_delay(8'd0),
        // Outputs
        .est_bits_out(stage1_est_bits_out),    
        .slcd_bits_out(stage1_sliced_bits_out),
        .act_codes_out(stage1_act_codes_out),

        .est_bits_out_delay(stage1_est_bits_out_delay),    
        .slcd_bits_out_delay(stage1_sliced_bits_out_delay),
        .act_codes_out_delay(stage1_act_codes_out_delay),


        // JTAG Registers
        .weights(weights),
        .ffe_shift(ffe_shift),
        .thresh(thresh),
        .disable_product(disable_product),
        .align_pos(align_pos)
    );

    res_err_estimator_datapath  #(
        .channel_pipeline_depth(constant_gpack::stage2_chan_pipeline_depth),
        .error_output_pipeline_depth(constant_gpack::stage2_err_out_pipeline_depth),
        .main_cursor_position(2)
    ) res_err_stage_2_i (
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .slcd_bits_in(stage1_sliced_bits_out),
        .act_codes_in(stage1_act_codes_out), 

        .slcd_bits_in_delay(stage1_sliced_bits_out_delay),
        .act_codes_in_delay(stage1_act_codes_out_delay),         
        // Outputs
        .slcd_bits_out(stage2_sliced_bits_out),
        .res_err_out(stage2_res_errors_out),

        .slcd_bits_out_delay(stage2_sliced_bits_out_delay),
        .res_err_out_delay(stage2_res_errors_out_delay),
        // JTAG Registers
        .channel_est(channel_est),
        .channel_shift(channel_shift)
    );

    logic                                               stage3_sliced_bits_out [constant_gpack::channel_width-1:0];
    logic signed [error_gpack::est_error_precision-1:0] stage3_res_errors_out  [constant_gpack::channel_width-1:0];

    logic [delay_width+width_width-1:0] stage3_sliced_bits_out_delay;
    logic [delay_width+width_width-1:0] stage3_res_errors_out_delay ;

    error_checker_datapath  #(
        .seq_length(4),
        .num_of_flip_patterns(5),
        .flip_pattern_depth(4),
        .flip_patterns('{'{1,1,1,1},'{0,1,1,1},'{0,1,0,1},'{0,0,1,1}, '{0,0,1,0}}),
        .sliding_detector_output_pipeline_depth(constant_gpack::stage3_sld_dtct_out_pipeline_depth)
    )err_chk_stage_3_i (
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .sliced_bits_in(stage2_sliced_bits_out),
        .res_errors_in(stage2_res_errors_out),

        .sliced_bits_in_delay(stage2_sliced_bits_out_delay),
        .res_errors_in_delay(stage2_res_errors_out_delay),

        // Outputs
        .sd_flags(stage3_sd_flags),       
        .sd_flags_ener(stage3_sd_flags_ener),
        .sliced_bits_out(stage3_sliced_bits_out),
        .res_errors_out(stage3_res_errors_out),

        .sd_flags_delay(stage3_sd_flags_delay),       
        .sd_flags_ener_delay(stage3_sd_flags_ener_delay),
        .sliced_bits_out_delay(stage3_sliced_bits_out_delay),
        .res_errors_out_delay(stage3_res_errors_out_delay),

        //JTAG Registers
        .channel_est(channel_est),
        .channel_shift(channel_shift)
    );

    error_corrector_datapath  #(
        .seq_length                      (4), 
        .num_of_flip_patterns(5),
        .flip_pattern_depth(4),
        .flip_patterns('{'{1,1,1,1},'{0,1,1,1},'{0,1,0,1},'{0,0,1,1}, '{0,0,1,0}}),
        .flip_bits_output_pipeline_depth(constant_gpack::stage4_fp_bits_out_pipeline_depth),
        .main_cursor_position(2),
        .error_channel_pipeline_depth(constant_gpack::stage4_err_chan_out_pipeline_depth),
        .residual_error_output_pipeline_depth(constant_gpack::stage4_res_err_out_pipeline_depth)
    ) err_corr_stage_4_i(
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .sd_flags(stage3_sd_flags),        
        .sd_flags_ener(stage3_sd_flags_ener),  
        .sliced_bits_in(stage3_sliced_bits_out),   
        .res_errors_in(stage3_res_errors_out),

        .sd_flags_delay(stage3_sd_flags_delay),        
        .sd_flags_ener_delay(stage3_sd_flags_ener_delay),  
        .sliced_bits_in_delay(stage3_sliced_bits_out_delay),   
        .res_errors_in_delay(stage3_res_errors_out_delay),
        // Outputs
        .sliced_bits_out(stage4_sliced_bits_out),  
        .res_errors_out(stage4_res_errors_out),

        .sliced_bits_out_delay(stage4_sliced_bits_out_delay),  
        .res_errors_out_delay(stage4_res_errors_out_delay),
        //JTAG Registers
        .channel_est(channel_est),
        .channel_shift(channel_shift)
    );

    logic                                               stage5_sliced_bits_out [constant_gpack::channel_width-1:0];
    logic signed [error_gpack::est_error_precision-1:0] stage5_res_errors_out  [constant_gpack::channel_width-1:0];

    logic [delay_width+width_width-1:0] stage5_sliced_bits_out_delay;
    logic [delay_width+width_width-1:0] stage5_res_errors_out_delay;
    error_checker_datapath  #(
        .seq_length(3),
        .num_of_flip_patterns(2),
        .flip_pattern_depth(3),
        .flip_patterns('{'{0,1,1}, '{0,1,0}}),
        .sliding_detector_output_pipeline_depth(constant_gpack::stage5_sld_dtct_out_pipeline_depth)
    )err_chk_stage_5_i (
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .sliced_bits_in(stage4_sliced_bits_out),
        .res_errors_in(stage4_res_errors_out),

        .sliced_bits_in_delay(stage4_sliced_bits_out_delay),
        .res_errors_in_delay(stage4_res_errors_out_delay),

        // Outputs
        .sd_flags(stage5_sd_flags),       
        .sd_flags_ener(stage5_sd_flags_ener),
        .sliced_bits_out(stage5_sliced_bits_out),
        .res_errors_out(stage5_res_errors_out),

        .sd_flags_delay(stage5_sd_flags_delay),       
        .sd_flags_ener_delay(stage5_sd_flags_ener_delay),
        .sliced_bits_out_delay(stage5_sliced_bits_out_delay),
        .res_errors_out_delay(stage5_res_errors_out_delay),
        //JTAG Registers
        .channel_est(channel_est),
        .channel_shift(channel_shift)
    );

    error_corrector_datapath  #(
        .seq_length                          (3),
        .num_of_flip_patterns(2),
        .flip_pattern_depth(3),
        .flip_patterns('{'{0,1,1}, '{0,1,0}}),
        .flip_bits_output_pipeline_depth(constant_gpack::stage6_fp_bits_out_pipeline_depth),
        .main_cursor_position(2),
        .error_channel_pipeline_depth(constant_gpack::stage6_err_chan_out_pipeline_depth),
        .residual_error_output_pipeline_depth(constant_gpack::stage6_res_err_out_pipeline_depth)
    ) err_corr_stage_6_i (
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .sd_flags(stage5_sd_flags),        
        .sd_flags_ener(stage5_sd_flags_ener),  
        .sliced_bits_in(stage5_sliced_bits_out),   
        .res_errors_in(stage5_res_errors_out),

        .sd_flags_delay(stage5_sd_flags_delay),        
        .sd_flags_ener_delay(stage5_sd_flags_ener_delay),  
        .sliced_bits_in_delay(stage5_sliced_bits_out_delay),   
        .res_errors_in_delay(stage5_res_errors_out_delay),
        // Outputs
        .sliced_bits_out(stage6_sliced_bits_out),  
        .res_errors_out(stage6_res_errors_out),

        .sliced_bits_out_delay(stage6_sliced_bits_out_delay),  
        .res_errors_out_delay(stage6_res_errors_out_delay),
        //JTAG Registers
        .channel_est(channel_est),
        .channel_shift(channel_shift)
    );
    logic                                               stage7_sliced_bits_out [constant_gpack::channel_width-1:0];
    logic signed [error_gpack::est_error_precision-1:0] stage7_res_errors_out  [constant_gpack::channel_width-1:0];
    logic [delay_width+width_width-1:0] stage7_sliced_bits_out_delay;
    logic [delay_width+width_width-1:0] stage7_res_errors_out_delay;
    error_checker_datapath  #( 
        .seq_length(3),
        .num_of_flip_patterns(1),
        .flip_pattern_depth(3),
        .flip_patterns('{'{0,1,0}}),
        .sliding_detector_output_pipeline_depth(constant_gpack::stage5_sld_dtct_out_pipeline_depth)
    )err_chk_stage_7_i (
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .sliced_bits_in(stage6_sliced_bits_out),
        .res_errors_in(stage6_res_errors_out),

        .sliced_bits_in_delay(stage6_sliced_bits_out_delay),
        .res_errors_in_delay(stage6_res_errors_out_delay),

        // Outputs
        .sd_flags(stage7_sd_flags),       
        .sd_flags_ener(stage7_sd_flags_ener),
        .sliced_bits_out(stage7_sliced_bits_out),
        .res_errors_out(stage7_res_errors_out),

        .sd_flags_delay(stage7_sd_flags_delay),       
        .sd_flags_ener_delay(stage7_sd_flags_ener_delay),
        .sliced_bits_out_delay(stage7_sliced_bits_out_delay),
        .res_errors_out_delay(stage7_res_errors_out_delay),
        //JTAG Registers
        .channel_est(channel_est),
        .channel_shift(channel_shift)
    );

    error_corrector_datapath  #(
        .seq_length                          (3),
        .num_of_flip_patterns(1),
        .flip_pattern_depth(3),
        .flip_patterns('{'{0,1,0}}),
        .flip_bits_output_pipeline_depth(constant_gpack::stage6_fp_bits_out_pipeline_depth),
        .main_cursor_position(2),
        .error_channel_pipeline_depth(constant_gpack::stage6_err_chan_out_pipeline_depth),
        .residual_error_output_pipeline_depth(constant_gpack::stage6_res_err_out_pipeline_depth)
    ) err_corr_stage_8_i (
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .sd_flags(stage7_sd_flags),        
        .sd_flags_ener(stage7_sd_flags_ener),  
        .sliced_bits_in(stage7_sliced_bits_out),   
        .res_errors_in(stage7_res_errors_out),

        .sd_flags_delay(stage7_sd_flags_delay),        
        .sd_flags_ener_delay(stage7_sd_flags_ener_delay),  
        .sliced_bits_in_delay(stage7_sliced_bits_out_delay),   
        .res_errors_in_delay(stage7_res_errors_out_delay),
        // Outputs
        .sliced_bits_out(stage8_sliced_bits_out),  
        .res_errors_out(stage8_res_errors_out),

        .sliced_bits_out_delay(stage8_sliced_bits_out_delay),  
        .res_errors_out_delay(stage8_res_errors_out_delay),
        //JTAG Registers
        .channel_est(channel_est),
        .channel_shift(channel_shift)
    );

endmodule : datapath_core
`default_nettype wire
