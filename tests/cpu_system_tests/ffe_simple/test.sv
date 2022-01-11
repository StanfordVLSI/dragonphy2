`include "mLingua_pwl.vh"

`define FORCE_JTAG(name, value) force top_i.idcore.jtag_i.rjtag_intf_i.``name`` = ``value``


`ifndef ADC_TXT
    `define ADC_TXT
`endif

`ifndef FFE_TXT
    `define FFE_TXT
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

    // TODO don't hard code these weight manager parameters
    localparam integer width = 16;
    localparam integer depth = 10;
    localparam integer bitwidth= 10;

    logic signed [bitwidth-1:0] value;

    initial begin
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
    end

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
	logic recording_clk;
   
	 ti_adc_recorder #(
        .filename(`ADC_TXT)
    ) adc_recorder_i (
		.in(top_i.idcore.adcout_unfolded[15:0]),
		.clk(recording_clk),
		.en(should_record)
	);
   

    logic signed [7:0] estimated_bits [15:0];
    genvar gi;
    generate
        for(gi = 0; gi < 16; gi = gi + 1) begin
            assign estimated_bits[gi] = top_i.idcore.estimated_bits[gi][7:0];
        end
    endgenerate

	 ti_adc_recorder #(
        .filename(`FFE_TXT)
    ) ffe_recorder_i (
		.in(estimated_bits),
		.clk(recording_clk),
		.en(should_record)
	);

    tx_output_recorder tx_output_recorder_i (
        .in(tx_data),
        .clk(tx_clk),
        .en(should_record)
    );

    always @(posedge top_i.idcore.clk_adc) begin
       // pulse the recording clock
        recording_clk = 1'b1;
        #(1ps);
        recording_clk = 1'b0;
        #(1ps);
    end

	// Main test

	logic [Nadc-1:0] tmp_ext_pfd_offset [Nti-1:0];
    logic [4:0] tmp_ffe_shift [Nti-1:0];
	initial begin
        integer ii, jj;

        `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif

        // initialize control signals
		should_record = 1'b0;
		recording_clk = 1'b0;
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

        for (int idx=0; idx <Nti; idx=idx+1) begin
            tmp_ffe_shift[idx] = 0;
        end
        `FORCE_JTAG(ffe_shift, tmp_ffe_shift);
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
        force top_i.idcore.int_pi_ctl_cdr[0] = 0;
        force top_i.idcore.int_pi_ctl_cdr[1] = 67;
        force top_i.idcore.int_pi_ctl_cdr[2] = 133;
        force top_i.idcore.int_pi_ctl_cdr[3] = 200;
        #(5ns);

        // toggle the en_v2t signal to re-initialize the V2T ordering
        `FORCE_JTAG(en_v2t, 0);
        #(5ns);
        `FORCE_JTAG(en_v2t, 1);
        #(5ns);


        $display("Loading FFE weights");
        // Load new FFE weights
        for(ii = 0; ii < width; ii = ii + 1) begin
            load(9, ii, 1);
            $display("\tFinished %d of %d", ii+1, width);
        end


		// Wait some time initially
		$display("Initial delay of 50 ns...");
		#(120ns);
		// Then record for awhile
        record_bits();

        $display("Loading FFE weights for diff");
        // Load new FFE weights
        for(ii = 0; ii < width; ii = ii + 1) begin
            load(8, ii, -4);
            $display("\tFinished %d of %d", ii+1, width);
        end
        for (int idx=0; idx <Nti; idx=idx+1) begin
            // shift of 2+5 is divide by 128
            tmp_ffe_shift[idx] = 2;
        end
        `FORCE_JTAG(ffe_shift, tmp_ffe_shift);
		// Then record for awhile
        record_bits();

        $display("Loading larger set of weights");
        // Load new FFE weights
        for(ii = 0; ii < width; ii = ii + 1) begin
            load(9, ii, 10);
            load(8, ii, 8);
            load(7, ii, -12);
            load(6, ii, 10);
            load(5, ii, 3);
            load(4, ii, -7);
            load(3, ii, 3);
            load(2, ii, -12);
            load(1, ii, -2);
            load(0, ii, 1);
            $display("\tFinished %d of %d", ii+1, width);
        end

        for (int idx=0; idx <Nti; idx=idx+1) begin
            // shift of 2+5 is divide by 128
            tmp_ffe_shift[idx] = 7;
        end
        `FORCE_JTAG(ffe_shift, tmp_ffe_shift);

		// Then record for awhile
        record_bits();
		$finish;
	end

    task record_bits;
		should_record = 1'b1;
		for (int k=0; k<(`N_INTERVAL); k=k+1) begin
		    $display("Current test is %0.1f%% complete.", (100.0*k)/(1.0*(`N_INTERVAL)));
		    #((`INTERVAL_LENGTH)*1s);
		end
        should_record = 1'b0;
    endtask

    task load(input logic [$clog2(depth)-1:0] d_idx, logic [$clog2(width)-1:0] w_idx, logic [bitwidth-1:0] value);
        force top_i.idcore.wdbg_intf_i.wme_ffe_inst[$clog2(depth)+$clog2(width)] = 0;
        force top_i.idcore.wdbg_intf_i.wme_ffe_inst[$clog2(depth)+$clog2(width)-1:$clog2(depth)] = w_idx;
        force top_i.idcore.wdbg_intf_i.wme_ffe_inst[$clog2(depth)-1:0] = d_idx;
        force top_i.idcore.wdbg_intf_i.wme_ffe_data[bitwidth-1:0] = value;
        toggle_exec();
    endtask

    task toggle_exec;
        // TODO on the actual chip we can't change wme_ffe_exec with precise timing
        @(posedge top_i.idcore.clk_adc) force top_i.idcore.wdbg_intf_i.wme_ffe_exec=1;
        @(posedge top_i.idcore.clk_adc) force top_i.idcore.wdbg_intf_i.wme_ffe_exec=0;
    endtask

endmodule
