`include "mLingua_pwl.vh"

`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

module test;

	import const_pack::*;
	import test_pack::*;
	import checker_pack::*;
	import jtag_reg_pack::*;

	// Analog inputs
	pwl ch_outp;
	pwl ch_outn;
	real v_cm;
	real v_cal;

	// clock inputs 
	logic clk_async;
	logic clk_jm_p;
	logic clk_jm_n;
	logic ext_clkp;
	logic ext_clkn;

	// clock outputs
	logic clk_out_p;
	logic clk_out_n;
	logic clk_trig_p;
	logic clk_trig_n;
	logic clk_retime;
	logic clk_slow;

	// dump control
	logic dump_start;

	// JTAG
	jtag_intf jtag_intf_i();

	// reset
	logic rstb;

	// instantiate top module
	dragonphy_top top_i (
		// analog inputs
		.ext_rx_inp(ch_outp),
		.ext_rx_inn(ch_outn),
		.ext_Vcm(v_cm),
		.ext_Vcal(v_cal),

		// clock inputs 
		.ext_clkp(ext_clkp),
		.ext_clkn(ext_clkn),

		// clock outputs
		.clk_out_p(clk_out_p),
		.clk_out_n(clk_out_n),
		.clk_trig_p(clk_trig_p),
		.clk_trig_n(clk_trig_n),
		// dump control
		.ext_dump_start(dump_start),
        .ext_rstb(rstb),
		// JTAG
		.jtag_intf_i(jtag_intf_i)
	);

	// External clock

	clock #(
		.freq(full_rate/2), // This depends on the frequency divider in the ACORE's input buffer
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	); 

	// JTAG driver

	jtag_drv jtag_drv_i (jtag_intf_i);

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

		// Toggle reset
		$display("Toggling reset...");
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;

		// Initialize JTAG
		// TODO: is this needed?
        $display("Initializing JTAG...");
		jtag_drv_i.init();

		// Enable the input buffer
		$display("Setting control signals...");
		`FORCE_ADBG(bypass_inbuf_div, 0);
		#(1ns);
        `FORCE_ADBG(en_inbuf, 1);
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