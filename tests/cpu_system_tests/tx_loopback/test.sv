`include "mLingua_pwl.vh"

`define FORCE_JTAG(name, value) force top_i.idcore.jtag_i.rjtag_intf_i.``name`` = ``value``
`define GET_JTAG(name) top_i.idcore.jtag_i.rjtag_intf_i.``name``

`ifndef EXT_PFD_OFFSET
    `define EXT_PFD_OFFSET 16
`endif

// comment out to directly feed ADC data to CDR
`define CDR_USE_FFE

module test;

	import const_pack::*;
	import test_pack::*;
	import jtag_reg_pack::*;

    localparam real dt=1.0/(16.0e9);
    localparam real bw=1.0e9;
    localparam real tau=1.0/(2.0*3.14*bw);
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

    logic tx_outp;
    logic tx_outn;

	dragonphy_top top_i (
	    // analog inputs
		.ext_rx_inp(ch_outp),
		.ext_rx_inn(ch_outn),

        // analog outputs
        .ext_tx_outp(tx_outp),
        .ext_tx_outn(tx_outn),

		// external clocks
		.ext_clkp(ext_clkp),
		.ext_clkn(ext_clkn),

		// reset
        .ext_rstb(rstb),

        // JTAG
		.jtag_intf_i(jtag_intf_i)

		// other I/O not used...
	);

    // TX driver
    // TODO: when TX driver is implemented on-chip, this
    // block can be removed

    pwl tx_p;
    pwl tx_n;

    diff_tx_driver diff_tx_driver_i (
        .in(tx_outp),
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
		.freq(full_rate/2), // This depends on the frequency divider in the ACORE's input buffer
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	);

    //  Main test

	logic [Nadc-1:0] tmp_ext_pfd_offset [Nti-1:0];
    logic [Npi-1:0] tmp_ext_pi_ctl_offset [Nout-1:0];
    logic [Npi-1:0] tmp_tx_pi_ctl [Nout-1:0];
    logic [Nprbs-1:0] tmp_prbs_eqn;

    integer loop_var, loop_var2;
    integer offset;

    longint err_bits, total_bits;

    logic [ffe_gpack::shift_precision-1:0] tmp_ffe_shift [constant_gpack::channel_width-1:0];

	initial begin
        `ifdef DUMP_WAVEFORMS
            // Set up probing
            $shm_open("waves.shm");

            // transmitter data signal signals
            $shm_probe(top_i.idcore.tx_data_gen_i);
            $shm_probe(top_i.idcore.tx_data_gen_i.exec_m);
            $shm_probe(top_i.idcore.tx_data_gen_i.exec_d);
            $shm_probe(top_i.idcore.tx_data_gen_i.rst_d);
            $shm_probe(top_i.idcore.tx_data_gen_i.cke_d);
            $shm_probe(top_i.idcore.tx_data_gen_i.data_mode_d);
            $shm_probe(top_i.idcore.tx_data_gen_i.data_per_d);
            $shm_probe(top_i.idcore.tx_data_gen_i.data_in_d);
            $shm_probe(top_i.idcore.tx_data_gen_i.prbs_init_d);
            $shm_probe(top_i.idcore.tx_data_gen_i.prbs_eqn_d);
            $shm_probe(top_i.idcore.tx_data_gen_i.prbs_inj_err_d);
            $shm_probe(top_i.idcore.tx_data_gen_i.prbs_chicken_d);
            $shm_probe(top_i.idcore.tx_data_gen_i.prbs_out);
            $shm_probe(top_i.idcore.tx_data_gen_i.data_out_reg);
            $shm_probe(top_i.idcore.tx_data_gen_i.counter);

            // transmitter signals
            $shm_probe(top_i.itx);
            $shm_probe(top_i.itx.clk_halfrate);
            $shm_probe(top_i.itx.clk_halfrate_n);

            // PI controls
            $shm_probe(top_i.idcore.int_pi_ctl_cdr);
            $shm_probe(top_i.idcore.ctl_valid);
            $shm_probe(top_i.idcore.tx_pi_ctl);
            $shm_probe(top_i.idcore.tx_ctl_valid);
        `endif

        // print test condition
        $display("bw=%0.3f (GHz)", bw/1.0e9);
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
        `FORCE_JTAG(tx_rst, 0);
        #(1ns);
        `FORCE_JTAG(en_inbuf, 1);
        `FORCE_JTAG(tx_en_inbuf, 1);
		#(1ns);
        `FORCE_JTAG(en_gf, 1);
        `FORCE_JTAG(tx_en_gf, 1);
        #(1ns);

        // set the TX PI codes
        // these are selected so that the optimal
        // PI codes of the RX will be in a good range
        tmp_tx_pi_ctl[0] = 97;
        tmp_tx_pi_ctl[1] = 232;
        tmp_tx_pi_ctl[2] = 367;
        tmp_tx_pi_ctl[3] = 502;
        `FORCE_JTAG(tx_pi_ctl, tmp_tx_pi_ctl);
        #(1ns);
        `FORCE_JTAG(tx_ctl_valid, 1);
        #(1ns);

        // enable the V2T, which starts clk_adc
        `FORCE_JTAG(en_v2t, 1);
        #(64ns);

        // Set up the PFD offset
        $display("Setting up the PFD offset...");
        for (int idx=0; idx<Nti; idx=idx+1) begin
            tmp_ext_pfd_offset[idx] = `EXT_PFD_OFFSET;
        end
        `FORCE_JTAG(ext_pfd_offset, tmp_ext_pfd_offset);
        #(1ns);

        // Set up the TX data generator
        // this needs to happen after the TX clocks have been
        // enabled, because it depends on the clock output
        // from the TX to the digital core
        $display("Setting up the TX data source...");
        `FORCE_JTAG(tx_data_gen_exec, 0);
        #(25ns);
        `FORCE_JTAG(tx_data_gen_rst, 0);
        `FORCE_JTAG(tx_data_gen_cke, 1);
        `FORCE_JTAG(tx_data_gen_mode, 4);  // 0: RESET, 1: CONSTANT, 2: PULSE, 3: SQUARE, 4: PRBS
        #(25ns);
        `FORCE_JTAG(tx_data_gen_exec, 1);
        #(25ns);
        `FORCE_JTAG(tx_data_gen_exec, 0);
        #(25ns);

        // Set the equation for the PRBS checker
        $display("Setting the PRBS equation");
        tmp_prbs_eqn = 0;
        tmp_prbs_eqn[ 1] = 1'b1;
        tmp_prbs_eqn[20] = 1'b1;
        `FORCE_JTAG(prbs_eqn, tmp_prbs_eqn);
        #(10ns);

        // Select the PRBS checker data source
        $display("Select the PRBS checker data source");
        `FORCE_JTAG(sel_prbs_mux, 2'b01);
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
                    load(loop_var2, loop_var, coeff0);
                end else if (loop_var2 == 1) begin
                    load(loop_var2, loop_var, coeff1);
                end else begin
                    load(loop_var2, loop_var, 0);
                end
            end
            tmp_ffe_shift[loop_var] = 7;
        end
        `FORCE_JTAG(ffe_shift, tmp_ffe_shift);

        #(10ns);

        // Configure the CDR offsets
        $display("Setting up the CDR offset...");
        tmp_ext_pi_ctl_offset[0] =   0;
        tmp_ext_pi_ctl_offset[1] = 135;
        tmp_ext_pi_ctl_offset[2] = 270;
        tmp_ext_pi_ctl_offset[3] = 405;
        `FORCE_JTAG(ext_pi_ctl_offset, tmp_ext_pi_ctl_offset);
        #(5ns);

        // Configure the CDR
      	$display("Configuring the CDR...");
      	`FORCE_JTAG(Kp, 18);
      	`FORCE_JTAG(Ki, 0);
      	`FORCE_JTAG(invert, 1);
		`FORCE_JTAG(en_freq_est, 0);
		`FORCE_JTAG(en_ext_pi_ctl, 0);
		`ifdef CDR_USE_FFE
		    `FORCE_JTAG(sel_inp_mux, 1);
		`endif
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
        $display("Running the PRBS tester");
        `FORCE_JTAG(prbs_checker_mode, 2);
        for (loop_var=0; loop_var<6; loop_var=loop_var+1) begin
		    $display("Interval %0d/6", loop_var);
		    #(100ns);
		end
        #(25ns);

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

    // for loading one FFE weight with specified depth and width
    task load(input logic [$clog2(ffe_gpack::length)-1:0] d_idx, logic [$clog2(constant_gpack::channel_width)-1:0] w_idx, logic [ffe_gpack::weight_precision-1:0] value);
        `FORCE_JTAG(wme_ffe_inst[$clog2(ffe_gpack::length)+$clog2(constant_gpack::channel_width)],  0);
        `FORCE_JTAG(wme_ffe_inst[$clog2(ffe_gpack::length)+$clog2(constant_gpack::channel_width)-1:$clog2(ffe_gpack::length)],  w_idx);
        `FORCE_JTAG(wme_ffe_inst[$clog2(ffe_gpack::length)-1:0],  d_idx);
        `FORCE_JTAG(wme_ffe_data[ffe_gpack::weight_precision-1:0],  value);
        toggle_exec();
    endtask

    task toggle_exec;
        // TODO on the actual chip we can't change wme_ffe_exec with precise timing
        @(posedge top_i.idcore.clk_adc) `FORCE_JTAG(wme_ffe_exec, 1);
        @(posedge top_i.idcore.clk_adc) `FORCE_JTAG(wme_ffe_exec, 0);
    endtask

endmodule
