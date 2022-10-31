`default_nettype none

interface sram_debug_intf #(
    parameter integer N_mem_tiles=4
);

    localparam log_N_tiles = $clog2(N_mem_tiles);

	import const_pack::*;

    logic [N_mem_addr + log_N_tiles  - 1:0] in_addr;
    logic signed [Nadc - 1:0] out_data [(Nti+Nti_rep)-1:0];
    logic [N_mem_addr + log_N_tiles  - 1:0] addr;
    logic sel_sram;

    modport sram (
	    input in_addr,
        input sel_sram,
	    output out_data,
	    output addr
    );

    modport jtag (
	    output in_addr,
        output sel_sram,
	    input out_data,
	    input addr
    );

endinterface

`default_nettype wire