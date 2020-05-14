`include "mLingua_pwl.vh"

`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``
`define FORCE_MDBG(name, value) force top_i.mdbg_intf_i.``name`` = ``value``

module test;

	import test_pack::*;
	import checker_pack::*;

	// clock inputs
	logic ext_mdll_clk_refp;
	logic ext_mdll_clk_refn;

	// clock outputs
	logic clk_out_p;
	logic clk_out_n;

	// dump control
	logic dump_start;

	// reset
	logic rstb;

	// JTAG driver
	jtag_intf jtag_intf_i ();
	jtag_drv jtag_drv_i (jtag_intf_i);

	// instantiate top module
	dragonphy_top top_i (
        // clock inputs
		.ext_mdll_clk_refp(ext_mdll_clk_refp),
	    .ext_mdll_clk_refn(ext_mdll_clk_refn),

        // clock outputs
		.clk_out_p(clk_out_p),
		.clk_out_n(clk_out_n),

		// reset
        .ext_rstb(rstb),

        // JTAG
		.jtag_intf_i(jtag_intf_i)

		// other I/O not used..
	);

	// External clocks

	clock #(
		.freq(125.0e6),
		.duty(0.5),
		.td(0)
	) ext_clk_i (
		.ckout(ext_mdll_clk_refp),
		.ckoutb(ext_mdll_clk_refn)
	);

	// Frequency measurement

	pwl clk_in_pi_period;
	meas_clock meas_clk_in_pi (
		.clk(top_i.iacore.clk_in_pi),
		.period(clk_in_pi_period)
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

	// Main test

	initial begin
		`ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif

        // initialize control signals
		rstb = 1'b0;
        #(1ns);

		// Release reset
		$display("Releasing external reset...");
		rstb = 1'b1;
        #(1ns);

        // Initialize JTAG
        $display("Initializing JTAG...");
        jtag_drv_i.init();

        // Soft reset sequence
        $display("Soft reset sequence...");
        `FORCE_DDBG(int_rstb, 1);
        #(1ns);
        `FORCE_ADBG(en_inbuf, 1);
		#(1ns);
        `FORCE_ADBG(en_gf, 1);
        #(1ns);
        `FORCE_ADBG(en_v2t, 1);
        #(1ns);

        // Enable input buffer for the MDLL reference clock
        $display("Enable input buffer for the MDLL reference clock...");
        `FORCE_ADBG(disable_ibuf_mdll_ref, 0);
        #(1ns);

        // Take the MDLL out of reset and enable the oscillator
        $display("Take the MDLL out of reset and enable the oscillator...");
        `FORCE_MDBG(rstn_jtag, 1);
        #(25ns);
        `FORCE_MDBG(en_osc_jtag, 1);
        #(25ns);

        // Use the MDLL clock in the analog core
        $display("Use the MDLL clock in the analog core...");
        `FORCE_ADBG(sel_clk_source, 1);
        #(25ns);

        // Bypass the initial divide-by-two in the analog core
        $display("Bypass the initial divide-by-two in the analog core...");
        `FORCE_ADBG(bypass_inbuf_div2, 1);
        #(25ns);

		// Set up the output buffer
		$display("Set up the output buffer...");
		`FORCE_DDBG(en_outbuff, 1);
        #(1ns);
        `FORCE_DDBG(sel_outbuff, 13);  // MDLL output clock
        #(1ns);

		// Wait a little bit to measure frequencies
		#(100ns);

		// run assertions
		$display("Testing PI input clock");
		$display("CLK_IN_PI period: ", clk_in_pi_period.a);
		check_rel_tol(1.0/clk_in_pi_period.a, 4e9, 0.05);

		$display("Testing output clock");
		$display("CLK_OUT period: ", clk_out_period_p.a);
		check_rel_tol(1.0/clk_out_period_p.a, 4e9, 0.05);
		check_rel_tol(1.0/clk_out_period_n.a, 4e9, 0.05);
		
		$finish;
	end

endmodule
