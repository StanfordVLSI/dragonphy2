interface dsp_debug_intf ();

    logic signed [ffe_gpack::weight_precision-1:0] weights [constant_gpack::channel_width-1:0][ffe_gpack::length-1:0];
    logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0];
    logic signed [ffe_gpack::output_precision-1:0] slice_levels [2:0];
    logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0];
    logic [channel_gpack::shift_precision-1:0] channel_shift [constant_gpack::channel_width-1:0];
    logic [$clog2(constant_gpack::channel_width)-1:0] align_pos;
    logic signed [detector_gpack::branch_bitwidth-1:0]                                      trellis_patterns       [detector_gpack::num_of_trellis_patterns-1:0][detector_gpack::trellis_pattern_depth-1:0];


    modport dsp (
        input weights,
        input ffe_shift,
        input slice_levels,
        input channel_est,
        input channel_shift,
        input align_pos,
        input trellis_patterns
    );

endinterface : dsp_debug_intf