interface dsp_debug_intf import const_pack::*; ();

    logic signed [ffe_gpack::weight_precision-1:0] weights [constant_gpack::channel_width-1:0][ffe_gpack::length-1:0];
    logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0];
    logic signed [cmp_gpack::thresh_precision-1:0] thresh  [constant_gpack::channel_width-1:0];
    logic signed [channel_gpack::est_estimate_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0];
    logic [channel_gpack::shift_precision-1:0] channel_shift [constant_gpack::channel_width-1:0];
    logic [constant_gpack::channel_width-1:0] disable_product [ffe_gpack::length-1:0];


    modport dsp (
        input weights,
        input ffe_shift,
        input thresh,
        input channel_est,
        input channel_shift,
        input disable_product
    );

endinterface : dsp_debug_intf