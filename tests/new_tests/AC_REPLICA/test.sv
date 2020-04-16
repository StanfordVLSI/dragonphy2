`include "mLingua_pwl.vh"
`include "iotype.sv"

`default_nettype none

module test;

	import const_pack::*;
	import test_pack::*;
	import checker_pack::*;
	import jtag_reg_pack::*;

	localparam real v_diff_min = -0.4;
	localparam real v_diff_max = +0.4;
	localparam real v_diff_step = 0.01;
	localparam `real_t v_cm = 0.40;

	// mLingua initialization
	PWLMethod pm=new;

	// Analog inputs
	`pwl_t ch_outp;
	`pwl_t ch_outn;
    `voltage_t v_cal;

	// clock inputs 
	logic clk_async;
	logic clk_jm_p;
	logic clk_jm_n;
	logic ext_clkp;
	logic ext_clkn;

	// clock outputs
	logic clk_out_p;
	logic clk_out_n;
	logic clk_trig_p;
	logic clk_trig_n;
	logic clk_retime;
	logic clk_slow;
    logic rstb;

	// dump control
	logic dump_start;
	logic clk_cdr;

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
		.freq(full_rate/2), //Depends on divider !
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	); 

	jtag_drv jtag_drv_i (jtag_intf_i);

	logic should_record;
	
    ti_adc_recorder #(
    	.num_channels(Nti_rep)
    ) ti_adc_recorder_i (
		.in(top_i.idcore.adcout_unfolded[Nti+Nti_rep-1:Nti]),
		.clk(top_i.idcore.clk_adc),
		.en(should_record)
	);

    // Sine wave stimulus

    sine_stim #(
		.sine_freq(11e6)
    ) sine_stim_i (
		.ch_outp(ch_outp),
		.ch_outn(ch_outn)
	);

	// Main stimulus program

	localparam integer V2T_CTL_NOM = 6;

	initial begin
		should_record = 1'b0;
		rstb = 1'b0;

		#(20ns);
		rstb = 1'b1;
		#(10ns);

		// Initialize JTAG
		jtag_drv_i.init();

		// JTAG writes
		$display("Enabling the input buffer.");
		jtag_drv_i.write_tc_reg(en_inbuf, 'b1);
		$display("Enabling the V2T.");
		jtag_drv_i.write_tc_reg(en_v2t, 'b1);
		$display("Enabling the replica slices.");
		jtag_drv_i.write_tc_reg(en_slice_rep, (1<<(Nti_rep))-1);
		jtag_drv_i.write_tc_reg(int_rstb, 'b1);
		for (int i=0; i<Nti_rep; i=i+1) begin
			$display("Writing V2TP control code for replica %d.", i);
			jtag_drv_i.write_tc_reg(ctl_v2tp_rep[i], V2T_CTL_NOM);
			$display("Writing V2TN control code for replica %d.", i);
			jtag_drv_i.write_tc_reg(ctl_v2tn_rep[i], V2T_CTL_NOM);
		end
		
		// Wait some time initially
		$display("Initial delay.");
		#(50ns);

		// Then record for awhile
		$display("Recording data.");
		should_record = 1'b1;
		#(1.2us);

		$finish;
	end

	// print out simulation progress
	sim_status sim_status_i ();

endmodule

`default_nettype wire
