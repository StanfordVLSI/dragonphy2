`timescale 1s/1fs

`include "mLingua_pwl.vh"

`define FORCE_JTAG(name, value) force top_i.idcore.jtag_i.rjtag_intf_i.``name`` = ``value``
`define GET_JTAG(name) top_i.idcore.jtag_i.rjtag_intf_i.``name``

module test;

	import const_pack::*;
	import jtag_reg_pack::*;

    import ffe_gpack::length;
    import ffe_gpack::weight_precision;
    import constant_gpack::channel_width;

    localparam real dt=1.0/(16.0e9);
    localparam real tau=25.0e-12;
    localparam integer coeff0 = 128.0/(1.0-$exp(-dt/tau));
    localparam integer coeff1 = -128.0*$exp(-dt/tau)/(1.0-$exp(-dt/tau));

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

    real inp, inn;
    assign inp = ch_outp.a;
    assign inn = ch_outn.a;

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
        .freq(16.0e9),
        .td(31.25e-12)
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

    diff_channel #(
        .tau(tau)
    ) diff_channel_i (
        .in_p(tx_p),
        .in_n(tx_n),
        .out_p(ch_outp),
        .out_n(ch_outn)
    );

	// External clock

	clock #(
		.freq(8.0e9), // This depends on the frequency divider in the ACORE's input buffer
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	);

    //  Main test

	logic [Nadc-1:0] tmp_ext_pfd_offset [Nti-1:0];
    logic [Npi-1:0] tmp_ext_pi_ctl_offset [Nout-1:0];
    logic [Nprbs-1:0] tmp_prbs_eqn;

    integer loop_var, loop_var2;
    integer offset;

    longint err_bits, total_bits;

    logic [ffe_gpack::shift_precision-1:0] tmp_ffe_shift [constant_gpack::channel_width-1:0];

    // for loading one FFE weight with specified depth and width
    task load_weight(
        input logic [$clog2(length)-1:0] d_idx,
        logic [$clog2(channel_width)-1:0] w_idx,
        logic [weight_precision-1:0] value
    );
        $display("Loading weight d_idx=%0d, w_idx=%0d with value %0d", d_idx, w_idx, value);
        `FORCE_JTAG(wme_ffe_inst, {1'b0, w_idx, d_idx});
        `FORCE_JTAG(wme_ffe_data, value);
        #(3ns);
        `FORCE_JTAG(wme_ffe_exec, 1);
        #(3ns);
        `FORCE_JTAG(wme_ffe_exec, 0);
        #(3ns);
    endtask

    function real get_time();
        // this function is modified from:
        // https://verificationguide.com/how-to/how-to-display-system-time-in-systemverilog/

        int file_pointer;

        // Stores time and date to file tmp_sys_time
        void'($system("date +%s.%N > tmp_sys_time"));

        // Open the file tmp_sys_time with read access
        file_pointer = $fopen("tmp_sys_time", "r");

        // Assign the value from file to variable
        void'($fscanf(file_pointer, "%f", get_time));

        // Close the file
        $fclose(file_pointer);

        // Remove file tmp_sys_time
        void'($system("rm tmp_sys_time"));
    endfunction

    real start_time;
    real stop_time;

	initial begin
        `ifdef DUMP_WAVEFORMS
            // Set up probing
            $shm_open("waves.shm");
            $shm_probe("ASMC");
        `endif

        // print test condition
        $display("tau=%0.3f (ps)", tau*1.0e12);

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
            tmp_ext_pfd_offset[idx] = 0;
        end
        `FORCE_JTAG(ext_pfd_offset, tmp_ext_pfd_offset);
        #(1ns);

        // Set the equation for the PRBS checker
        $display("Setting the PRBS equation");
        tmp_prbs_eqn = 0;
        tmp_prbs_eqn[ 1] = 1'b1;
        tmp_prbs_eqn[20] = 1'b1;
        `FORCE_JTAG(prbs_eqn, tmp_prbs_eqn);
        #(10ns);

        // Select the PRBS checker data source
        $display("Select the PRBS checker data source");
        `FORCE_JTAG(sel_prbs_mux, 2'b01); // 2'b00: ADC, 2'b01: FFE
        #(10ns);

        // Release the PRBS checker from reset
        $display("Release the PRBS tester from reset");
        `FORCE_JTAG(prbs_rstb, 1);
        #(50ns);

        // Set up the FFE
        for (loop_var=0; loop_var<Nti; loop_var=loop_var+1) begin
            for (loop_var2=0; loop_var2<ffe_gpack::length; loop_var2=loop_var2+1) begin
                if (loop_var2 == 0) begin
                    // The argument order for load() is depth, width, value
                    load_weight(loop_var2, loop_var, coeff0);
                end else if (loop_var2 == 1) begin
                    load_weight(loop_var2, loop_var, coeff1);
                end else begin
                    load_weight(loop_var2, loop_var, 0);
                end
            end
            tmp_ffe_shift[loop_var] = 7;
        end
        `FORCE_JTAG(ffe_shift, tmp_ffe_shift);

        #(10ns);

        // Configure the CDR offsets
        $display("Setting up the CDR offset...");
        tmp_ext_pi_ctl_offset[0] =   0;
        tmp_ext_pi_ctl_offset[1] = 128;
        tmp_ext_pi_ctl_offset[2] = 256;
        tmp_ext_pi_ctl_offset[3] = 384;
        `FORCE_JTAG(ext_pi_ctl_offset, tmp_ext_pi_ctl_offset);
        #(5ns);
        `FORCE_JTAG(en_ext_max_sel_mux, 1);
        #(5ns);

        // Configure the retimer
        `FORCE_JTAG(retimer_mux_ctrl_1, 16'hFFFF);
        `FORCE_JTAG(retimer_mux_ctrl_2, 16'hFFFF);
        #(5ns);

        // Configure the CDR
      	$display("Configuring the CDR...");
      	`FORCE_JTAG(Kp, 18);
      	`FORCE_JTAG(Ki, 0);
      	`FORCE_JTAG(invert, 1);
		`FORCE_JTAG(en_freq_est, 0);
		`FORCE_JTAG(en_ext_pi_ctl, 0);
		`FORCE_JTAG(sel_inp_mux, 1); // "0": use ADC output, "1": use FFE output
		#(10ns);

        // Toggle the en_v2t signal to re-initialize the V2T ordering
        $display("Toggling en_v2t...");
        `FORCE_JTAG(en_v2t, 0);
        #(5ns);
        `FORCE_JTAG(en_v2t, 1);
        #(5ns);

		// Wait for MM_CDR to lock
		$display("Waiting for MM_CDR to lock...");
		for (loop_var=0; loop_var<2; loop_var=loop_var+1) begin
		    $display("Interval %0d/2", loop_var);
		    #(100ns);
		end

        // Run the PRBS tester

        // Nothing is printed out during the test to get the most aggressive (i.e. fairest)
        // throughput comparison when examining FPGA vs. CPU performance.

        $display("Running the PRBS tester");
        `FORCE_JTAG(prbs_checker_mode, 2);

        start_time = get_time();
        #(37.5us);
		stop_time = get_time();

        // Print out results of runtime experiment
        $display("PRBS test took %0f seconds.", stop_time - start_time);

        // Get results
        `FORCE_JTAG(prbs_checker_mode, 3);
        #(10ns);

        err_bits = 0;
        err_bits |= `GET_JTAG(prbs_err_bits_upper);
        err_bits <<= 32;
        err_bits |= `GET_JTAG(prbs_err_bits_lower);

        total_bits = 0;
        total_bits |= `GET_JTAG(prbs_total_bits_upper);
        total_bits <<= 32;
        total_bits |= `GET_JTAG(prbs_total_bits_lower);

        // Print results
        $display("err_bits: %0d", err_bits);
        $display("total_bits: %0d", total_bits);

        // Check results

        if (!(total_bits >= 9500)) begin
            $error("Not enough bits transmitted");
        end else begin
            $display("Number of bits transmitted is OK");
        end

        if (!(err_bits == 0)) begin
            $error("Bit error detected");
        end else begin
            $display("No bit errors detected");
        end

		// Finish test
		$display("Test complete.");
		$finish;
    end
endmodule
