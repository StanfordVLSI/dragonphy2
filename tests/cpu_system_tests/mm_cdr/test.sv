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
        .freq(full_rate),
        .td(34.7e-12)
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
    logic [Nprbs-1:0] tmp_prbs_eqn;

    integer loop_var, loop_var2;
    integer offset;

    longint err_bits, total_bits;

    //logic signed [ffe_gpack::weight_precision-1:0] tmp_weights [constant_gpack::channel_width-1:0][ffe_gpack::length-1:0];
    logic [ffe_gpack::shift_precision-1:0] tmp_ffe_shift [constant_gpack::channel_width-1:0];

	initial begin
        `ifdef DUMP_WAVEFORMS
            // Set up probing
            $shm_open("waves.shm");

            // MM CDR instance
            $shm_probe(top_i.idcore.iMM_CDR.pi_ctl);
            $shm_probe(top_i.idcore.iMM_CDR.phase_error);
            $shm_probe(top_i.idcore.iMM_CDR.phase_est_update);
            $shm_probe(top_i.idcore.iMM_CDR.phase_est_d);
            $shm_probe(top_i.idcore.iMM_CDR.phase_est_out);

            // Calculating PI control codes
            $shm_probe(top_i.idcore.scale_value);
            $shm_probe(top_i.idcore.unscaled_pi_ctl);
            $shm_probe(top_i.idcore.scaled_pi_ctl);
            $shm_probe(top_i.idcore.int_pi_ctl_cdr);
            $shm_probe(top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset);
            $shm_probe(top_i.idcore.ddbg_intf_i.en_ext_max_sel_mux);
            $shm_probe(top_i.idcore.ddbg_intf_i.en_bypass_pi_ctl);
            $shm_probe(top_i.idcore.ddbg_intf_i.bypass_pi_ctl);
            $shm_probe(top_i.iacore.adbg_intf_i.max_sel_mux);

            // Number of error bits
            $shm_probe(top_i.idcore.prbs_checker_i.err_bits);
            $shm_probe(top_i.idcore.prbs_checker_i.err_signals);

            // clocks in analog_core
            $shm_probe(top_i.iacore.clk_interp_slice);
            $shm_probe(top_i.iacore.clk_interp_sw);

            // data in analog_core
            $shm_probe(inp);
            $shm_probe(inn);

            // data in digital_core
            $shm_probe(top_i.idcore.adcout_unfolded);
            $shm_probe(top_i.idcore.estimated_bits);
            $shm_probe(top_i.idcore.dsp_i.cffe_i.weights);
            $shm_probe(top_i.idcore.dsp_i.cffe_i.flat_codes);
            $shm_probe(top_i.idcore.dsp_i.cffe_i.disable_product);
            $shm_probe(top_i.idcore.dsp_i.cffe_i.shift_index);
            $shm_probe(top_i.idcore.dsp_dbg_intf_i.weights);
            $shm_probe(top_i.idcore.dsp_dbg_intf_i.ffe_shift);
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
