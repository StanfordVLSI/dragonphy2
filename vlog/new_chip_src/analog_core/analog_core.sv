`include "iotype.sv"

//`default_nettype none

 module analog_core import const_pack::*; #(
) (
    input `pwl_t rx_inp,                                    // RX input (+) (from pad)
	input `pwl_t rx_inn,                                    // RX input (-)	(from pad)
	input `real_t Vcm,										// common mode voltate for termination (from pad/inout)
	
    input `pwl_t rx_inp_test,                                // RX input (+) for replica ADC (from pad)
    input `pwl_t rx_inn_test,                                // RX input (-) for replica ADC (from pad)
    
	input wire logic ext_clkp,                              // (+) 4GHz clock input (from pad)
    input wire logic ext_clkn,                              // (-) 4GHz clock input (from pad)

	input wire logic ext_clk_aux,							// aux clock input from secondary input buffer (optional/reserved)

	input wire logic ext_clk_test0,                              // (+) 4GHz clock input (from pad)
    input wire logic ext_clk_test1,                              // (-) 4GHz clock input (from pad)
    	
	input wire logic clk_cdr,		                        // cdr loop filter clock (from DCORE)
	input wire logic clk_async,		                        // asynchronous clock for phase measurement (from DCORE)
	input wire logic [Npi-1:0] ctl_pi[Nout-1:0],         			    // PI control code (from DCORE)
 

	input `real_t Vcal,										// bias voltage for V2T (from pad)
	
	output wire logic clk_adc,                              // clock for retiming adc data assigned from ADC_0 (to DCORE)
    output wire logic [Nadc-1:0] adder_out [Nti-1:0],   	// adc output (to DCORE)
    output wire logic [Nti-1:0] sign_out,					// adc output (to DCORE)

    output wire logic [Nadc-1:0] adder_out_rep [1:0],   // adc_rep output (to DCORE)
    output wire logic [1:0] sign_out_rep,				// adc_rep_output (to DOORE)
    
	acore_debug_intf.acore adbg_intf_i
);

// internal signals
 	`pwl_t VinP_slice [Nout-1:0];
 	`pwl_t VinN_slice [Nout-1:0];
	
	logic [Nti-1:0] en_sync_in;
	logic [Nti-1:0] en_sync_out;
	logic [Nti-1:0] clk_v2t_prev;
	logic [Nti-1:0] clk_v2t_next;
	logic [Nti-1:0] clk_div;
	logic [1:0] clk_v2t_next_rep;
	logic [1:0] clk_div_rep;
	
	logic [Nout-1:0] clk_interp_slice;
	logic [Nout-1:0] clk_interp_sw;
	logic [Nout-1:0] clk_interp_swb;
	logic clk_in_pi;
	
	assign clk_adc = clk_div[0];


//termination
	termination iterm(
		.VinP(rx_inp),
		.VinN(rx_inn),
		.Vcm(Vcm)
	);

// 1st-level SnH
    snh iSnH (
        .clk(clk_interp_sw),
        .clkb(clk_interp_swb),
        .in_p(rx_inp),
        .in_n(rx_inn),
        .out_p(VinP_slice),
        .out_n(VinN_slice)
    );

// 16-way TI ADC
genvar k;
generate
    for (k=0;k<Nti;k++) begin:iADC
        stochastic_adc_PR iADC (
    //inputs
		.VinP(VinP_slice[k/Nout]),
    	.VinN(VinN_slice[k/Nout]),
    	.clk_in(clk_interp_slice[k/Nout]),
    	.Vcal(Vcal),
    	//.VcalN(Vcal),
	    .clk_async(clk_async),
    	
		.en_sync_in(en_sync_in[k]),
    	//.clk_v2t_prev(clk_v2t_prev[k]),
    	.rstb(adbg_intf_i.rstb),
    	.en_slice(adbg_intf_i.en_slice[k]),
	    .ctl_v2t_n(adbg_intf_i.ctl_v2tn[k]),
    	.ctl_v2t_p(adbg_intf_i.ctl_v2tp[k]),
	    .init(adbg_intf_i.init[k]),
	    .alws_on(adbg_intf_i.ALWS_ON[k]),
	    .sel_pm_sign(adbg_intf_i.sel_pm_sign[k]),
    	.sel_pm_in(adbg_intf_i.sel_pm_in[k]),
	    .sel_clk_TDC(adbg_intf_i.sel_clk_TDC[k]),
	    .en_pm(adbg_intf_i.en_pm[k]),
	    //.en_v2t_clk_next(adbg_intf_i.en_v2t_clk_next[k]),
        //.en_sw_test(adbg_intf_i.en_sw_test[k]),
	    .ctl_dcdl_late(adbg_intf_i.ctl_dcdl_late[k]),
	    .ctl_dcdl_early(adbg_intf_i.ctl_dcdl_early[k]),
	    .ctl_dcdl(adbg_intf_i.ctl_dcdl_TDC[k]),
		.en_TDC_phase_reverse(adbg_intf_i.en_TDC_phase_reverse),
	//outputs
	    .en_sync_out(en_sync_out[k]),
	    //.clk_v2t_next(clk_v2t_next[k]),
	    .adder_out(adder_out[k]),
	    .sign_out(sign_out[k]),
	    .clk_adder(clk_div[k]),
	    .del_out(adbg_intf_i.del_out[k]),
	    .pm_out(adbg_intf_i.pm_out[k])
    );
	if (k != 0) begin
            assign en_sync_in[k] = en_sync_out[k-1];
            //assign clk_v2t_prev[k] = clk_v2t_next[k-1];

    end
    else begin
            assign en_sync_in[k] = adbg_intf_i.en_v2t;
            //assign clk_v2t_prev[k] = clk_v2t_next[Nti-1];
        end
    end
