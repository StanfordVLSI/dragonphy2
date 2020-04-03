`default_nettype none

interface acore_debug_intf import const_pack::*; (
);
	// inputs to analog core
		//ADC
		logic rstb;											// from JTAG (0)x
		logic en_v2t;										// from JTAG (0)x
		logic [Nti-1:0] en_slice; 							// from JTAG (all 1) x
   		logic [Nv2t-1:0] ctl_v2tn [Nti-1:0];				// from JTAG (all 16) x
    	logic [Nv2t-1:0] ctl_v2tp [Nti-1:0];				// from JTAG (all 16) x
    	logic [$clog2(Nout)-1:0] init[Nti-1:0];  			// from JTAG (all 0) x (phase of v2t clock)
    	logic [Nti-1:0] ALWS_ON;							// from JTAG (all 0) x(always on - switches)
    	logic [1:0] sel_pm_sign[Nti-1:0];					// from JTAG (all 0)x
    	logic [1:0] sel_pm_in[Nti-1:0];						// from JTAG (all 0)x
    	logic [Nti-1:0] sel_clk_TDC;						// from JTAG (all 0)x
    	logic [Nti-1:0] en_pm;								// from JTAG (all 0)x
    	logic [Nti-1:0] en_v2t_clk_next;					// from JTAG (all 0)x
		logic [Nti-1:0] en_sw_test;							// from JTAG (all 0)x
    	logic [1:0] ctl_dcdl_late[Nti-1:0];					// from JTAG (all 0)x
    	logic [1:0] ctl_dcdl_early[Nti-1:0];				// from JTAG (all 0)x
    	logic [4:0] ctl_dcdl_TDC[Nti-1:0];					// from JTAG (all 0)x
		//PI
		logic en_gf;										// from JTAG (0)x
        logic [Nout-1:0] en_arb_pi;							// from JTAG (all 1)x
        logic [Nout-1:0] en_delay_pi;						// from JTAG (all 1)x
        logic [Nout-1:0] en_ext_Qperi;						// from JTAG (all 0)x
        logic [Nout-1:0] en_pm_pi;							// from JTAG (all 0)x
        logic [Nout-1:0] en_cal_pi;							// from JTAG (all 0)x
        logic [$clog2(Nunit_pi)-1:0] ext_Qperi[Nout-1:0];	// from JTAG (all 17)x
        logic [1:0] sel_pm_sign_pi[Nout-1:0];				// from JTAG (all 0)x
        logic [Nunit_pi-1:0] del_inc[Nout-1:0];				// from JTAG (all 0) x
        logic [1:0] ctl_dcdl_slice[Nout-1:0];				// from JTAG (all 0) x
        logic [1:0] ctl_dcdl_sw[Nout-1:0];					// from JTAG (all 0) x
        logic [Nout-1:0] disable_state;						// from JTAG (all 0) x
        logic [Nout-1:0] en_clk_sw;							// from JTAG (all 1) x
        logic [Nout-1:0] en_meas_pi;						// from JTAG (all 0) x
        logic [Nout-1:0] sel_meas_pi;						// from JTAG (all 0) x
		//ADCrep
		logic [1:0] en_slice_rep; 							// from JTAG (all 0) x
   		logic [Nv2t-1:0] ctl_v2tn_rep [1:0];				// from JTAG (all 16) x
    	logic [Nv2t-1:0] ctl_v2tp_rep [1:0];				// from JTAG (all 16) x
    	logic [$clog2(Nout)-1:0] init_rep[1:0]; 			// from JTAG (all 0) x
    	logic [1:0] ALWS_ON_rep;							// from JTAG (all 0) x
    	logic [1:0] sel_pm_sign_rep[1:0];					// from JTAG (all 0) x
    	logic [1:0] sel_pm_in_rep[1:0];						// from JTAG (all 0) x
    	logic [1:0] sel_clk_TDC_rep;						// from JTAG (all 0) x
    	logic [1:0] en_pm_rep;								// from JTAG (all 0) x
    	logic [1:0] en_v2t_clk_next_rep;					// from JTAG (all 0) x
    	logic [1:0] en_sw_test_rep;							// from JTAG (all 0) x
    	logic [1:0] ctl_dcdl_late_rep[1:0];					// from JTAG (all 0) x
    	logic [1:0] ctl_dcdl_early_rep[1:0];				// from JTAG (all 0) x	
    	logic [4:0] ctl_dcdl_TDC_rep[1:0];					// from JTAG (all 0) x
		// Input Buffers
        logic disable_ibuf_async;
        logic disable_ibuf_aux;
        logic disable_ibuf_test0;
        logic disable_ibuf_test1;

		//ADCtest(only for ADCrep1)
 		logic sel_pfd_in;									// from JTAG (0) x
 		logic sel_pfd_in_meas;								// from JTAG (0)x
 		logic en_pfd_inp_meas;								// from JTAG (0)x
 		logic en_pfd_inn_meas;								// from JTAG (0)x
		logic sel_del_out;									// from JTAG (0)x
		
		//input clock buffer
		logic en_inbuf;										// xfrom JTAG (1)
		logic sel_inbuf_in;									// xfrom JTAG (0)
		logic bypass_inbuf_div;								// xfrom JTAG (1)
        logic [2:0] inbuf_ndiv;								// xfrom JTAG (0)
        logic en_inbuf_meas;								// xfrom JTAG (0)
		//biasgen
		logic [3:0] en_biasgen;								// xfrom JTAG (all 1)x
		logic [3:0] ctl_biasgen [3:0];						//x from JTAG (all 7)x

		//ACORE
		logic sel_del_out_pi; //x
		logic en_del_out_pi;  //x

	    // outputs from analog core
		//ADC
		logic [19:0] pm_out [Nti-1:0];						// to JTAG	
       	logic [Nti-1:0] del_out;							// (all NC/open)
		//PI
		logic [19:0] pm_out_pi [Nout-1:0];					// to JTAG
		//logic [Nout-1:0] del_out_pi;						// ([3:1]--> NC/open, [0]--> to output buffer )
		logic  del_out_pi;									// to output buffer
		logic [Nout-1:0] cal_out_pi;						// to DCORE and JTAG
		logic [$clog2(Nunit_pi)-1:0] Qperi[Nout-1:0]; 		// to JTAG
 		logic [$clog2(Nunit_pi)-1:0] max_sel_mux[Nout-1:0];	// to DCORE and JTAG
       	logic [Nout-1:0] pi_out_meas;						// to output buffer
       	//ADCrep
		logic [19:0] pm_out_rep [1:0];						// to JTAG
       	logic [1:0] del_out_rep;							// ([1] --> to output buffer [0] --> NC/open)
 		logic pfd_inp_meas;									// to output buffer
 		logic pfd_inn_meas;									// to output buffer
		
		//input clock buffer
		logic inbuf_out_meas;								// to output buffer									
	
	modport acore (
		// inputs to analog core
		input rstb,
		input en_v2t,						
		input en_slice, 
   		input ctl_v2tn ,
    	input ctl_v2tp ,
    	input init,  
    	input ALWS_ON,
    	input sel_pm_sign,
    	input sel_pm_in,
    	input sel_clk_TDC,
    	input en_pm,
    	input en_v2t_clk_next,
    	input en_sw_test,
    	input ctl_dcdl_late,
    	input ctl_dcdl_early,
    	input ctl_dcdl_TDC,
		
		input en_gf,
        input en_arb_pi,
        input en_delay_pi,
        input en_ext_Qperi,
        input en_pm_pi,
        input en_cal_pi,
        input ext_Qperi,
        input sel_pm_sign_pi,
        input del_inc,
        input ctl_dcdl_slice,
        input ctl_dcdl_sw,
        input disable_state,
        input en_clk_sw,
        input en_meas_pi,
        input sel_meas_pi,

		input en_slice_rep, 
   		input ctl_v2tn_rep ,
    	input ctl_v2tp_rep ,
    	input init_rep,  
    	input ALWS_ON_rep,
    	input sel_pm_sign_rep,
    	input sel_pm_in_rep,
    	input sel_clk_TDC_rep,
    	input en_pm_rep,
    	input en_v2t_clk_next_rep,
    	input en_sw_test_rep,
    	input ctl_dcdl_late_rep,
    	input ctl_dcdl_early_rep,
    	input ctl_dcdl_TDC_rep,
	

        input disable_ibuf_async,
        input disable_ibuf_aux,
        input disable_ibuf_test0,
        input disable_ibuf_test1,

		input en_inbuf,
        input sel_inbuf_in,
		input bypass_inbuf_div,
		input inbuf_ndiv,
        input en_inbuf_meas,
		
		input en_biasgen,
		input ctl_biasgen,

 		input sel_pfd_in,
 		input sel_pfd_in_meas,
 		input en_pfd_inp_meas,
 		input en_pfd_inn_meas,
		input sel_del_out,
	
		input sel_del_out_pi,
		input en_del_out_pi,

  // outputs from analog core
		output pm_out ,		
       	output del_out,
       	output pm_out_pi ,
       	output del_out_pi,
       	output cal_out_pi,
        output Qperi,
    	output max_sel_mux,
        output pi_out_meas,
       	output pm_out_rep ,
       	output del_out_rep,
		output inbuf_out_meas,
 		output pfd_inp_meas,
 		output pfd_inn_meas
	);

    modport dcore (
        // inputs to analog core
        output rstb,
        output en_v2t,                       
        output en_slice, 
        output ctl_v2tn ,
        output ctl_v2tp ,
        output init,  
        output ALWS_ON,
        output sel_pm_sign,
        output sel_pm_in,
        output sel_clk_TDC,
        output en_pm,
        output en_v2t_clk_next,
        output en_sw_test,
        output ctl_dcdl_late,
        output ctl_dcdl_early,
        output ctl_dcdl_TDC,
        
        output en_gf,
        output en_arb_pi,
        output en_delay_pi,
        output en_ext_Qperi,
        output en_pm_pi,
        output en_cal_pi,
        output ext_Qperi,
        output sel_pm_sign_pi,
        output del_inc,
        output ctl_dcdl_slice,
        output ctl_dcdl_sw,
        output disable_state,
        output en_clk_sw,
        output en_meas_pi,
        output sel_meas_pi,

        output en_slice_rep, 
        output ctl_v2tn_rep ,
        output ctl_v2tp_rep ,
        output init_rep,  
        output ALWS_ON_rep,
        output sel_pm_sign_rep,
        output sel_pm_in_rep,
        output sel_clk_TDC_rep,
        output en_pm_rep,
        output en_v2t_clk_next_rep,
        output en_sw_test_rep,
        output ctl_dcdl_late_rep,
        output ctl_dcdl_early_rep,
        output ctl_dcdl_TDC_rep,
        
        output disable_ibuf_async,
        output disable_ibuf_aux,
        output disable_ibuf_test0,
        output disable_ibuf_test1,


        output en_inbuf,
        output sel_inbuf_in,
        output bypass_inbuf_div,
        output inbuf_ndiv,
        output en_inbuf_meas,
        
        output en_biasgen,
        output ctl_biasgen,

        output sel_pfd_in,
        output sel_pfd_in_meas,
        output en_pfd_inp_meas,
        output en_pfd_inn_meas,
        output sel_del_out,
    
        output sel_del_out_pi,
        output en_del_out_pi,

  // outputs from analog core
        input pm_out ,     
        input del_out,
        input pm_out_pi ,
        input del_out_pi,
        input cal_out_pi,
        input Qperi,
        input max_sel_mux,
        input pi_out_meas,
        input pm_out_rep ,
        input del_out_rep,
        input inbuf_out_meas,
        input pfd_inp_meas,
        input pfd_inn_meas
    );

/*
	modport dcore (
	);
	
	modport memory (
	);

	modport out_buff (
	);
		
	modport jtag (
	);
*/
endinterface

`default_nettype wire
