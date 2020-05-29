`include "mLingua_pwl.vh"
`include "iotype.sv"

`default_nettype none

module test;

	import const_pack::*;
	import test_pack::*;
	import jtag_reg_pack::*;

	logic clk;
	logic rstb;

	acore_debug_intf adbg_intf_i ();
	cdr_debug_intf cdbg_intf_i ();
	dcore_debug_intf ddbg_intf_i ();
	sram_debug_intf sdbg_intf_i ();
	jtag_intf jtag_intf_i ();

	jtag jtag_i (
		.clk(clk),
		.rstb(rstb),
		.adbg_intf_i(adbg_intf_i),
		.cdbg_intf_i(cdbg_intf_i),
		.ddbg_intf_i(ddbg_intf_i),
		.sdbg_intf_i(sdbg_intf_i),
		.jtag_intf_i(jtag_intf_i)
	);

	// Clock

	clock #(
		.freq(1e9),
		.duty(0.5),
		.td(0)
	) jtag_int_clk (
		.ckout(clk),
		.ckoutb()
	);

	// JTAG driver

	jtag_drv jtag_drv_i (jtag_intf_i);

	// Main test

	logic [31:0] result;

	initial begin
		// Initialization
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;
		#(20ns);	

		// Initialize JTAG
		jtag_drv_i.init();

		// ID read test
		jtag_drv_i.read_id(result);
		assert (result == 1'b1);

		`include "test_body.svh"

		// Finish test
		$finish;
	end

endmodule

`default_nettype wire