endgenerate
 
logic [3:0] inv_del_out_pi;
// 4ch. PI
generate
    for (k=0;k<Nout;k++) begin: iPI
	phase_interpolator iPI(
	//inputs
		.rstb(adbg_intf_i.rstb),
		.clk_in(clk_in_pi),
		.clk_async(clk_async),
		.clk_cdr(clk_cdr),
		.ctl(ctl_pi[k]),
	
		.en_gf(adbg_intf_i.en_gf),
		.en_arb(adbg_intf_i.en_arb_pi[k]),
		.en_delay(adbg_intf_i.en_delay_pi[k]),
		.en_ext_Qperi(adbg_intf_i.en_ext_Qperi[k]),
		.en_pm(adbg_intf_i.en_pm_pi[k]),
		.en_cal(adbg_intf_i.en_cal_pi[k]),
		.ext_Qperi(adbg_intf_i.ext_Qperi[k]),
		.sel_pm_sign(adbg_intf_i.sel_pm_sign_pi[k]),
		.inc_del(adbg_intf_i.del_inc[k]),
		.ctl_dcdl_slice(adbg_intf_i.ctl_dcdl_slice[k]),
		.ctl_dcdl_sw(adbg_intf_i.ctl_dcdl_sw[k]),
		.disable_state(adbg_intf_i.disable_state[k]),
		.en_clk_sw(adbg_intf_i.en_clk_sw[k]),
		//.en_meas(adbg_intf_i.en_meas_pi[k]),
		//.sel_meas(adbg_intf_i.sel_meas_pi[k]),
	
	//outputs
		.clk_out_slice(clk_interp_slice[k]),
		.clk_out_sw(clk_interp_sw[k]),
		//.clk_out_swb(clk_interp_swb[k]),
		.Qperi(adbg_intf_i.Qperi[k]),
		.cal_out(adbg_intf_i.cal_out_pi[k]),
		.del_out(inv_del_out_pi[k]),
		.pm_out(adbg_intf_i.pm_out_pi[k]),
		.max_sel_mux(adbg_intf_i.max_sel_mux[k])
		//.clk_out_meas(adbg_intf_i.pi_out_meas)
	);
	assign clk_interp_swb[k] = ~clk_interp_sw[k];
	assign adbg_intf_i.pi_out_meas[k] = (adbg_intf_i.sel_meas_pi[k] ? clk_interp_slice[k] : clk_interp_sw[k])&adbg_intf_i.en_meas_pi[k];
	end
endgenerate


// replica ADCs
/*
generate
    for (k=0;k<2;k++) begin:iADCrep
        stochastic_adc_PR iADCrep (
    //inputs
		.VinP(rx_inp_test),
    	.VinN(rx_inn_test),
    	.CLK_4G(clk_in_pi),
    	.VcalN(Vcal),
    	.VcalP(Vcal),
    	.en_sync_in(adbg_intf_i.en_v2t),
    	.clk_v2t_prev(clk_v2t_next_rep[k]),
    	.rstb(adbg_intf_i.rstb),
    	.en_slice(adbg_intf_i.en_slice_rep[k]),
	    .CTRLN(adbg_intf_i.ctl_v2tn_rep[k]),
    	.CTRLP(adbg_intf_i.ctl_v2tp_rep[k]),
	    .init(adbg_intf_i.init_rep[k]),
	    .ALWS_ON(adbg_intf_i.ALWS_ON_rep[k]),
	    .sel_pm_sign(adbg_intf_i.sel_pm_sign_rep[k]),
    	.sel_pm_in(adbg_intf_i.sel_pm_in_rep[k]),
	    .sel_clk_TDC(adbg_intf_i.sel_clk_TDC_rep[k]),
	    .en_pm(adbg_intf_i.en_pm_rep[k]),
	    .clk_async(clk_async),
	    .en_v2t_clk_next(adbg_intf_i.en_v2t_clk_next_rep[k]),
  		.en_sw_test(adbg_intf_i.en_sw_test_rep[k]),
	    .ctl_dcdl_late(adbg_intf_i.ctl_dcdl_late_rep[k]),
	    .ctl_dcdl_early(adbg_intf_i.ctl_dcdl_early_rep[k]),
	    .ctl_dcdl(adbg_intf_i.ctl_dcdl_TDC_rep[k]),
	//outputs
	    .en_sync_out(),
	    .clk_v2t_next(clk_v2t_next_rep[k]),
	    .adder_out(adder_out_rep[k]),
	    .sign_out(sign_out_rep[k]),
	    .del_out(adbg_intf_i.del_out_rep[k]),
	    .pm_out(adbg_intf_i.pm_out_rep[k]),
	    .clk_div(clk_div_rep[k])
    );
	end
endgenerate
*/

