`include "mLingua_pwl.vh"

`define FORCE_JTAG(name, value) force top_i.idcore.jtag_i.rjtag_intf_i.``name`` = ``value``

`ifndef SRAM_OUT_TXT
    `define SRAM_OUT_TXT "sram_out.txt"
`endif

`define WAIT(x) #((1.0*x)/freq*1s)

`ifndef EXT_PFD_OFFSET
    `define EXT_PFD_OFFSET 16
`endif

`ifndef N_INTERVAL
    `define N_INTERVAL 10
`endif

`ifndef INTERVAL_LENGTH
    //`define INTERVAL_LENGTH 10e-9
    `define INTERVAL_LENGTH (Nwrite*1e-9/`N_INTERVAL)
`endif

module test;
	import test_pack::*;
	import checker_pack::*;
    import const_pack::Nti;
    import const_pack::Nadc;
    import const_pack::Nout;
    import const_pack::Npi;
    import const_pack::N_mem_addr;
    import const_pack::N_mem_tiles;

    localparam real freq = 4e9; // TODO should this be full_rate?

    // write more data than SRAM can hold to make sure we capture just the beginning
    localparam integer Nwrite = (2**(N_mem_addr+$clog2(N_mem_tiles)))*1.1;
    localparam integer Nread = (2**(N_mem_addr+$clog2(N_mem_tiles)));

	// clock inputs

	logic ext_clkp;
	logic ext_clkn;

    // SRAM

    logic ext_dump_start;
    logic [N_mem_addr+$clog2(N_mem_tiles)-1:0] addr;

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

        // sram
        .ext_dump_start(ext_dump_start),

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
    logic signed [Nadc-1:0] adcout_unfolded [Nti-1:0];
    logic out_record;
    logic clk_r;

    tx_output_recorder tx_output_recorder_i (
        .in(tx_data),
        .clk(tx_clk),
        .en(should_record)
    );

    sram_recorder #(
        .filename(`SRAM_OUT_TXT)
    ) sram_out_recorder (
        .in(top_i.idcore.sm1_dbg_intf_i.out_data),
        .clk(clk_r),
        .en(out_record)
    );

	integer tmp;
    
	always @(posedge top_i.idcore.clk_adc) begin
        // compute the unfolded ADC outputs
        for (int k=0; k<Nti; k=k+1) begin
            // compute output
             tmp = top_i.idcore.adcout_sign_retimed[k] ?
                  top_i.idcore.adcout_retimed[k] - (`EXT_PFD_OFFSET) :
                  (`EXT_PFD_OFFSET) - top_i.idcore.adcout_retimed[k];
			
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

	logic [Nadc-1:0] tmp_ext_pfd_offset [Nti-1:0];

	initial begin
        `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif

        // initialize control signals
		should_record = 1'b0;
		recording_clk = 1'b0;
        ext_dump_start = 1'b0;
        out_record = 1'b0;

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

		// Wait some time initially
		$display("Initial delay of 50 ns...");
		#(100ns);

		// Trigger dump and record input for awhile
		should_record = 1'b1;
        ext_dump_start = 1'b1;
		for (int k=0; k<(`N_INTERVAL); k=k+1) begin
		    $display("Test is %0.1f%% complete.", (100.0*k)/(1.0*(`N_INTERVAL)));
		    #((`INTERVAL_LENGTH)*1s);
            if (k == 0) ext_dump_start = 1'b0;
		end

        // Read from SRAM
        out_record = 1'b1;
        addr = 0;
        force top_i.idcore.sm1_dbg_intf_i.in_addr = addr;
        `WAIT(0.6);
        // clock in the first memory address
        addr = 1;
        // read out the memory contents
        $display("Nread is %d\n", Nread);
        for (int j=1; j<Nread; j=j+1) begin
            addr = j;
            pulse_clk_r;
        end
        `WAIT(1.0);

		$finish;
	end
    
    task pulse_clk_r;
        clk_r = 1'b1;
        `WAIT(16 * 0.5);
        clk_r = 1'b0;
        `WAIT(16 * 0.5);
    endtask

endmodule
