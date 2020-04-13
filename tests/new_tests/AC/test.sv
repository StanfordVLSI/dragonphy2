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
	localparam `real_t v_cm = 0.25;

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

	// Save signals for post-processing

	logic should_record;
	
    ti_adc_recorder ti_adc_recorder_i (
		.in(top_i.idcore.adcout_unfolded[15:0]),
		.clk(top_i.idcore.clk_adc),
		.en(should_record)
	);

    // Sine wave stimulus

    sine_stim #(.sine_freq(1.023E9))

 sine_stim_i (
		.ch_outp(ch_outp),
		.ch_outn(ch_outn)
	);

	// Main stimulus program

genvar kk;
generate
	for(kk=0;kk<Nti;kk=kk+1) begin : gen1
		initial begin
			force top_i.idcore.jtag_i.rjtag_intf_i.ctl_v2tp[kk] = 'd6;
			force top_i.idcore.jtag_i.rjtag_intf_i.ctl_v2tn[kk] = 'd6;
			force top_i.idcore.jtag_i.rjtag_intf_i.ext_pfd_offset[kk] = 'd53;
		end
	end
endgenerate


	initial begin
		should_record = 1'b0;
		rstb = 1'b0;

		#(20ns);
		rstb = 1'b1;
		#(10ns);

		// Initialize JTAG
		jtag_drv_i.init();

		// Enable the input buffer
		jtag_drv_i.write_tc_reg(int_rstb, 'b1);
		jtag_drv_i.write_tc_reg(en_inbuf, 'b1);
		jtag_drv_i.write_tc_reg(en_v2t, 'b1);
		// Wait some time initially
		#(50ns);

		// Then record for awhile
		should_record = 1'b1;
		#(2.4us);

		$finish;
	end

endmodule

`default_nettype wire
