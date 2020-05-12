`include "mLingua_pwl.vh"
`include "iotype.sv"

// From butterphy LOOPBACK
`default_nettype none

`ifndef EXT_PI_CTL_OFFSET_0
	`define EXT_PI_CTL_OFFSET_0 0
`endif

`ifndef EXT_PI_CTL_OFFSET_1
	`define EXT_PI_CTL_OFFSET_1 149
`endif

`ifndef EXT_PI_CTL_OFFSET_2
	`define EXT_PI_CTL_OFFSET_2 298
`endif

`ifndef EXT_PI_CTL_OFFSET_3	
	`define EXT_PI_CTL_OFFSET_3 447
`endif

// From dragonphy AC
`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

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
	logic ext_clkp;
	logic ext_clkn;
	
	// Clock outputs
	logic clk_out_p;
	logic clk_out_n;
	logic clk_trig_p;
	logic clk_trig_n;
    logic rstb;
	
	// Dump control
	logic dump_start;
	
	// JTAG
	jtag_intf jtag_intf_i();
    // TODO do we need this jtad_drv? it's instantiated down below
    // jtag_drv jtag_drv_i (jtag_intf_i);


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

	// Save TX output and RX ADC data

	logic should_record;

	tx_output_recorder tx_output_recorder_i (
		.in(tx_data),
		.clk(tx_clk),
		//.en(1'b1)
		.en(should_record)
	);


    ///////// Inserting magic reordering
    logic signed [Nadc-1:0] adcout_unfolded [Nti-1:0];
    reg recording_clk;
// Re-ordering
    // TODO: clean this up because it is likely a real bug
    integer tmp;
    integer idx_order [Nti] = '{0, 5, 10, 15,
                                1, 6, 11, 12,
                                2, 7,  8, 13,
                                3, 4,  9, 14};
    always @(posedge top_i.idcore.clk_adc) begin
        // compute the unfolded ADC outputs
        for (int k=0; k<Nti; k=k+1) begin
            // compute output
            tmp = top_i.idcore.adcout_sign[idx_order[k]] ?
                  top_i.idcore.adcout[idx_order[k]] - (`EXT_PFD_OFFSET) :
                  (`EXT_PFD_OFFSET) - top_i.idcore.adcout[idx_order[k]];
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

    //////// End magic reordering

	ti_adc_recorder ti_adc_recorder_i (
		//.in(top_i.idcore.adcout_unfolded[Nti-1:0]),
		//.clk(top_i.clk_adc),
        .in(adcout_unfolded),
        .clk(recording_clk),
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
		jtag_drv_i.write_tc_reg(int_rstb, 'b1);
		$display("Enabling input buffer...");
		jtag_drv_i.write_tc_reg(en_inbuf, 'b1);
		$display("Enabling V2T...");
		jtag_drv_i.write_tc_reg(en_v2t, 'b1);



		// Write the PI offsets
		$display("Writing ext_pi_ctl_offset[0]=%d", `EXT_PI_CTL_OFFSET_0);
		//jtag_drv_i.write_tc_reg(ext_pi_ctl_offset[0], `EXT_PI_CTL_OFFSET_0);
		$display("Writing ext_pi_ctl_offset[1]=%d", `EXT_PI_CTL_OFFSET_1);
		//jtag_drv_i.write_tc_reg(ext_pi_ctl_offset[1], `EXT_PI_CTL_OFFSET_1);
		$display("Writing ext_pi_ctl_offset[2]=%d", `EXT_PI_CTL_OFFSET_2);
		//jtag_drv_i.write_tc_reg(ext_pi_ctl_offset[2], `EXT_PI_CTL_OFFSET_2);
		$display("Writing ext_pi_ctl_offset[3]=%d", `EXT_PI_CTL_OFFSET_3);
		//jtag_drv_i.write_tc_reg(ext_pi_ctl_offset[3], `EXT_PI_CTL_OFFSET_3);

		// Dummy write
		//$display("Dummy write...");
		//jtag_drv_i.write_tc_reg(en_inbuf, 'b1);
		//This doesn't appear to be necessary...

		// Wait for valid data
		$display("Waiting for valid data...");
		#(100ns);

		// Record for a bit
		$display("Recording input and output...");
		should_record = 'b1;
		#(250ns);

		// Finish test
		$display("Test complete.");
		$finish;
	end

endmodule

`default_nettype wire
