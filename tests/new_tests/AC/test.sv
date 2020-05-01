`include "mLingua_pwl.vh"

`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

`ifndef TI_ADC_TXT
    `define TI_ADC_TXT
`endif

`ifndef EXT_PFD_OFFSET
    `define EXT_PFD_OFFSET 16
`endif

`ifndef N_INTERVAL
    `define N_INTERVAL 10
`endif

`ifndef INTERVAL_LENGTH
    `define INTERVAL_LENGTH 10e-9
`endif

module test;
	import test_pack::*;
	import checker_pack::*;
    import const_pack::Nti;
    import const_pack::Nadc;
    import const_pack::Nout;
    import const_pack::Npi;

	// clock inputs

	logic ext_clkp;
	logic ext_clkn;

	// reset

	logic rstb;

	// JTAG driver

	jtag_intf jtag_intf_i ();
	jtag_drv jtag_drv_i (jtag_intf_i);

	// Analog inputs

	pwl ch_outp;
	pwl ch_outn;

	// instantiate top module

	dragonphy_top top_i (
	    // analog inputs
		.ext_rx_inp(ch_outp),
		.ext_rx_inn(ch_outn),
		.ext_Vcm(v_cm),
	    .ext_Vcal(0.23),

		// clock inputs
		.ext_clkp(ext_clkp),
		.ext_clkn(ext_clkn),

        // reset
        .ext_rstb(rstb),

        // JTAG
		.jtag_intf_i(jtag_intf_i)
		// other I/O not used..
	);

	// External clock

    localparam real ext_clk_freq = full_rate/2;
	clock #(
		.freq(ext_clk_freq),
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	);

	// Save signals for post-processing

	logic should_record;
	logic recording_clk;
    logic signed [Nadc-1:0] adcout_unfolded [Nti-1:0];
    ti_adc_recorder #(
        .filename(`TI_ADC_TXT)
    ) ti_adc_recorder_i (
		.in(adcout_unfolded),
		.clk(recording_clk),
		.en(should_record)
	);

    // Sine wave stimulus

    sine_stim #(
        .Vcm(0.4),
        .sine_ampl(0.2),
        .sine_freq(1.023e9)
    ) sine_stim_i (
		.ch_outp(ch_outp),
		.ch_outn(ch_outn)
	);

    // Re-ordering
    // TODO: clean this up because it is likely a real bug
	integer tmp;
	integer idx_order [Nti] = '{0, 5, 10, 15,
	                            1, 6, 11, 12,
	                            2, 7,  8, 13,
	                            3, 4,  9, 14};
    always @(posedge top_i.idcore.clk_adc) begin
        // compute the unfolded ADC outputs
        for (int k=0; k<Nti; k=k+1) begin
            // compute output
            tmp = top_i.idcore.adcout_sign[idx_order[k]] ?
                  top_i.idcore.adcout[idx_order[k]] - (`EXT_PFD_OFFSET) :
                  (`EXT_PFD_OFFSET) - top_i.idcore.adcout[idx_order[k]];
            // clamp
            if (tmp > 127) begin
                tmp = 127;
            end
            if (tmp < -128) begin
                tmp = -128;
            end
            // assign to output vector
            adcout_unfolded[k] = tmp;
        end
        // pulse the recording clock
        recording_clk = 1'b1;
        #(1ps);
        recording_clk = 1'b0;
        #(1ps);
    end

	// Main test
	logic [Npi-1:0] tmp_ext_pi_ctl_offset [Nout-1:0];
	logic [Nadc-1:0] tmp_ext_pfd_offset [Nti-1:0];
	initial begin
		// Uncomment to probe waveforms
		// $shm_open("out.shm");
		// $shm_probe("ASM");

		// Initialize pins
		$display("Initializing pins...");
		should_record = 1'b0;
		recording_clk = 1'b0;
		jtag_drv_i.init();

		// Toggle reset
		$display("Toggling reset...");
        #(20ns);
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;

		// Enable the input buffer
		$display("Set up the input buffer...");
        `FORCE_ADBG(en_inbuf, 0);
        #(1ns);
        `FORCE_ADBG(en_inbuf, 1);
        #(1ns);
		`FORCE_ADBG(en_gf, 1);
        #(1ns);
        `FORCE_DDBG(int_rstb, 1);
        #(1ns);

        // Set up the PFD offset
        $display("Setting up the PFD offset...");
        for (int idx=0; idx<Nti; idx=idx+1) begin
            tmp_ext_pfd_offset[idx] = `EXT_PFD_OFFSET;
        end
        `FORCE_DDBG(ext_pfd_offset, tmp_ext_pfd_offset);
        #(1ns);

        // apply the stimulus
        $display("Setting up the PI control codes...");
        tmp_ext_pi_ctl_offset[0] = 0;
        tmp_ext_pi_ctl_offset[1] = 67;
        tmp_ext_pi_ctl_offset[2] = 133;
        tmp_ext_pi_ctl_offset[3] = 200;
        force top_i.idcore.int_pi_ctl_cdr[0] = tmp_ext_pi_ctl_offset[0];
        force top_i.idcore.int_pi_ctl_cdr[1] = tmp_ext_pi_ctl_offset[1];
        force top_i.idcore.int_pi_ctl_cdr[2] = tmp_ext_pi_ctl_offset[2];
        force top_i.idcore.int_pi_ctl_cdr[3] = tmp_ext_pi_ctl_offset[3];

        // toggle the CDR clock a few times
        // TODO: fix this!  this may be a real bug
        for (int k=0; k<5; k=k+1) begin
            force top_i.idcore.clk_cdr = 1'b1;
            #(1ns);
            force top_i.idcore.clk_cdr = 1'b0;
            #(1ns);
        end
        release top_i.idcore.clk_cdr;

        // Enable the V2T
        `FORCE_ADBG(en_v2t, 1);
        #(1ns);

		// Wait some time initially
		$display("Initial delay of 50 ns...");
		#(50ns);

		// Then record for awhile
		should_record = 1'b1;
		for (int k=0; k<(`N_INTERVAL); k=k+1) begin
		    $display("Test is %0.1f%% complete.", (100.0*k)/(1.0*(`N_INTERVAL)));
		    #((`INTERVAL_LENGTH)*1s);
		end

		$finish;
	end
endmodule