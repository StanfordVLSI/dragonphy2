interface dsp_debug_intf import const_pack::*; ();
    
    logic signed [ffe_gpack::weight_precision-1:0] new_weights [constant_gpack::channel_width-1:0];
    logic signed [ffe_gpack::shift_precision-1:0] new_ffe_shift [constant_gpack::channel_width-1:0]
    logic signed [cmp_gpack::thresh_precision-1:0] new_thresh  [constant_gpack::channel_width-1:0];
    logic signed [mlsd_gpack::estimate_precision-1:0] new_channel_est [constant_gpack::channel_width-1:0][mlsd_gpack::estimate_depth-1:0];
    logic signed [mlsd_gpack::shift_precision-1:0] new_mlsd_shift [constant_gpack::channel_width-1:0];   

    logic update_weights[constant_gpack::channel_width-1:0];
    logic update_ffe_shift [constant_gpack::channel_width-1:0];
    logic update_thresh[constant_gpack::channel_width-1:0];
    logic update_channel_est [constant_gpack::channel_width-1:0][mlsd_gpack::estimate_depth-1:0];
    logic update_mlsd_shift[constant_gpack::channel_width-1:0];


    modport dsp (
        input new_weights,
        input new_ffe_shift,
        input new_thresh,
        input new_channel_est,
        input new_mlsd_shift,

        input update_weights,
        input update_ffe_shift,
        input update_thresh,
        input update_channel_est,
        input update_mlsd_shift
    );

    modport weight_controller (
        output new_weights,
        output new_channel_est,

        output update_weights,
        output update_channel_est
    );

    modport jtag (
        output new_ffe_shift,
        output new_thresh,
        output new_mlsd_shift,

        output update_ffe_shift,
        output update_thresh,
        output update_mlsd_shift
    );


endinterface : dsp_debug_intf