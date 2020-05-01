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
    `define N_INTERVAL 160
`endif

`ifndef INTERVAL_LENGTH
    `define INTERVAL_LENGTH 10e-9
`endif

module test;
	import test_pack::*;
	import checker_pack::*;
    import const_pack::Nti;
    import const_pack::Nti_rep;
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
		.ext_rx_inp_test(ch_outp),
		.ext_rx_inn_test(ch_outn),
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
    ti_adc_recorder #(
    	.num_channels(Nti_rep)
    ) ti_adc_recorder_i (
		.in(top_i.idcore.adcout_unfolded[Nti+Nti_rep-1:Nti]),
		.clk(top_i.idcore.clk_adc),
		.en(should_record)
	);

    // Sine wave stimulus
    sine_stim #(
        .Vcm(0.4),
        .sine_ampl(0.2),
        .sine_freq(12.3e6)
    ) sine_stim_i (
		.ch_outp(ch_outp),
		.ch_outn(ch_outn)
	);

	// Main test
	logic [Nadc-1:0] tmp_ext_pfd_offset_rep [Nti_rep-1:0];
	initial begin
		// Uncomment to probe waveforms
		// $shm_open("out.shm");
		// $shm_probe("ASM");

		// Initialize pins
		$display("Initializing pins...");
		should_record = 1'b0;
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
        // Enable the V2T
        `FORCE_ADBG(en_v2t, 1);
        #(1ns);
        // Enable the replica slices
        `FORCE_ADBG(en_slice_rep, (1<<(Nti_rep))-1);
        #(1ns);
        // Release from reset
        `FORCE_DDBG(int_rstb, 1);
        #(1ns);

        // Set up the PFD offset
        for (int idx=0; idx<Nti_rep; idx=idx+1) begin
            tmp_ext_pfd_offset_rep[idx] = `EXT_PFD_OFFSET;
        end
        `FORCE_DDBG(ext_pfd_offset_rep, tmp_ext_pfd_offset_rep);
        #(1ns);

        // run CDR clock fast to reduce simulation time
        // (the CDR clock is an input of the phase interpolator)
        `FORCE_DDBG(Ndiv_clk_cdr, 1);

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