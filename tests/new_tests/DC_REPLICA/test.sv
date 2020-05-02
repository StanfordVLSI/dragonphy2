`include "mLingua_pwl.vh"

`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

`ifndef RX_INPUT_TXT
    `define RX_INPUT_TXT
`endif

`ifndef WIDTH_TXT
    `define WIDTH_TXT
`endif

`ifndef TI_ADC_TXT
    `define TI_ADC_TXT
`endif

`ifndef EXT_PFD_OFFSET
    `define EXT_PFD_OFFSET 16
`endif

module test;
	import test_pack::*;
	import checker_pack::*;
    import const_pack::Nti;
    import const_pack::Nadc;
    import const_pack::Nti_rep;

	// clock inputs

	logic ext_clkp;
	logic ext_clkn;

	// reset

	logic rstb;

	// JTAG driver

	jtag_intf jtag_intf_i ();
	jtag_drv jtag_drv_i (jtag_intf_i);

    // stimulus parameters

	localparam real v_diff_min = -0.40;
	localparam real v_diff_max = +0.40;
	localparam real v_diff_step = 0.0025;
	localparam real v_cm = 0.40;

	// mLingua initialization

	PWLMethod pm=new;

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

    // Measuring the width of the PFD output
    real width [Nti_rep];
    generate
        width_meas_ideal width_meas_inst_0 (
            .in(top_i.iacore.iADCrep0.pfd_out),
            .width(width[0])
        );
        width_meas_ideal width_meas_inst_1 (
            .in(top_i.iacore.iADCrep1.pfd_out),
            .width(width[1])
        );
    endgenerate

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

    real_array_recorder #(
        .n(Nti_rep),
        .filename(`WIDTH_TXT)
    ) width_recorder_i (
		.in(width),
		.clk(record),
		.en(1'b1)
	);

    ti_adc_recorder #(
         .num_channels(Nti_rep),
        .filename(`TI_ADC_TXT)
    ) ti_adc_recorder_i (
		.in(top_i.idcore.adcout_unfolded[Nti+Nti_rep-1:Nti]),
		.clk(record),
		.en(1'b1)
	);

	// Main test
	logic [Nadc-1:0] tmp_ext_pfd_offset_rep [Nti_rep-1:0];
	initial begin
        `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif

        // initialize control signals
    	record = 1'b0;
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
        #(1ns);

        // Enable replica slices
        $display("Enable replica slices...");
        `FORCE_ADBG(en_slice_rep, (1<<(Nti_rep))-1);
        #(1ns);

        // Set up the PFD offset
        $display("Set the PFD offset...");
        for (int idx=0; idx<Nti_rep; idx=idx+1) begin
            tmp_ext_pfd_offset_rep[idx] = `EXT_PFD_OFFSET;
        end
        `FORCE_DDBG(ext_pfd_offset_rep, tmp_ext_pfd_offset_rep);
        #(1ns);

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
