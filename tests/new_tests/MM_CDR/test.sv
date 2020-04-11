`include "mLingua_pwl.vh"
`include "iotype.sv"

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
    `voltage_t v_cal;

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
	butterphy_top top_i (
		// analog inputs
		.ext_rx_inp(ch_outp),
		.ext_rx_inn(ch_outn),
		.ext_Vcm(v_cm),
		.ext_Vcal(v_cal),

		// clock inputs 
		.ext_clkp(ext_clkp),
		.ext_clkn(ext_clkn),

		// clock outputs
		.clk_out_p(clk_out_p),
		.clk_out_n(clk_out_n),
		.clk_trig_p(clk_trig_p),
		.clk_trig_n(clk_trig_n),
		// dump control
		.ext_dump_start(dump_start),
        .ext_rstb(rstb),
		// JTAG
		.jtag_intf_i(jtag_intf_i)
	);

	clock #(
		.freq(full_rate/2), // Depends on divider!
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	); 

	jtag_drv jtag_drv_i (jtag_intf_i);

	// TX data

	logic tx_clk;
	logic tx_data;

	tx_prbs #(
		.freq((full_rate*1000)/1000)
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

	// Save TX output and RX ADC data

	logic should_record;

	tx_output_recorder tx_output_recorder_i (
		.in(tx_data),
		.clk(tx_clk),
		.en(should_record)
	);

	ti_adc_recorder ti_adc_recorder_i (
		.in(top_i.idcore.adcout_unfolded[Nti-1:0]),
		.clk(top_i.clk_adc),
		.en(should_record)
	);

	initial begin
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
		jtag_drv_i.write_tc_reg(en_inbuf, 'b1);
		$display("Enabling V2T...");
		jtag_drv_i.write_tc_reg(en_v2t, 'b1);
		jtag_drv_i.write_tc_reg(int_rstb, 'b1);

		$display("Disabling external PI CTL code...");
		#(1us)
		jtag_drv_i.write_tc_reg(en_ext_pi_ctl_cdr, 'b0);
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
