`include "mLingua_pwl.vh"

`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

module test;

	import test_pack::*;
	import checker_pack::*;

	// clock inputs
	logic ext_clkp;
	logic ext_clkn;

	// clock outputs
	logic clk_out_p;
	logic clk_out_n;
	logic clk_trig_p;
	logic clk_trig_n;

	// dump control
	logic dump_start;

	// reset
	logic rstb;

	// JTAG driver
	jtag_intf jtag_intf_i ();
	jtag_drv jtag_drv_i (jtag_intf_i);

	// instantiate top module
	dragonphy_top top_i (
		.ext_clkp(ext_clkp),
		.ext_clkn(ext_clkn),
		.clk_out_p(clk_out_p),
		.clk_out_n(clk_out_n),
		.clk_trig_p(clk_trig_p),
		.clk_trig_n(clk_trig_n),
        .ext_rstb(rstb),
		.jtag_intf_i(jtag_intf_i)
		// other I/O not used..
	);


	// External clock
    localparam real ext_clk_freq = full_rate/2;
	clock #(
		.freq(ext_clk_freq),
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	); 

	// Frequency measurement

	pwl clk_in_period_p;
	meas_clock meas_clk_in_p (
		.clk(ext_clkp),
		.period(clk_in_period_p)
	);

	pwl clk_in_period_n;
	meas_clock meas_clk_in_n (
		.clk(ext_clkn),
		.period(clk_in_period_n)
	);

	pwl clk_out_period_p;
	meas_clock meas_clk_out_p (
		.clk(clk_out_p),
		.period(clk_out_period_p)
	);

	pwl clk_out_period_n;
	meas_clock meas_clk_out_n (
		.clk(clk_out_n),
		.period(clk_out_period_n)
	);

	pwl trig_out_period_p;
	meas_clock meas_trig_out_p (
		.clk(clk_trig_p),
		.period(trig_out_period_p)
	);

	pwl trig_out_period_n;
	meas_clock meas_trig_out_n (
		.clk(clk_trig_n),
		.period(trig_out_period_n)
	);

	// Main test

	initial begin
		// Uncomment to save key signals
	    // $dumpfile("out.vcd");
	    // $dumpvars(1, top_i);
	    // $dumpvars(1, top_i.iacore);
	    // $dumpvars(3, top_i.iacore.iinbuf);
        // $dumpvars(1, top_i.idcore);
        // $dumpvars(2, top_i.idcore.out_buff_i);
        // $dumpvars(1, top_i.idcore.buffered_signals);

		// Initialize pins
		$display("Initializing pins...");
		jtag_drv_i.init();

		// Toggle reset
		$display("Toggling reset...");
        #(20ns);
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;

		// Enable the input buffer
		$display("Set up the input buffer...");
		`FORCE_ADBG(en_gf, 1);
        #(1ns);
        `FORCE_ADBG(bypass_inbuf_div, 1);
        #(1ns);
		`FORCE_ADBG(en_inbuf, 0);
        #(1ns);
        `FORCE_ADBG(en_inbuf, 1);
        #(1ns);
        `FORCE_ADBG(en_v2t, 1);
        #(1ns);
        `FORCE_DDBG(int_rstb, 1);
        #(1ns);

		// Set up the output buffer
		$display("Set up the output buffer...");
		`FORCE_DDBG(en_outbuff, 'b1);
        #(1ns);
        `FORCE_DDBG(en_trigbuff, 'b1);
        #(1ns);

		// Wait a little bit to measure frequencies
		#(100ns);

		// run assertions
		$display("Testing input clock");
		$display("External period: ", clk_in_period_p.a);
		check_rel_tol(1.0/clk_in_period_p.a, ext_clk_freq, 0.01);
		check_rel_tol(1.0/clk_in_period_n.a, ext_clk_freq, 0.01);

		$display("Testing output clock");
		$display("CLK_OUT period: ", clk_out_period_p.a);
		check_rel_tol(1.0/clk_out_period_p.a, ext_clk_freq/256, 0.01);
		check_rel_tol(1.0/clk_out_period_n.a, ext_clk_freq/256, 0.01);

		$display("Testing trigger clock");
		$display("TRIG_OUT period: ", trig_out_period_p.a);
		check_rel_tol(1.0/trig_out_period_p.a, ext_clk_freq/256, 0.01);
		check_rel_tol(1.0/trig_out_period_n.a, ext_clk_freq/256, 0.01);
		
		$finish;
	end

endmodule