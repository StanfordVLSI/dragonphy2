`include "mLingua_pwl.vh"

`ifndef EXPECTED_JTAG_ID
    `define EXPECTED_JTAG_ID 32'h0
`endif

module test;
	
	import const_pack::*;
	import test_pack::*;
	import jtag_reg_pack::*;

	// clock inputs
	logic ext_clkp;
	logic ext_clkn;

	// reset
	logic rstb;

	// JTAG
	jtag_intf jtag_intf_i();
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
		.freq(full_rate/2), // This depends on the frequency divider in the ACORE's input buffer
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	);

	// Main test

	logic [31:0] result;

	initial begin
	    `ifdef DUMP_WAVEFORMS_NCSIM
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

		// ID read test
		$display("Reading the JTAG ID.");
		jtag_drv_i.read_id(result);
		assert (result == `EXPECTED_JTAG_ID);

		// TC domain write/read test
		$display("Writing TC register 0x%0H...", pd_offset_ext);
		jtag_drv_i.write_tc_reg(pd_offset_ext, 'hCAFE);
		$display("Reading TC register 0x%0H...", pd_offset_ext);
		jtag_drv_i.read_tc_reg(pd_offset_ext, result);
		$display("Read 0x%0H from TC register 0x%0H.", result, pd_offset_ext);
		assert (result == 'hCAFE);

        // Soft reset sequence
        $display("De-asserting int_rstb...");
        jtag_drv_i.write_tc_reg(int_rstb, 1);
        $display("De-asserting en_inbuf...");
        jtag_drv_i.write_tc_reg(en_inbuf, 1);
		$display("De-asserting en_inbuf...");
        jtag_drv_i.write_tc_reg(en_gf, 1);
        $display("De-asserting en_v2t...");
        jtag_drv_i.write_tc_reg(en_v2t, 1);

		// Force data into SC domain
		$display("Writing data to Qperi...");
		force top_i.iacore.adbg_intf_i.Qperi = '{'hE, 'hC, 'hA, 'hF};
		#(10ns);

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
