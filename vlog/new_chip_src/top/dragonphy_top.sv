`include "iotype.sv"

`default_nettype none

module dragonphy_top import const_pack::*; (
	// analog inputs
	input `pwl_t ext_rx_inp,
	input `pwl_t ext_rx_inn,
	input `real_t ext_Vcm,
	input `real_t ext_Vcal,
	input `pwl_t ext_rx_inp_test,
	input `pwl_t ext_rx_inn_test,

	// clock inputs 
	input wire logic ext_clk_async_p,
	input wire logic ext_clk_async_n,

	input wire logic ext_clk_test0_p,
	input wire logic ext_clk_test0_n,
	input wire logic ext_clk_test1_p,
	input wire logic ext_clk_test1_n,
	input wire logic ext_clkp,
	input wire logic ext_clkn,

	// clock outputs
	output wire logic clk_out_p,
	output wire logic clk_out_n,
	output wire logic clk_trig_p,
	output wire logic clk_trig_n,

	//Reset Logic
	input wire logic ext_rstb,

	// dump control
	input wire logic ext_dump_start,

	// JTAG
	jtag_intf.target jtag_intf_i
);

	// analog core debug interface
	acore_debug_intf adbg_intf_i ();

	wire logic clk_main;
	wire logic clk_async;
	wire logic ext_clk_test0;
	wire logic ext_clk_test1;

	// Signal declaration
	input_buffer ibuf_async (
		.inp(ext_clk_async_p),
		.inm(ext_clk_async_n),
		.pd(adbg_intf_i.disable_ibuf_async),
		.clk(clk_async)
	);

	input_buffer ibuf_main (
		.inp(ext_clkp),
		.inm(ext_clkn),
		.pd(adbg_intf_i.disable_ibuf_main),
		.clk(clk_main)
	);

	input_buffer ibuf_test0 (
		.inp(ext_clk_test0_p),
		.inm(ext_clk_test0_n),
		.pd(adbg_intf_i.disable_ibuf_test0),
		.clk(ext_clk_test0)
	);

	input_buffer ibuf_test1 (
		.inp(ext_clk_test1_p),
		.inm(ext_clk_test1_n),
		.pd(adbg_intf_i.disable_ibuf_test1),
		.clk(ext_clk_test1)
	);


	logic clk_cdr;
	logic [Npi-1:0]		pi_ctl_cdr[Nout-1:0];

	logic clk_adc;
	logic [Nadc-1:0] 	adcout 				[Nti-1:0];
	logic [Nti-1:0]  	adcout_sign;
	logic [Nadc-1:0] 	adcout_rep 			[Nti_rep-1:0];
	logic [Nti_rep-1:0] adcout_sign_rep;


// temp setting for sim ultil DCORE is fixed ---------------------------
	logic ctl_valid;
	assign ctl_valid = 1;	
//---------------------------------------------------------------------------
	
	// Analog core instantiation
	analog_core iacore (
		.rx_inp(ext_rx_inp),						// RX input (+) 
		.rx_inn(ext_rx_inn), 						// RX input (-)
		.Vcm(ext_Vcm),

		.rx_inp_test(ext_rx_inp_test),
		.rx_inn_test(ext_rx_inn_test),

		.ext_clk(clk_main),					// External clock (+)
		.ext_clk_test0(ext_clk_test0),
		.ext_clk_test1(ext_clk_test1),
		.clk_cdr(clk_cdr),						// CDR clock
		.clk_async(clk_async),
		.ctl_pi(pi_ctl_cdr),  // PI control code from CDR
		.ctl_valid(ctl_valid),  // PI control valid flag from CDR
		
		.Vcal(ext_Vcal),
		
		.clk_adc(clk_adc), 						// clock for retiming adc data
		.adder_out(adcout), 						// adc output
		.sign_out(adcout_sign),
		.adder_out_rep(adcout_rep), 						// adc output
		.sign_out_rep(adcout_sign_rep),

		.adbg_intf_i(adbg_intf_i) 				// debug IO
	);
	
	// digital core instantiation

	digital_core idcore (
		.clk_adc(clk_adc), 						// clock for retiming adc data
		.adcout(adcout), 	
		.adcout_sign(adcout_sign),
		.adcout_rep(adcout_rep), 	
		.adcout_sign_rep(adcout_sign_rep),
		.ext_rstb(ext_rstb),
		.clock_out_p(clk_out_p),
    	.clock_out_n(clk_out_n),
    	.trigg_out_p(clk_trig_p),
    	.trigg_out_n(clk_trig_n),
    	.clk_async(clk_async),
		.clk_cdr(clk_cdr),						// CDR clock
		.int_pi_ctl_cdr(pi_ctl_cdr),		// PI control code from CDR
		
		.ext_dump_start(ext_dump_start),

		.adbg_intf_i(adbg_intf_i),		
		.jtag_intf_i(jtag_intf_i)
	);

endmodule

`default_nettype wire
