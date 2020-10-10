`include "mLingua_pwl.vh"

`define FORCE_JTAG(name, value) force top_i.idcore.jtag_i.rjtag_intf_i.``name`` = ``value``
`define GET_JTAG(name) top_i.idcore.jtag_i.rjtag_intf_i.``name``

`ifndef RX_INPUT_TXT
    `define RX_INPUT_TXT
`endif

`ifndef WIDTH_TXT
    `define WIDTH_TXT
`endif

`ifndef TI_ADC_TXT
    `define TI_ADC_TXT
`endif

module test;
	import test_pack::*;
	import checker_pack::*;
    import const_pack::Nti;
    import const_pack::Nadc;

	// clock inputs

	logic ext_clkp;
	logic ext_clkn;

	// reset

	logic rstb;

	// JTAG driver

	jtag_intf jtag_intf_i ();
	jtag_drv jtag_drv_i (jtag_intf_i);

    // stimulus parameters

	localparam real v_diff_min = -0.05;
	localparam real v_diff_max = +0.05;
	localparam real v_diff_step = 0.0025;
	localparam real v_cm = 0.40;

	// mLingua initialization

	PWLMethod pm=new;

	// Analog inputs

	pwl ch_outp_dc;
	pwl ch_outn_dc;

	pwl ch_outp_rand;
	pwl ch_outn_rand;

	pwl ch_outp;
	pwl ch_outn;

	// Random stimulus

    integer seed;
    initial begin
        seed = $urandom;
    end

    real diff_rand;

    always begin
        diff_rand = 0.07*($dist_uniform(seed, -1000, 1000)/1000.0);
        ch_outp_rand = pm.write(v_cm + 0.5*diff_rand, 0, 0);
        ch_outn_rand = pm.write(v_cm - 0.5*diff_rand, 0, 0);
        #(50ps);
    end

    // Select stimulus

    logic stim_sel;

    assign ch_outp = stim_sel ? ch_outp_dc : ch_outp_rand;
    assign ch_outn = stim_sel ? ch_outn_dc : ch_outn_rand;

	// instantiate top module

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

    // Measuring the width of the PFD output
    real width [Nti];
    generate
        for (genvar k=0; k<Nti; k=k+1) begin
            width_meas_ideal width_meas_inst (
                .in(top_i.iacore.iADC[k].iADC.pfd_out),
                .width(width[k])
            );
        end
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
        .n(Nti),
        .filename(`WIDTH_TXT)
    ) width_recorder_i (
		.in(width),
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
	logic [Nadc-1:0] tmp_ext_pfd_offset [Nti-1:0];
	logic signed [Nadc-1:0] tmp_pfd_offset [Nti-1:0];
	initial begin
        `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif

        // initialize control signals
    	record = 1'b0;
		rstb = 1'b0;
		stim_sel = 1'b0;
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
        #(1ns);

        // Set up the PFD calibration
        $display("Set up the PFD calibration...");
        for (int idx=0; idx<Nti; idx=idx+1) begin
            tmp_ext_pfd_offset[idx] = 0;
        end
        `FORCE_JTAG(ext_pfd_offset, tmp_ext_pfd_offset);
        #(1ns);
        `FORCE_JTAG(en_pfd_cal, 0);
        #(1ns);
        `FORCE_JTAG(en_ext_pfd_offset, 0);
        #(1ns);
        `FORCE_JTAG(Nbin_adc, 0);
        #(1ns);
        `FORCE_JTAG(Navg_adc, 7);
        #(1ns);
        `FORCE_JTAG(Ndiv_clk_avg, 7);
        #(1ns);
        `FORCE_JTAG(DZ_hist_adc, 3);
        #(1ns);

        // Wait for PFD calibration to be initialized
        $display("Wait for PFD calibration initialization...");
        #(150ns);

        // Wait for PFD calibration to settle
        $display("Wait for PFD calibration to settle...");
        `FORCE_JTAG(en_pfd_cal, 1);
        #(4us);

        // Print out the PFD offsets
        tmp_pfd_offset = `GET_JTAG(pfd_offset);
        for (int idx=0; idx<Nti; idx=idx+1) begin
            $display("pfd_offset[%0d]=%0d", idx, tmp_pfd_offset[idx]);
            if ((14 <= tmp_pfd_offset[idx]) && (tmp_pfd_offset[idx] <= 17)) begin
                // OK
            end else begin
                $error("PFD offset out of expected range.");
            end
        end

        // Walk through differential input voltages
        stim_sel = 1'b1;
		for (real v_diff = v_diff_min;
		     v_diff <= v_diff_max + v_diff_step;
		     v_diff = v_diff + v_diff_step
		) begin
			ch_outp_dc = pm.write(v_cm+v_diff/2.0, 0, 0);
			ch_outn_dc = pm.write(v_cm-v_diff/2.0, 0, 0);

			$display("Differential input: %0.3f V", ch_outp_dc.a-ch_outn_dc.a);
			#(15ns);

			$display("ADC out: %d",top_i.idcore.adcout_unfolded[0]);
			record = 1'b1;
			#(1ns);
			record = 1'b0;
		    #(1ns);
		end

		$finish;
	end
endmodule


