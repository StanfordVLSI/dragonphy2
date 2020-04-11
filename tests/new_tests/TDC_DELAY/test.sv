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

	// ASYNC clock

	clock #(
		.freq(100e6),
		.duty(0.5),
		.td(0)
	) iASYNCCLK (
		.ckout(clk_async)
	); 

	// JTAG driver

	jtag_drv jtag_drv_i (jtag_intf_i);

	// Main test

	initial begin
		// Toggle reset
        #(20ns);
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;

		// Initialize JTAG
		jtag_drv_i.init();

		$display("Enabling the input buffer.");
		jtag_drv_i.write_tc_reg(en_inbuf, 'b1);
		$display("Enabling the V2T.");
		jtag_drv_i.write_tc_reg(en_v2t, 'b1);
		$display("Enabling the replica slices.");
		jtag_drv_i.write_tc_reg(en_slice_rep, (1<<(Nti_rep))-1);
		$display("Sending del_out_rep[0] to outbuff");
		jtag_drv_i.write_tc_reg(sel_outbuff, 'd6);
		$display("Sending clk_async to trigbuff");
		jtag_drv_i.write_tc_reg(sel_trigbuff, 'd9);
		$display("Enabling the output buffer");
		jtag_drv_i.write_tc_reg(en_outbuff, 'b1);
		$display("Enabling the trigger buffer");
		jtag_drv_i.write_tc_reg(en_trigbuff, 'b1);
		$display("Setting the output buffer divide ratio");
		jtag_drv_i.write_tc_reg(Ndiv_outbuff, 'd0);
		$display("Setting the trigger buffer divide ratio");
		jtag_drv_i.write_tc_reg(Ndiv_trigbuff, 'd0);
		jtag_drv_i.write_tc_reg(int_rstb, 'b1);


		// Dummy write
		$display("Dummy write");
		jtag_drv_i.write_tc_reg(en_inbuf, 'b1);

		// Wait a little bit
		#(250ns);
		
		$finish;
	end

endmodule

`default_nettype wire
