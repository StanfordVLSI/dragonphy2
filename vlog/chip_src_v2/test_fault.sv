module test ();
    logic signed [ffe_gpack::weight_precision-1:0] ffe_weights [ffe_gpack::length-1:0],
    logic signed [channel_gpack::est_channel_precision-1:0] channel_est [channel_gpack::est_channel_depth-1:0],
    logic signed [constant_gpack::code_precision-1:0] adc_codes [constant_gpack::channel_width-1:0],

    logic clk,
    logic rstb


    dsp_debug_intf dsp_dbg_intf_i();
    datapath_core #(
        .ffe_pipeline_depth(1), 
        .channel_pipeline_depth(1), 
        .additional_error_pipeline_depth(0), 
        .sliding_detector_output_pipeline_depth(1)
    ) dp_core_i (
        .adc_codes(adc_codes),
        .clk(clk),
        .rstb(rstb),
        .dsp_dbg_intf_i(dsp_dbg_intf_i)
    );


    genvar gi, gj;
    generate
        for(gi = 0; gi < constant_gpack::channel_width; gi = gi + 1) begin
            assign dsp_dbg_intf_i.ffe_shift[gi] = 0;
            assign dsp_dbg_intf_i.thresh[gi] = 0;

            assign dsp_dbg_intf_i.channel_est[gi][0] = 1;
            for(gj = 1; gj < channel_gpack::est_channel_depth; gj = gj + 1) begin
                assign dsp_dbg_intf_i.channel_est[gi][gj] = channel_est[gj];
            end
            assign dsp_dbg_intf_i.channel_shift[gi] = 0;
            for(gj = 0; gj < ffe_gpack::length; gj = gj + 1 ) begin
                assign dsp_dbg_intf_i.disable_product[gj][gi] = 0;
                assign dsp_dbg_intf_i.weights[gi][gj] = ffe_weights[gj];
            end
        end
    endgenerate
endmodule : test