stochastic_adc_PR iADCrep0 (
    //inputs
		.VinP(rx_inp_test),
    	.VinN(rx_inn_test),
    	.clk_in(clk_in_pi),
    	.Vcal(Vcal),
    	//.VcalN(Vcal),
	    .clk_async(clk_async),
    	
		.en_sync_in(adbg_intf_i.en_v2t),
    	//.clk_v2t_prev(1'b0),
    	.rstb(adbg_intf_i.rstb),
    	.en_slice(adbg_intf_i.en_slice_rep[0]),
	    .ctl_v2t_p(adbg_intf_i.ctl_v2tn_rep[0]),
    	.ctl_v2t_n(adbg_intf_i.ctl_v2tp_rep[0]),
	    .init(adbg_intf_i.init_rep[0]),
	    .alws_on(adbg_intf_i.ALWS_ON_rep[0]),
	    .sel_pm_sign(adbg_intf_i.sel_pm_sign_rep[0]),
    	.sel_pm_in(adbg_intf_i.sel_pm_in_rep[0]),
	    .sel_clk_TDC(adbg_intf_i.sel_clk_TDC_rep[0]),
	    .en_pm(adbg_intf_i.en_pm_rep[0]),
	    //.en_v2t_clk_next(adbg_intf_i.en_v2t_clk_next_rep[0]),
  		//.en_sw_test(adbg_intf_i.en_sw_test_rep[0]),
	    .ctl_dcdl_late(adbg_intf_i.ctl_dcdl_late_rep[0]),
	    .ctl_dcdl_early(adbg_intf_i.ctl_dcdl_early_rep[0]),
	    .ctl_dcdl(adbg_intf_i.ctl_dcdl_TDC_rep[0]),
		.en_TDC_phase_reverse(adbg_intf_i.en_TDC_phase_reverse),
	//outputs
	    .en_sync_out(),
	    //.clk_v2t_next(clk_v2t_next_rep[0]),
	    .adder_out(adder_out_rep[0]),
	    .sign_out(sign_out_rep[0]),
	    .clk_adder(clk_div_rep[0]),
	    .del_out(adbg_intf_i.del_out_rep[0]),
	    .pm_out(adbg_intf_i.pm_out_rep[0])
    );

stochastic_adc_PR iADCrep1 (
    //inputs
		.VinP(rx_inp_test),
    	.VinN(rx_inn_test),
    	.clk_in(clk_in_pi),
    	.Vcal(Vcal),
    	//.VcalN(Vcal),
	    .clk_async(clk_async),
    	
		.en_sync_in(adbg_intf_i.en_v2t),
    	//.clk_v2t_prev(1'b0),
    	.rstb(adbg_intf_i.rstb),
    	.en_slice(adbg_intf_i.en_slice_rep[1]),
	    .ctl_v2t_p(adbg_intf_i.ctl_v2tn_rep[1]),
    	.ctl_v2t_n(adbg_intf_i.ctl_v2tp_rep[1]),
	    .init(adbg_intf_i.init_rep[1]),
	    .alws_on(adbg_intf_i.ALWS_ON_rep[1]),
	    .sel_pm_sign(adbg_intf_i.sel_pm_sign_rep[1]),
    	.sel_pm_in(adbg_intf_i.sel_pm_in_rep[1]),
	    .sel_clk_TDC(adbg_intf_i.sel_clk_TDC_rep[1]),
	    .en_pm(adbg_intf_i.en_pm_rep[1]),
	    //.en_v2t_clk_next(adbg_intf_i.en_v2t_clk_next_rep[0]),
  		//.en_sw_test(adbg_intf_i.en_sw_test_rep[0]),
	    .ctl_dcdl_late(adbg_intf_i.ctl_dcdl_late_rep[1]),
	    .ctl_dcdl_early(adbg_intf_i.ctl_dcdl_early_rep[1]),
	    .ctl_dcdl(adbg_intf_i.ctl_dcdl_TDC_rep[1]),
		.en_TDC_phase_reverse(adbg_intf_i.en_TDC_phase_reverse),
	//outputs
	    .en_sync_out(),
	    //.clk_v2t_next(clk_v2t_next_rep[0]),
	    .adder_out(adder_out_rep[1]),
	    .sign_out(sign_out_rep[1]),
	    .clk_adder(clk_div_rep[1]),
	    .del_out(adbg_intf_i.del_out_rep[1]),
	    .pm_out(adbg_intf_i.pm_out_rep[1])
    );
