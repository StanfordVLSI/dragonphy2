interface tx_debug_intf import const_pack::*; (
);
	// inputs to analog core
		//TX 16 to 1
		//PI
		// logic en_gf;										// 
        // logic [Nout-1:0] en_arb_pi;							// 
        // logic [Nout-1:0] en_delay_pi;						// 
        // logic [Nout-1:0] en_ext_Qperi;						// 
        // logic [Nout-1:0] en_pm_pi;							// 
        // logic [Nout-1:0] en_cal_pi;							// 
        // logic [$clog2(Nunit_pi)-1:0] ext_Qperi[Nout-1:0];	// from JTAG (all 17)x
        // logic [1:0] sel_pm_sign_pi[Nout-1:0];				// from JTAG (all 0)x
        // logic [Nunit_pi-1:0] del_inc[Nout-1:0];				// from JTAG (all 0) x
        // logic [Nunit_pi-1:0] enb_unit_pi[Nout-1:0];			// from JTAG (all 0) x
        // logic [1:0] ctl_dcdl_slice[Nout-1:0];				// from JTAG (all 0) x
        // logic [1:0] ctl_dcdl_sw[Nout-1:0];					// from JTAG (all 0) x
        // logic [1:0] ctl_dcdl_clk_encoder[Nout-1:0];			// from JTAG (all 0) x
        // logic [Nout-1:0] disable_state;						// from JTAG (all 0) x
        // logic [Nout-1:0] en_clk_sw;							// from JTAG (all 1) x
        // logic [Nout-1:0] en_meas_pi;						// from JTAG (all 0) x
        // logic [Nout-1:0] sel_meas_pi;						// from JTAG (all 0) x

		//input clock buffer
		logic en_inbuf;										// xfrom JTAG (1)
		logic sel_clk_source;										// xfrom JTAG (1)
		logic bypass_inbuf_div;								// xfrom JTAG (1)
		logic bypass_inbuf_div2;							// xfrom JTAG (1)
		logic [2:0] inbuf_ndiv;								// xfrom JTAG (0)
		logic en_inbuf_meas;								// xfrom JTAG (0)

		//ACORE input divider output selection
		logic sel_del_out_pi; //x
		logic en_del_out_pi;  //x

		// outputs from analog core
		//ADC
		logic [Nti-1:0] del_out;							// (all NC/open)
		//PI
		logic [19:0] pm_out_pi [Nout-1:0];					// to JTAG
		logic  del_out_pi;									// to output buffer
		logic [Nout-1:0] cal_out_pi;						// to DCORE and JTAG
		logic [$clog2(Nunit_pi)-1:0] Qperi[Nout-1:0]; 		// to JTAG
 		logic [$clog2(Nunit_pi)-1:0] max_sel_mux[Nout-1:0];	// to DCORE and JTAG
       	logic [Nout-1:0] pi_out_meas;						// to output buffer
		
		// Input clock signal measurement
		logic inbuf_out_meas;								// to output buffer									
		
		// output buffer control
        logic [17:0] ctl_buf_n0;
        logic [17:0] ctl_buf_n1;
		logic [17:0] ctl_buf_p0;
        logic [17:0] ctl_buf_p1;

	modport tx (
		
		// input en_gf,
        // input en_arb_pi,
        // input en_delay_pi,
        // input en_ext_Qperi,
        // input en_pm_pi,
        // input en_cal_pi,
        // input ext_Qperi,
        // input sel_pm_sign_pi,
        // input del_inc,
        // input enb_unit_pi,
        // input ctl_dcdl_slice,
        // input ctl_dcdl_sw,
        // input ctl_dcdl_clk_encoder,
        // input disable_state,
        // input en_clk_sw,
        // input en_meas_pi,
        // input sel_meas_pi,

		//Input of the phase interpolator
		input en_inbuf,
		input sel_clk_source,
		input bypass_inbuf_div,
		input bypass_inbuf_div2,
		input inbuf_ndiv,
        input en_inbuf_meas,
		
		// input sel_del_out,
		input sel_del_out_pi,
		input en_del_out_pi,

        // output buf
        input ctl_buf_n0,
        input ctl_buf_p0,
        input ctl_buf_n1,
        input ctl_buf_p1,
        
        // outputs from analog core
       	output del_out,
       	output pm_out_pi ,
       	output del_out_pi,
       	output cal_out_pi,
        output Qperi,
    	output max_sel_mux,
        output pi_out_meas,
		output inbuf_out_meas
	);

    modport dcore (
        
        // output en_gf,
        // output en_arb_pi,
        // output en_delay_pi,
        // output en_ext_Qperi,
        // output en_pm_pi,
        // output en_cal_pi,
        // output ext_Qperi,
        // output sel_pm_sign_pi,
        // output del_inc,
        // output enb_unit_pi,
        // output ctl_dcdl_slice,
        // output ctl_dcdl_sw,
        // output ctl_dcdl_clk_encoder,
        // output disable_state,
        // output en_clk_sw,
        // output en_meas_pi,
        // output sel_meas_pi,
        

        output en_inbuf,
        output sel_clk_source,
        output bypass_inbuf_div,
        output bypass_inbuf_div2,
        output inbuf_ndiv,
        output en_inbuf_meas,
        
        // output sel_del_out,
    
        output sel_del_out_pi,
        output en_del_out_pi,

        // output buf ctl
        output ctl_buf_n0,
        output ctl_buf_p0,
        output ctl_buf_n1,
        output ctl_buf_p1,

        // outputs from analog core
        input del_out,
        input pm_out_pi ,
        input del_out_pi,
        input cal_out_pi,
        input Qperi,
        input max_sel_mux,
        input pi_out_meas,
        input inbuf_out_meas
    );
endinterface
