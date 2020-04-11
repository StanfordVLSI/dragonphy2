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
	//`real_t v_cm;
    `voltage_t v_cal;

	// clock inputs 
	logic clk_async;
	logic clk_jm_p;
	logic clk_jm_n;
	logic ext_clkp;
	logic ext_clkn;
    logic signed [Nadc-1:0] adcout_conv_signed [Nti-1:0];
	// clock outputs
	logic clk_out_p;
	logic clk_out_n;
	logic clk_trig_p;
	logic clk_trig_n;

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
	// Force CDR Clock

	// RSTB

	// Save signals for post-processing

	logic record;

	rx_input_recorder rx_input_recorder_i (
		.in_p(ch_outp),
		.in_n(ch_outn),
		.clk(record),
		.en(1'b1)
	);
	
    ti_adc_recorder ti_adc_recorder_i (
		.in(top_i.idcore.adcout_unfolded[15:0]),
		.clk(record),
		.en(1'b1)
	);

	// Main stimulus program

	initial begin
		//force top_i.idcore.iMM_CDR.iMM_AVG_IIR.in = +'sd383;
		record = 1'b0;
		rstb = 1'b1;
		#(20ns);
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;
		#(10ns);

		// Initialize JTAG
		jtag_drv_i.init();

		// Enable the input buffer
		jtag_drv_i.write_tc_reg(en_inbuf, 'b1);
		jtag_drv_i.write_tc_reg(en_v2t, 'b1);
		ch_outp = pm.write(v_cm, 0, 0);
		ch_outn = pm.write(v_cm, 0, 0);
		jtag_drv_i.write_tc_reg(int_rstb, 'b1);

		//repeat (2) @(top_i.idcore.clk_cdr);
		//force top_i.idcore.cdr_rstb = 1;
		
		for (real v_diff = v_diff_min; v_diff <= v_diff_max+v_diff_step; v_diff = v_diff+v_diff_step) begin
			ch_outp = pm.write(v_cm+v_diff/2.0, 0, 0);
			ch_outn = pm.write(v_cm-v_diff/2.0, 0, 0);
			
			$display("Differential input: %0.3f V", ch_outp.a-ch_outn.a);
			
			#(15ns);

			record = 1'b1;
			#0;
			record = 1'b0;
		end

		$finish;
	end

endmodule

`default_nettype wire
