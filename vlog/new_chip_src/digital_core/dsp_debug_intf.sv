interface dsp_debug_intf import const_pack::*; ();

    logic signed [ffe_gpack::weight_precision-1:0] weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0];
    logic signed [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0];
    logic signed [cmp_gpack::thresh_precision-1:0] thresh  [constant_gpack::channel_width-1:0];
    logic signed [mlsd_gpack::estimate_precision-1:0] channel_est [constant_gpack::channel_width-1:0][mlsd_gpack::estimate_depth-1:0];
    logic signed [mlsd_gpack::shift_precision-1:0] mlsd_shift [constant_gpack::channel_width-1:0];   

    modport dsp (
        input weights,
        input ffe_shift,
        input thresh,
        input channel_est,
        input mlsd_shift

    );

    modport weight_controller (
        output weights,
        output channel_est
    );

    modport jtag (
        output ffe_shift,
        output thresh,
        output mlsd_shift
    );


endinterface : dsp_debug_intf