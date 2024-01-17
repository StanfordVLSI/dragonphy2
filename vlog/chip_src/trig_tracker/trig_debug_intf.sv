`default_nettype none

interface trig_debug_intf;

	import const_pack::*;

    logic trigger;
    logic [9:0] in_addr;
    logic [31:0] mem_data_out;

	modport aet (
	 input  trigger,
	 input  in_addr,
	 output mem_data_out
	);

	modport jtag (
	 output trigger,
	 output in_addr,
	 input  mem_data_out
	);

endinterface

`default_nettype wire
