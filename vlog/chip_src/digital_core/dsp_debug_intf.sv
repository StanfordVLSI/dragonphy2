interface dsp_debug_intf ();

    logic signed [ffe_gpack::weight_precision-1:0] weights [constant_gpack::channel_width-1:0][ffe_gpack::length-1:0];
    logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0];
    logic signed [ffe_gpack::output_precision-1:0] bit_level;
    logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0];
    logic [channel_gpack::shift_precision-1:0] channel_shift [constant_gpack::channel_width-1:0];
    logic [constant_gpack::channel_width-1:0] disable_product [ffe_gpack::length-1:0];
    logic [$clog2(constant_gpack::channel_width)-1:0] align_pos;

    modport dsp (
        input weights,
        input ffe_shift,
        input bit_level,
        input channel_est,
        input channel_shift,
        input disable_product,
        input align_pos
    );

endinterface : dsp_debug_intf