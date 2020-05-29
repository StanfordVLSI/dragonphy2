`include "mLingua_pwl.vh"

`define FORCE_JTAG(name, value) force top_i.idcore.jtag_i.rjtag_intf_i.``name`` = ``value``

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
	real v_cm = 0.4;
	dragonphy_top top_i (
	    // analog inputs
		.ext_rx_inp(ch_outp),
		.ext_rx_inn(ch_outn),
		.ext_Vcm(v_cm),

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

	// Save signals for post-processing

	logic should_record;
    logic signed [Nadc-1:0] adcout_unfolded [Nti-1:0];
   
	 ti_adc_recorder #(
        .filename(`TI_ADC_TXT)
    ) ti_adc_recorder_i (
		.in(top_i.idcore.adcout_unfolded[15:0]),
		.clk(top_i.clk_adc),
		.en(should_record)
	);

    tx_output_recorder tx_output_recorder_i (
        .in(tx_data),
        .clk(tx_clk),
        .en(should_record)
    );

	// Main test

	logic [Nadc-1:0] tmp_ext_pfd_offset [Nti-1:0];
    logic [Npi-1:0] tmp_bypass_pi_ctl [Nout-1:0];

	initial begin
        `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif

        // initialize control signals
		should_record = 1'b0;
        rstb = 1'b0;
        #(1ns);

		// Release reset
		$display("Releasing external reset...");
		rstb = 1'b1;
        #(32ns);

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

        // apply the stimulus
        $display("Setting up the PI control codes...");
        tmp_bypass_pi_ctl[0] = 0;
        tmp_bypass_pi_ctl[1] = 67;
        tmp_bypass_pi_ctl[2] = 133;
        tmp_bypass_pi_ctl[3] = 200;
        `FORCE_JTAG(bypass_pi_ctl, tmp_bypass_pi_ctl);
        `FORCE_JTAG(en_bypass_pi_ctl, 1);
        #(5ns);

        // toggle the en_v2t signal to re-initialize the V2T ordering
        `FORCE_JTAG(en_v2t, 0);
        #(5ns);
        `FORCE_JTAG(en_v2t, 1);
        #(5ns);

		// Wait some time initially
		$display("Initial delay of 50 ns...");
		#(100ns);

		// Then record for awhile
		should_record = 1'b1;
		for (int k=0; k<(`N_INTERVAL); k=k+1) begin
		    $display("Test is %0.1f%% complete.", (100.0*k)/(1.0*(`N_INTERVAL)));
		    #((`INTERVAL_LENGTH)*1s);
		end

		$finish;
	end
endmodule
