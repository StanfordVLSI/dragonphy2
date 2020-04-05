`include "mLingua_pwl.vh"
`include "iotype.sv"

`default_nettype none

module test;
	
	import const_pack::*;
	import test_pack::*;
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

	// Main test

	logic [31:0] result;

	initial begin
		// Toggle reset
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;		

		// Initialize JTAG
		jtag_drv_i.init();
		jtag_drv_i.write_tc_reg(int_rstb, 'b1);

		// ID read test
		jtag_drv_i.read_id(result);
		assert (result == 1'b1);

		// TC domain write/read test
		jtag_drv_i.write_tc_reg(pd_offset_ext, 'hCAFE);
		jtag_drv_i.read_tc_reg(pd_offset_ext, result);
		assert (result == 'hCAFE);
		jtag_drv_i.read_tc_reg(en_v2t, result);

		// Enable V2T
		// TODO: why is this needed?
		jtag_drv_i.write_tc_reg(en_v2t, 'b1);

		// Enable the input buffer
		jtag_drv_i.write_tc_reg(en_inbuf, 'b1);

		// Force data into SC domain
		force top_i.iacore.adbg_intf_i.Qperi = '{'hE, 'hC, 'hA, 'hF};
		#(10ns);

		// Read back data from SC domain
		jtag_drv_i.read_sc_reg(Qperi[0], result);
		assert (result == 'hF);
		#(10ns);

		jtag_drv_i.read_sc_reg(Qperi[1], result);
		assert (result == 'hA);
		#(10ns);

		jtag_drv_i.read_sc_reg(Qperi[2], result);
		assert (result == 'hC);
		#(10ns);

		jtag_drv_i.read_sc_reg(Qperi[3], result);
		assert (result == 'hE);
		#(10ns);

        // Declare success
        $display("Success!");

		// Finish test
		$finish;
	end

endmodule

`default_nettype wire
