package dsp_pack;
    localparam integer ffe_code_numPb    = 1;//$ceil((ffe_gpack::length-1)*1.0/(constant_gpack::channel_width));

    localparam integer mlsd_bit_numPb    = 2;//$ceil((mlsd_gpack::estimate_depth-1)*1.0/constant_gpack::channel_width);
    localparam integer mlsd_bit_numFb    =  1;//$ceil((mlsd_gpack::length-1)*1.0/constant_gpack::channel_width);

    localparam integer mlsd_code_numPb   = 1;// $ceil((mlsd_gpack::length-1)*1.0/constant_gpack::channel_width);
endpackage : dsp_pack