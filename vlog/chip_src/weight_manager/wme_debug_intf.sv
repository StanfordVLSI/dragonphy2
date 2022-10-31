interface wme_debug_intf import const_pack::*; ();

    logic [31:0] wme_chan_data;
    logic [$clog2(Nti)+$clog2(channel_gpack::est_channel_depth):0] wme_chan_inst;
    logic wme_chan_exec;
    logic signed [((channel_gpack::est_channel_precision)-1):0] wme_chan_read;


    modport wme (
        input wme_chan_data,
        input wme_chan_inst,
        input wme_chan_exec,
        output wme_chan_read
    );

    modport jtag (

        output wme_chan_data,
        output wme_chan_inst,
        output wme_chan_exec,
        input wme_chan_read
    );

endinterface : wme_debug_intf