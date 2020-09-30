interface wme_debug_intf import const_pack::*; ();

    logic [31:0] wme_ffe_data;
    logic [$clog2(Nti)+$clog2(ffe_gpack::length):0] wme_ffe_inst;
    logic wme_ffe_exec;
    logic signed [((ffe_gpack::weight_precision)-1):0] wme_ffe_read;

    logic [31:0] wme_mlsd_data;
    logic [$clog2(Nti)+$clog2(mlsd_gpack::estimate_depth):0] wme_mlsd_inst;
    logic wme_mlsd_exec;
    logic signed [((mlsd_gpack::estimate_precision)-1):0] wme_mlsd_read;


    modport wme (
        input wme_ffe_data,
        input wme_ffe_inst,
        input wme_ffe_exec,
        output wme_ffe_read,

        input wme_mlsd_data,
        input wme_mlsd_inst,
        input wme_mlsd_exec,
        output wme_mlsd_read
    );

        modport jtag (
        output wme_ffe_data,
        output wme_ffe_inst,
        output wme_ffe_exec,
        input wme_ffe_read,

        output wme_mlsd_data,
        output wme_mlsd_inst,
        output wme_mlsd_exec,
        input wme_mlsd_read
    );

endinterface : wme_debug_intf