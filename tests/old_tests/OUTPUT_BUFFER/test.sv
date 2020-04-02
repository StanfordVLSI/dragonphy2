`include "mLingua_pwl.vh"
`include "iotype.sv"
`default_nettype none

module test;

	import const_pack::*;
	import test_pack::*;
	import checker_pack::*;
	import jtag_reg_pack::*;

	// Analog inputs
	pwl ch_outp;
	pwl ch_outn;
	real v_cm;
	`voltage_t v_cal;

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
	butterphy_top top_i (
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
		// Toggle reset
        #(20ns);
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;

		// Initialize JTAG
		jtag_drv_i.init();

		// Enable the input buffer
		jtag_drv_i.write_tc_reg(en_inbuf, 'b1);
		jtag_drv_i.write_tc_reg(en_v2t, 'b1);
		jtag_drv_i.write_tc_reg(int_rstb, 'b1);


		// Set up the output buffer
		jtag_drv_i.write_tc_reg(sel_outbuff, 'd0);
		jtag_drv_i.write_tc_reg(sel_trigbuff, 'd0);
		jtag_drv_i.write_tc_reg(en_outbuff, 'b1);
		jtag_drv_i.write_tc_reg(en_outbuff, 'b1);
		jtag_drv_i.write_tc_reg(Ndiv_outbuff, 'd0);
		jtag_drv_i.write_tc_reg(Ndiv_trigbuff, 'd0);

		// Wait a little bit
		#(100ns);

		// run assertions
		$display("Testing input clock");
		$display("External period: ", clk_in_period_p.a);
		check_rel_tol(1.0/clk_in_period_p.a, 8e9, 0.01);
		check_rel_tol(1.0/clk_in_period_n.a, 8e9, 0.01);

		$display("Testing output clock");
		$display("CLK_OUT period: ", clk_out_period_p.a);
		check_rel_tol(1.0/clk_out_period_p.a, 1e9, 0.01);
		check_rel_tol(1.0/clk_out_period_n.a, 1e9, 0.01);

		$display("Testing trigger clock");
		$display("TRIG_OUT period: ", trig_out_period_p.a);
		check_rel_tol(1.0/trig_out_period_p.a, 1e9, 0.01);
		check_rel_tol(1.0/trig_out_period_n.a, 1e9, 0.01);
		
		$finish;
	end

endmodule

`default_nettype wire
