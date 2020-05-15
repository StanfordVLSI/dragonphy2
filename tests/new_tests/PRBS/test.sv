`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``
`define FORCE_PDBG(name, value) force top_i.idcore.pdbg_intf_i.``name`` = ``value``

`define GET_PDBG(name) top_i.idcore.pdbg_intf_i.``name``

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
    longint err_bits_1, total_bits_1;
    longint err_bits_2, total_bits_2;
    integer rx_shift;
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
        #(64ns);

        // Turn on the PRBS generator
        $display("Turn on the PRBS generator (case 1)");
        `FORCE_DDBG(prbs_gen_rstb, 1);
        `FORCE_PDBG(prbs_gen_cke, 1);
        #(50ns);

        // Select the PRBS checker data source
        $display("Select the PRBS checker data source (case 1)");
        `FORCE_DDBG(sel_prbs_mux, 2'b11);
        #(10ns);

        // Release the PRBS checker from reset
        $display("Release the PRBS tester from reset (case 1)");
        `FORCE_DDBG(prbs_rstb, 1);
        #(50ns);

        // run the PRBS tester
        $display("Running the PRBS tester (case 1)");
        `FORCE_PDBG(prbs_checker_mode, 2);
        #(625ns);

        // get results
        `FORCE_PDBG(prbs_checker_mode, 3);
        #(10ns);

        err_bits_1 = 0;
        err_bits_1 |= `GET_PDBG(prbs_err_bits_upper);
        err_bits_1 <<= 32;
        err_bits_1 |= `GET_PDBG(prbs_err_bits_lower);

        total_bits_1 = 0;
        total_bits_1 |= `GET_PDBG(prbs_total_bits_upper);
        total_bits_1 <<= 32;
        total_bits_1 |= `GET_PDBG(prbs_total_bits_lower);

        // Reset the PRBS checker
        $display("Reset the PRBS tester (case 2)");
        `FORCE_PDBG(prbs_checker_mode, 0);
        #(50ns);

        // run the PRBS tester, but inject an error in the middle
        $display("Running the PRBS tester (case 2)");
        `FORCE_PDBG(prbs_checker_mode, 2);
        #(300ns);
        `FORCE_PDBG(prbs_gen_inj_err, 1);
        #(25ns);
        `FORCE_PDBG(prbs_gen_inj_err, 0);
        #(300ns);

        // get results
        `FORCE_PDBG(prbs_checker_mode, 3);
        #(10ns);

        err_bits_2 = 0;
        err_bits_2 |= `GET_PDBG(prbs_err_bits_upper);
        err_bits_2 <<= 32;
        err_bits_2 |= `GET_PDBG(prbs_err_bits_lower);

        total_bits_2 = 0;
        total_bits_2 |= `GET_PDBG(prbs_total_bits_upper);
        total_bits_2 <<= 32;
        total_bits_2 |= `GET_PDBG(prbs_total_bits_lower);

        // print results
        $display("err_bits_1: %0d", err_bits_1);
        $display("total_bits_1: %0d", total_bits_1);
        $display("err_bits_2: %0d", err_bits_2);
        $display("total_bits_2: %0d", total_bits_2);

        // check results

        if (!(total_bits_1 >= 9500)) begin
            $error("Not enough bits transmitted (case 1)");
        end else begin
            $display("Number of bits transmitted is OK (case 1)");
        end

        if (!(err_bits_1 == 0)) begin
            $error("Bit error detected (case 1)");
        end else begin
            $display("No bit errors detected (case 1)");
        end

        if (!(total_bits_2 >= 9500)) begin
            $error("Not enough bits transmitted (case 2)");
        end else begin
            $display("Number of bits transmitted is OK (case 2)");
        end

        if (!(err_bits_2 == 48)) begin
            $error("3*16=48 bit errors should be detected (case 2)");
        end else begin
            $display("3*16=48 bit errors detected, as expected for case 2");
        end

		// Finish test
		$finish;
	end

endmodule
