`include "mLingua_pwl.vh"
`include "iotype.sv"


`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``
`define FORCE_CDBG(name, value) force top_i.idcore.cdbg_intf_i.``name`` = ``value``


`default_nettype none

module test;

	import const_pack::*;
	import test_pack::*;
	import checker_pack::*;
	import jtag_reg_pack::*;

	localparam `real_t v_cm = 0.25;

	// mLingua initialization
	PWLMethod pm=new;

	// Analog inputs
	`pwl_t ch_outp;
	`pwl_t ch_outn;

	// Clock inputs 
	logic clk_async;
	logic clk_jm_p;
	logic clk_jm_n;
	logic ext_clkp;
	logic ext_clkn;
	
	// Clock outputs
	logic clk_out_p;
	logic clk_out_n;
	logic clk_trig_p;
	logic clk_trig_n;
	logic clk_retime;
	logic clk_slow;
    logic rstb;
	
	// Dump control
	logic dump_start;
	
	// JTAG
	jtag_intf jtag_intf_i();

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

	localparam real ext_clk_freq = full_rate/2;
	clock #(
		.freq(ext_clk_freq), // Depends on divider!
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	); 

	jtag_drv jtag_drv_i (jtag_intf_i);

	// TX data
	// Save TX output and RX ADC data

	logic should_record;
	
	ti_adc_recorder ti_adc_recorder_i (
		.in(top_i.idcore.adcout_unfolded[Nti-1:0]),
		.clk(top_i.clk_adc),
		.en(should_record)
	);

	initial begin
		$shm_open("waves.shm"); $shm_probe("ACT");
		$shm_probe(dragonphy_top.idcore.iMM_CDR.phase_est_out);
		$shm_probe(dragonphy_top.idcore.iMM_CDR.phase_est_d);
		$shm_probe(dragonphy_top.idcore.iMM_CDR.phase_est_q);
		$shm_probe(dragonphy_top.idcore.iMM_CDR.phase_est_update);
		$shm_probe(dragonphy_top.idcore.iMM_CDR.freq_diff);
		$shm_probe(dragonphy_top.idcore.iMM_CDR.freq_est_d);
		$shm_probe(dragonphy_top.idcore.iMM_CDR.freq_est_q);
		$shm_probe(dragonphy_top.idcore.iMM_CDR.freq_est_update);

		// signal initialization
		rstb = 1'b0;
		should_record = 'b0;

		// reset sequence
		#(20ns);
		rstb = 1'b1;
		#(10ns);

		// JTAG writes
		jtag_drv_i.init();

		// Enable the input buffer
		$display("Enabling input buffer...");
      	`FORCE_DDBG(int_rstb, 1);
      	`FORCE_CDBG(Kp, 7);

        #(1ns);
        `FORCE_ADBG(en_inbuf, 1);
		#(1ns);
        `FORCE_ADBG(en_gf, 1);
        #(1ns);
        `FORCE_ADBG(en_v2t, 1);
        #(1ns);
        $display("Enabling V2T...");

		$display("Disabling external PI CTL code...");
		#(1us)

		`FORCE_CDBG(en_ext_pi_ctl, 'b0);
		$display("Enabling external offset for PI CTL...");
		//jtag_drv_i.write_tc_reg(sel_ext_pd_offset, 'b1);

		// Wait for MM_CDR to lock
		$display("Waiting for MM_CDR to lock...");
		#(40us);

		// Record for a bit
		$display("Recording input and output...");
		should_record = 'b1;
		#(100ns);

		// Finish test
		$display("Test complete.");
		$finish;
	end

endmodule

`default_nettype wire
