`include "mLingua_pwl.vh"

`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

`ifndef RX_INPUT_TXT
    `define RX_INPUT_TXT
`endif

`ifndef TI_ADC_TXT
    `define TI_ADC_TXT
`endif

module test;
	import test_pack::*;
	import checker_pack::*;

	// clock inputs

	logic ext_clkp;
	logic ext_clkn;

	// reset

	logic rstb;

	// JTAG driver

	jtag_intf jtag_intf_i ();
	jtag_drv jtag_drv_i (jtag_intf_i);

    // stimulus parameters

	localparam real v_diff_min = -0.4;
	localparam real v_diff_max = +0.4;
	localparam real v_diff_step = 0.01;
	localparam real v_cm = 0.40;

	// mLingua initialization

	PWLMethod pm=new;

	// Analog inputs

	pwl ch_outp;
	pwl ch_outn;

	// instantiate top module

	dragonphy_top top_i (
	    // analog inputs
		.ext_rx_inp(ch_outp),
		.ext_rx_inn(ch_outn),
		.ext_Vcm(v_cm),
	    .ext_Vcal(0.6),

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

    // Data recording

    logic record;

    rx_input_recorder #(
        .filename(`RX_INPUT_TXT)
    ) rx_input_recorder_i (
		.in_p(ch_outp),
		.in_n(ch_outn),
		.clk(record),
		.en(1'b1)
	);

    ti_adc_recorder #(
        .filename(`TI_ADC_TXT)
    ) ti_adc_recorder_i (
		.in(top_i.idcore.adcout_unfolded[15:0]),
		.clk(record),
		.en(1'b1)
	);

	// Main test

	initial begin
		// Initialize pins
		$display("Initializing pins...");
		jtag_drv_i.init();

		// Toggle reset
		$display("Toggling reset...");
        #(20ns);
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;

		// Enable the input buffer
		$display("Set up the input buffer...");
		`FORCE_ADBG(en_gf, 1);
        #(1ns);
		`FORCE_ADBG(bypass_inbuf_div, 0);
		#(1ns);
        `FORCE_ADBG(en_inbuf, 1);
        #(1ns);
        `FORCE_ADBG(en_v2t, 1);
        #(1ns);
        `FORCE_DDBG(int_rstb, 1);
        #(1ns);

		// Wait a little bit to measure frequencies
		#(100ns);

        // Walk through differential input voltages
		for (real v_diff = v_diff_min;
		     v_diff <= v_diff_max + v_diff_step;
		     v_diff = v_diff + v_diff_step
		) begin
			ch_outp = pm.write(v_cm+v_diff/2.0, 0, 0);
			ch_outn = pm.write(v_cm-v_diff/2.0, 0, 0);

			$display("Differential input: %0.3f V", ch_outp.a-ch_outn.a);

			#(15ns);

			record = 1'b1;
			#(1ns);
			record = 1'b0;
		    #(1ns);
		end

		$finish;
	end
endmodule


