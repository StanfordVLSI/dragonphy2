`include "mLingua_pwl.vh"

`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

module test;

	import test_pack::*;
	import checker_pack::*;

	// clock inputs 
	logic ext_clkp;
	logic ext_clkn;

	// reset
	logic rstb;

	// JTAG driver
	jtag_intf jtag_intf_i ();
	jtag_drv jtag_drv_i (jtag_intf_i);

	// instantiate top module
	dragonphy_top top_i (
		.ext_clkp(ext_clkp),
		.ext_clkn(ext_clkn),
        .ext_rstb(rstb),
        .jtag_intf_i(jtag_intf_i)
        // other I/O not used...
	);

	// External clock

	clock #(
		.freq(full_rate/2),
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	); 

	// Frequency measurement

	pwl ext_period;
	meas_clock meas_clock_ext (
		.clk(ext_clkp),
		.period(ext_period)
	);

	pwl int_period;
	meas_clock meas_clock_int (
		.clk(top_i.iacore.clk_in_pi),
		.period(int_period)
	);

	// Main test

	initial begin
		// Uncomment to save key signals
	    // $dumpfile("out.vcd");
	    // $dumpvars(1, top_i);
	    // $dumpvars(1, top_i.iacore);
        // $dumpvars(3, top_i.iacore.iinbuf);

		// Initialize pins
		$display("Initializing pins...");
		jtag_drv_i.init();

		// Toggle reset
		$display("Toggling reset...");
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;

		// Enable the input buffer
		$display("Setting control signals...");
        `FORCE_ADBG(en_inbuf, 0);
        #(1ns);
        `FORCE_ADBG(en_inbuf, 1);
        #(1ns);
		`FORCE_ADBG(en_gf, 1);
        #(1ns);
        `FORCE_DDBG(int_rstb, 1);
        #(1ns);

        // Wait a little while
        $display("Waiting for period measurement to complete...");
        #(1us);

		// print results
		$display("External period: ", ext_period.a);
		$display("Internal period: ", int_period.a);

		// run assertions
		check_rel_tol(1.0/ext_period.a, 8e9, 0.01);
		check_rel_tol(1.0/int_period.a, 4e9, 0.01);
		
		$finish;
	end

endmodule
