`define FORCE_JTAG(name, value) force top_i.idcore.jtag_i.rjtag_intf_i.``name`` = ``value``
`define GET_JTAG(name) top_i.idcore.jtag_i.rjtag_intf_i.``name``

`ifndef EXT_PFD_OFFSET
    `define EXT_PFD_OFFSET 16
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

	// Analog inputs

	pwl ch_outp;
	pwl ch_outn;

	// instantiate top module

	dragonphy_top top_i (
	    // analog inputs
		.ext_rx_inp(ch_outp),
		.ext_rx_inn(ch_outn),

		// external clocks
		.ext_clkp(ext_clkp),
		.ext_clkn(ext_clkn),

		// reset
        .ext_rstb(rstb),

        // JTAG
		.jtag_intf_i(jtag_intf_i)

		// other I/O not used...
	);

    // prbs stimulus

    logic tx_clk;
    logic tx_data;

    tx_prbs #(
        .freq(full_rate)
    ) tx_prbs_i (
        .clk(tx_clk),
        .out(tx_data)
    );

    // TX driver

    pwl tx_p;
    pwl tx_n;

    diff_tx_driver diff_tx_driver_i (
        .in(tx_data),
        .out_p(tx_p),
        .out_n(tx_n)
    );

    // Differential channel

    diff_channel diff_channel_i (
        .in_p(tx_p),
        .in_n(tx_n),
        .out_p(ch_outp),
        .out_n(ch_outn)
    );

	// External clock

	clock #(
		.freq(full_rate/2), // This depends on the frequency divider in the ACORE's input buffer
		.duty(0.5),
		.td(30e-12)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	);

	// Main test

	logic [31:0] result;
    longint err_bits_0, total_bits_0;
    longint err_bits_1, total_bits_1;
    longint err_bits_2, total_bits_2;

	logic [Nadc-1:0] tmp_ext_pfd_offset [Nti-1:0];
    logic [Npi-1:0] tmp_bypass_pi_ctl [Nout-1:0];
    logic [Nprbs-1:0] tmp_prbs_eqn;

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
        `FORCE_JTAG(int_rstb, 1);
        #(1ns);
        `FORCE_JTAG(en_inbuf, 1);
		#(1ns);
        `FORCE_JTAG(en_gf, 1);
        #(1ns);
        `FORCE_JTAG(en_v2t, 1);
        #(64ns);

        // Set up the PFD offset
        $display("Setting up the PFD offset...");
        for (int idx=0; idx<Nti; idx=idx+1) begin
            tmp_ext_pfd_offset[idx] = `EXT_PFD_OFFSET;
        end
        `FORCE_JTAG(ext_pfd_offset, tmp_ext_pfd_offset);
        #(1ns);

        // Configure the PI
        $display("Setting up the PI control codes...");
        tmp_bypass_pi_ctl[0] = 0;
        tmp_bypass_pi_ctl[1] = 67;
        tmp_bypass_pi_ctl[2] = 133;
        tmp_bypass_pi_ctl[3] = 200;
        `FORCE_JTAG(bypass_pi_ctl, tmp_bypass_pi_ctl);
        `FORCE_JTAG(en_bypass_pi_ctl, 1);
        #(5ns);

        // Toggle the en_v2t signal to re-initialize the V2T ordering
        $display("Toggling en_v2t...");
        `FORCE_JTAG(en_v2t, 0);
        #(5ns);
        `FORCE_JTAG(en_v2t, 1);
        #(5ns);

		// Wait some time initially
		$display("Initial delay of 100 ns...");
		#(100ns);

        /////////
        // Case 0
        /////////

        // Set the equation for the PRBS checker
        $display("Setting the PRBS equation (case 0)");
        tmp_prbs_eqn = 0;
        tmp_prbs_eqn[ 1] = 1'b1;
        tmp_prbs_eqn[20] = 1'b1;
		`FORCE_JTAG(prbs_eqn, tmp_prbs_eqn);
        #(10ns);

        // Release the PRBS checker from reset
        $display("Release the PRBS tester from reset (case 0)");
        `FORCE_JTAG(prbs_rstb, 1);
        #(50ns);

        // Run the PRBS tester
        $display("Running the PRBS tester (case 0)");
        `FORCE_JTAG(prbs_checker_mode, 2);
        #(625ns);

        // Get results
        `FORCE_JTAG(prbs_checker_mode, 3);
        #(10ns);

        err_bits_0 = 0;
        err_bits_0 |= `GET_JTAG(prbs_err_bits_upper);
        err_bits_0 <<= 32;
        err_bits_0 |= `GET_JTAG(prbs_err_bits_lower);

        total_bits_0 = 0;
        total_bits_0 |= `GET_JTAG(prbs_total_bits_upper);
        total_bits_0 <<= 32;
        total_bits_0 |= `GET_JTAG(prbs_total_bits_lower);

        // Print results
        $display("err_bits_0: %0d", err_bits_0);
        $display("total_bits_0: %0d", total_bits_0);

        /////////
        // Case 1
        /////////

        // Set the equation for the PRBS checker
        $display("Setting the PRBS equation (case 1)");
        tmp_prbs_eqn = 32'b00000000000000000000000001100000;
        `FORCE_JTAG(prbs_eqn, tmp_prbs_eqn);
        #(10ns);

        // Turn on the PRBS generator
        $display("Turn on the PRBS generator (case 1)");
        `FORCE_JTAG(prbs_gen_rstb, 1);
        `FORCE_JTAG(prbs_gen_cke, 1);
        #(50ns);

        // Select the PRBS checker data source
        $display("Select the PRBS checker data source (case 1)");
        `FORCE_JTAG(sel_prbs_mux, 2'b11);
        #(10ns);

        // Reset the PRBS checker
        $display("Reset the PRBS tester (case 1)");
        `FORCE_JTAG(prbs_checker_mode, 0);
        #(50ns);

        // run the PRBS tester
        $display("Running the PRBS tester (case 1)");
        `FORCE_JTAG(prbs_checker_mode, 2);
        #(625ns);

        // get results
        `FORCE_JTAG(prbs_checker_mode, 3);
        #(10ns);

        err_bits_1 = 0;
        err_bits_1 |= `GET_JTAG(prbs_err_bits_upper);
        err_bits_1 <<= 32;
        err_bits_1 |= `GET_JTAG(prbs_err_bits_lower);

        total_bits_1 = 0;
        total_bits_1 |= `GET_JTAG(prbs_total_bits_upper);
        total_bits_1 <<= 32;
        total_bits_1 |= `GET_JTAG(prbs_total_bits_lower);

        // Print results
        $display("err_bits_1: %0d", err_bits_1);
        $display("total_bits_1: %0d", total_bits_1);

        /////////
        // Case 2
        /////////

        // Reset the PRBS checker
        $display("Reset the PRBS tester (case 2)");
        `FORCE_JTAG(prbs_checker_mode, 0);
        #(50ns);

        // run the PRBS tester, but inject an error in the middle
        $display("Running the PRBS tester (case 2)");
        `FORCE_JTAG(prbs_checker_mode, 2);
        #(300ns);
        `FORCE_JTAG(prbs_gen_inj_err, 1);
        #(25ns);
        `FORCE_JTAG(prbs_gen_inj_err, 0);
        #(300ns);

        // get results
        `FORCE_JTAG(prbs_checker_mode, 3);
        #(10ns);

        err_bits_2 = 0;
        err_bits_2 |= `GET_JTAG(prbs_err_bits_upper);
        err_bits_2 <<= 32;
        err_bits_2 |= `GET_JTAG(prbs_err_bits_lower);

        total_bits_2 = 0;
        total_bits_2 |= `GET_JTAG(prbs_total_bits_upper);
        total_bits_2 <<= 32;
        total_bits_2 |= `GET_JTAG(prbs_total_bits_lower);

        // print results
        $display("err_bits_2: %0d", err_bits_2);
        $display("total_bits_2: %0d", total_bits_2);

        ////////////////
        // Check results
        ////////////////

        if (!(total_bits_0 >= 9500)) begin
            $error("Not enough bits transmitted (case 0)");
        end else begin
            $display("Number of bits transmitted is OK (case 0)");
        end

        if (!(err_bits_0 == 0)) begin
            $error("Bit error detected (case 0)");
        end else begin
            $display("No bit errors detected (case 0)");
        end

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
