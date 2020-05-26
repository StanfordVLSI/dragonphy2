`include "mLingua_pwl.vh"
//`include "mdll_param.vh"

`define FORCE_TDBG(name, value) force top_i.adbg_intf_i.``name`` = ``value``
`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

`ifndef TI_ADC_TXT
    `define TI_ADC_TXT
`endif

`ifndef TI_ADC_TXT_2
    `define TI_ADC_TXT_2 (`TI_ADC_TXT+"2")
`endif

`ifndef EXT_PFD_OFFSET
    `define EXT_PFD_OFFSET 16
`endif

`ifndef N_INTERVAL
    `define N_INTERVAL 100
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
	pwl sin_outp;
	pwl sin_outn;
	pwl max_outp;
	pwl max_outn;

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

	// Save signals for post-processing

	logic should_record;
	logic should_record2;
	logic recording_clk;
    //logic signed [Nadc-0:0] adcout_unfolded [Nti-1:0];
   
	 ti_adc_recorder #(
        .filename(`TI_ADC_TXT)
    ) ti_adc_recorder_i (
		.in(top_i.idcore.adcout_unfolded[15:0]),
		.clk(recording_clk),
		.en(should_record)
	);

	 ti_adc_recorder #(
        .filename(`TI_ADC_TXT_2)
    ) ti_adc_recorder_i2 (
		.in(top_i.idcore.adcout_unfolded[15:0]),
		.clk(recording_clk),
		.en(should_record2)
	);

    always @(posedge top_i.idcore.clk_adc) begin
       // pulse the recording clock
        recording_clk = 1'b1;
        #(1ps);
        recording_clk = 1'b0;
        #(1ps);
    end


    // Sine wave stimulus

    sine_stim #(
        .Vcm(0.4),
        .sine_ampl(0.1),
        .sine_freq(1.023e9)
    ) sine_stim_i (
		.ch_outp(sin_outp),
		.ch_outn(sin_outn)
	);

    // max input voltage stimulus
    real Vmaxp = 0.4 + 0.1;
    real Vmaxn = 0.4 - 0.1;
    real2pwl pwl_maxp (
        .en(1'b1),
        .in(Vmaxp),
        .out(max_outp)
    );
    real2pwl pwl_maxn (
        .en(1'b1),
        .in(Vmaxn),
        .out(max_outn)
    );


    // input selection
    logic select_sin;
    always @(*) begin
        ch_outp = select_sin ? sin_outp : max_outp;
        ch_outn = select_sin ? sin_outn : max_outn;
    end


/*
    // Re-ordering
    // TODO: clean this up because it is likely a real bug
	
	integer tmp;
	//teger idx_order [Nti] = '{0, 5, 10, 15,
	//                         1, 6, 11, 12,
	//                         2, 7,  8, 13,
	//                         3, 4,  9, 14};
	
    integer idx_order [Nti] = '{0, 4, 8, 12,
	                         	1, 5, 9, 13,
	                         	2, 6, 10, 14,
	                         	3, 7, 11, 15};
    
	always @(posedge top_i.idcore.clk_adc) begin
        // compute the unfolded ADC outputs
        for (int k=0; k<Nti; k=k+1) begin
            // compute output
             tmp = top_i.idcore.adcout_sign[idx_order[k]] ?
                  top_i.idcore.adcout[idx_order[k]] - (`EXT_PFD_OFFSET) :
                  (`EXT_PFD_OFFSET) - top_i.idcore.adcout[idx_order[k]];
			
			// clamp
            if (tmp > 255) begin
                tmp = 255;
            end
            if (tmp < -255) begin
                tmp = -255;
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
*/

	// Main test

	logic [Nadc-1:0] tmp_ext_pfd_offset [Nti-1:0];

	initial begin
        `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif


        // initialize control signals
		should_record = 1'b0;
        should_record2 = 1'b0;
		recording_clk = 1'b0;
        select_sin = 1'b1;
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
        `FORCE_DDBG(int_rstb, 1);
        #(1ns);
        `FORCE_ADBG(en_inbuf, 1);
		#(1ns);
        `FORCE_ADBG(en_gf, 1);
        #(1ns);
        `FORCE_ADBG(en_v2t, 1);
        #(64ns);

        // Set up the PFD offset
        $display("Setting up the PFD offset...");
        for (int idx=0; idx<Nti; idx=idx+1) begin
            tmp_ext_pfd_offset[idx] = `EXT_PFD_OFFSET;
        end
        `FORCE_DDBG(ext_pfd_offset, tmp_ext_pfd_offset);
        #(1ns);

        // apply the stimulus
        $display("Setting up the PI control codes...");
        force top_i.idcore.int_pi_ctl_cdr[0] = 0;
        force top_i.idcore.int_pi_ctl_cdr[1] = 67;
        force top_i.idcore.int_pi_ctl_cdr[2] = 133;
        force top_i.idcore.int_pi_ctl_cdr[3] = 200;
        #(5ns);

        // toggle the en_v2t signal to re-initialize the V2T ordering
        `FORCE_ADBG(en_v2t, 0);
        #(5ns);
        `FORCE_ADBG(en_v2t, 1);
        #(5ns);

		// Wait some time initially
		$display("Initial delay of 50 ns...");
		#(100ns);

		// Then record for awhile
		should_record = 1'b1;
		for (int k=0; k<(`N_INTERVAL); k=k+1) begin
		    $display("Test (1 of 2) is %0.1f%% complete.", (100.0*k)/(1.0*(`N_INTERVAL)));
		    #((`INTERVAL_LENGTH)*1s);
		end

        should_record = 1'b0;


        // Now do phase doubling
        select_sin = 1'b0;

        #(10ns);

        `FORCE_TDBG(en_TDC_phase_reverse, 1);

        #(10ns);

        //`FORCE_TDBG(en_TDC_phase_reverse, 0);

        #(10ns);

        // re-run test now
        select_sin = 1'b1;

        #(10ns);


		should_record2 = 1'b1;
		for (int k=0; k<(`N_INTERVAL); k=k+1) begin
		    $display("Test (2 of 2) is %0.1f%% complete.", (100.0*k)/(1.0*(`N_INTERVAL)));
		    #((`INTERVAL_LENGTH)*1s);
		end
        should_record2 = 1'b0;

		$finish;
	end
endmodule
