module test ();

    datapath_core #(.ffe_pipeline_depth(1), .channel_pipeline_depth(1), .additional_error_pipeline_depth(0), .sliding_detector_output_pipeline_depth(1)) dp_core_i ();

endmodule : test
