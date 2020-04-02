`default_nettype none

interface sram_debug_intf;

	import const_pack::*;

    logic [N_mem_addr-1:0] in_addr;
    logic signed [Nadc-1:0] out_data [(Nti+Nti_rep)-1:0];
    logic [N_mem_addr-1:0] addr;

    modport sram (
	    input in_addr,
	    output out_data,
	    output addr
    );

    modport jtag (
	    output in_addr,
	    input out_data,
	    input addr
    );

endinterface

`default_nettype wire