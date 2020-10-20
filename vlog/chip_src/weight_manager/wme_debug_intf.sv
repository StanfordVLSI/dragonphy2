interface wme_debug_intf import const_pack::*; ();

    logic [31:0] wme_ffe_data;
    logic [$clog2(Nti)+$clog2(ffe_gpack::length):0] wme_ffe_inst;
    logic wme_ffe_exec;
    logic signed [((ffe_gpack::weight_precision)-1):0] wme_ffe_read;

    logic [31:0] wme_chan_data;
    logic [$clog2(Nti)+$clog2(chan_gpack::estimate_depth):0] wme_chan_inst;
    logic wme_chan_exec;
    logic signed [((chan_gpack::estimate_precision)-1):0] wme_chan_read;


    modport wme (
        input wme_ffe_data,
        input wme_ffe_inst,
        input wme_ffe_exec,
        output wme_ffe_read,

        input wme_chan_data,
        input wme_chan_inst,
        input wme_chan_exec,
        output wme_chan_read
    );

        modport jtag (
        output wme_ffe_data,
        output wme_ffe_inst,
        output wme_ffe_exec,
        input wme_ffe_read,

        output wme_chan_data,
        output wme_chan_inst,
        output wme_chan_exec,
        input wme_chan_read
    );

endinterface : wme_debug_intf