/*
stochastic_adc_PR_test iADCrep1 (
    //inputs
		.VinP(rx_inp_test),
    	.VinN(rx_inn_test),
    	.CLK_4G(clk_in_pi),
    	.VcalN(Vcal),
    	.VcalP(Vcal),
    	.en_sync_in(adbg_intf_i.en_v2t),
    	//.clk_v2t_prev(1'b0),
    	.rstb(adbg_intf_i.rstb),
    	.en_slice(adbg_intf_i.en_slice_rep[1]),
	    .CTRLN(adbg_intf_i.ctl_v2tn_rep[1]),
    	.CTRLP(adbg_intf_i.ctl_v2tp_rep[1]),
	    .init(adbg_intf_i.init_rep[1]),
	    .ALWS_ON(adbg_intf_i.ALWS_ON_rep[1]),
	    .sel_pm_sign(adbg_intf_i.sel_pm_sign_rep[1]),
    	.sel_pm_in(adbg_intf_i.sel_pm_in_rep[1]),
	    .sel_clk_TDC(adbg_intf_i.sel_clk_TDC_rep[1]),
	    .en_pm(adbg_intf_i.en_pm_rep[1]),
	    .clk_async(clk_async),
	    .en_v2t_clk_next(adbg_intf_i.en_v2t_clk_next_rep[1]),
  		.en_sw_test(adbg_intf_i.en_sw_test_rep[1]),
	    .ctl_dcdl_late(adbg_intf_i.ctl_dcdl_late_rep[1]),
	    .ctl_dcdl_early(adbg_intf_i.ctl_dcdl_early_rep[1]),
	    .ctl_dcdl(adbg_intf_i.ctl_dcdl_TDC_rep[1]),
		.sel_pfd_in(adbg_intf_i.sel_pfd_in),
		.sel_pfd_in_meas(adbg_intf_i.sel_pfd_in_meas),
		.en_pfd_inp_meas(adbg_intf_i.en_pfd_inp_meas),
		.en_pfd_inn_meas(adbg_intf_i.en_pfd_inn_meas),
		.sel_del_out(adbg_intf_i.sel_del_out),
        .clk_test_p(ext_clk_test0),
        .clk_test_n(ext_clk_test1),
	//outputs
	    //.clk_v2t_next(clk_v2t_next_rep[1]),
	    .adder_out(adder_out_rep[1]),
	    .sign_out(sign_out_rep[1]),
	    .del_out(adbg_intf_i.del_out_rep[1]),
	    .pm_out(adbg_intf_i.pm_out_rep[1]),
	    .clk_div(clk_div_rep[1]),
 		.pfd_inp_meas(adbg_intf_i.pfd_inp_meas),
 		.pfd_inn_meas(adbg_intf_i.pfd_inn_meas)
    );
*/

// bias generator
generate
    for (k=0;k<4;k++) begin:iBG
    biasgen iBG (
	//inputs
        .en(adbg_intf_i.en_biasgen[k]),
        .ctl(adbg_intf_i.ctl_biasgen[k]),
        .Vbias(Vcal)
    );
	end
endgenerate

// input clock buffer
	input_buffer iinbuf(
	//inputs	
		.inp(ext_clkp),
		.inn(ext_clkn),
		.in_aux(ext_clk_aux),
  		.en(adbg_intf_i.en_inbuf),
		.sel_in(adbg_intf_i.sel_inbuf_in),
		.bypass_div(adbg_intf_i.bypass_inbuf_div),
		.ndiv(adbg_intf_i.inbuf_ndiv),
		.en_meas(adbg_intf_i.en_inbuf_meas),
	//outputs
		.out(clk_in_pi),
		.out_meas(adbg_intf_i.inbuf_out_meas)
	);


// output drivers

wire del_out;
assign del_out = adbg_intf_i.sel_del_out_pi ? inv_del_out_pi[0] : clk_in_pi ;
assign adbg_intf_i.del_out_pi = del_out & adbg_intf_i.en_del_out_pi;


endmodule

//`default_nettype wire

