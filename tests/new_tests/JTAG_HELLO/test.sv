`include "mLingua_pwl.vh"

`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

module test;
	
	import const_pack::*;
	import test_pack::*;
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

	// Main test

	logic [31:0] result;

	initial begin
	    // Uncomment to save key signals
	    // $dumpfile("out.vcd");
	    // $dumpvars(2, top_i.iacore);

		// Toggle reset
		$display("Toggling reset.");
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;		

		// Toggle en_gf
		// TODO: remove this!
		$display("Toggling en_gf.");
		`FORCE_ADBG(en_v2t, 0);
		#(20ns);
		`FORCE_ADBG(en_v2t, 1);

		// Initialize JTAG
		$display("Initializing JTAG.");
		jtag_drv_i.init();

		// ID read test
		$display("Reading the JTAG ID.");
		jtag_drv_i.read_id(result);
		assert (result == 1'b1);

		// TC domain write/read test
		$display("Writing TC register 0x%0H...", pd_offset_ext);
		jtag_drv_i.write_tc_reg(pd_offset_ext, 'hCAFE);
		$display("Reading TC register 0x%0H...", pd_offset_ext);
		jtag_drv_i.read_tc_reg(pd_offset_ext, result);
		$display("Read 0x%0H from TC register 0x%0H.", result, pd_offset_ext);
		assert (result == 'hCAFE);

        // Set up clock as needed for SC
        $display("Clearing bypass_inbuf_div...", bypass_inbuf_div);
    	jtag_drv_i.write_tc_reg(bypass_inbuf_div, 0);
    	$display("Enabling input buffer", en_inbuf);
    	jtag_drv_i.write_tc_reg(en_inbuf, 1);
		$display("De-asserting int_rstb.");
		jtag_drv_i.write_tc_reg(int_rstb, 'b1);
	    $display("Setting en_v2t...", en_v2t);
		jtag_drv_i.write_tc_reg(en_v2t, 'b1);

		// Force data into SC domain
		$display("Writing data to Qperi...");
		`FORCE_ADBG(Qperi, '{'hE, 'hC, 'hA, 'hF});
		#(100ns);

		// Read back data from SC domain
		$display("Reading SC register 0x%0H...", Qperi[0]);
		jtag_drv_i.read_sc_reg(Qperi[0], result);
		$display("Read 0x%0H from SC register 0x%0H", result, Qperi[0]);
		assert (result == 'hF);
		#(10ns);

		$display("Reading SC register 0x%0H...", Qperi[1]);
		jtag_drv_i.read_sc_reg(Qperi[1], result);
		$display("Read 0x%0H from SC register 0x%0H", result, Qperi[1]);
		assert (result == 'hA);
		#(10ns);

		$display("Reading SC register 0x%0H...", Qperi[2]);
		jtag_drv_i.read_sc_reg(Qperi[2], result);
		$display("Read 0x%0H from SC register 0x%0H", result, Qperi[2]);
		assert (result == 'hC);
		#(10ns);

		$display("Reading SC register 0x%0H...", Qperi[3]);
		jtag_drv_i.read_sc_reg(Qperi[3], result);
		$display("Read 0x%0H from SC register 0x%0H", result, Qperi[3]);
		assert (result == 'hE);
		#(10ns);

        // Declare success
        $display("Success!");

		// Finish test
		$finish;
	end

endmodule