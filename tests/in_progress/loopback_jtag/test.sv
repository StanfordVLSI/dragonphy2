`include "mLingua_pwl.vh"
`include "iotype.sv"

`default_nettype none

`ifndef N_PRINT	
	`define N_PRINT 2
`endif

`ifndef N_TEST
	`define N_TEST 2 // (1<<N_mem_addr)
`endif

module test;

	import const_pack::*;
	import test_pack::*;
	import checker_pack::*;
	import jtag_reg_pack::*;

	localparam `real_t v_cm = 0.40;

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

	// Save TX output 

	logic tx_should_record;
	tx_output_recorder tx_output_recorder_i (
		.in(tx_data),
		.clk(tx_clk),
		.en(tx_should_record)
	);

	logic record;
	logic signed [Nadc-1:0] data_from_sram [Nti-1:0];
	ti_adc_recorder ti_adc_recorder_i (
		.in(data_from_sram),
		.clk(record),
		.en(1'b1)
	);

	task pulse_record();
		record = 1'b1;
		#0;
		record = 1'b0;
		#0;
	endtask

	integer i, j;
	logic [31:0] result;
	initial begin
		// signal initialization
		rstb = 1'b0;
		dump_start = 1'b0;
		record = 1'b0;
		tx_should_record = 1'b1;

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

		// Dummy write
		$display("Dummy write...");
		jtag_drv_i.write_tc_reg(en_inbuf, 'b1);


		// Wait for valid data
		$display("Waiting for valid data...");
		#(100ns);

		// Dump to SRAM
		$display("Recording input and output...");
		dump_start = 'b1;
		#(1.2us);
		tx_should_record = 'b0;

		// Read back from SRAM
		$display("Reading back data from SRAM...");
		for (i=0; i<`N_TEST; i=i+1) begin
			if (i % `N_PRINT == 0) begin
				$display("Reading from SRAM address %d", i);
			end

			jtag_drv_i.write_tc_reg(in_addr, i);
			for (j=0; j<Nti; j=j+1) begin
				`ifdef PRINT_ARRAY_ELEM
					$display("Reading array element %d", j);
				`endif
				jtag_drv_i.read_sc_reg(out_data[j], result);
				data_from_sram[j] = result;
			end
			pulse_record();
		end

		// Finish test
		$display("Test complete.");
		$finish;
	end

	sim_status #(.dt(0.1e-6)) sim_status_i ();

endmodule

`default_nettype wire
