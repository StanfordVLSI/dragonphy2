`include "mdll_param.vh"
`default_nettype none

interface mdll_r1_debug_intf import mdll_pkg::*; (
);
	logic rstn_jtag;			// reset ; active low; Note that this signal is also from jtag
	logic en_osc_jtag;		// enable osc; active high, false path
	logic en_dac_sdm_jtag;	// enable dco sdm; active high, false path
	logic en_monitor_jtag;	// enable measurement mode
	logic inj_mode_jtag; 	// 0: ring oscillator mode; 1: injection oscillator mode, false path
	logic freeze_lf_dco_track_jtag;	// freeze dco_ctl_track value in the loop filter; active high, false path
	logic freeze_lf_dac_track_jtag;	// freeze dac_ctl_track value in the loop filter; active high, false path
	logic load_lf_jtag;		// 1: load "load_val" into dco_ctl_fine reg; 0: normal loop filter ops, false path
	logic sel_dac_loop_jtag;	// 1: dac-based bb loop; 0: nominal bb loop, false path
  logic en_hold_jtag;       // enable holding dco_ctl_track value in dac tracking mode; active high, false path; otherwise, both dco_ctl tracking and dac_ctl tracking loops work together
	logic [$clog2(N_DIV):0] fb_ndiv_jtag;	// 2**fb_ndiv is the feedback divider ratio
	logic load_offset_jtag;	// 1: load dco_ctl_offset value, 0: keep the current offset value
	logic [N_DCO_O-1:0] dco_ctl_offset_jtag;			// # of delay coarse stages for supply modulation, false path
	logic [N_DCO_T-N_DCO_TF-1:0] dco_ctl_track_lv_jtag;		// init load value of dco_ctl_track in digital loop filter, false path
	logic [N_DAC_T-N_DAC_TF-1:0] dac_ctl_track_lv_jtag;		// init load value of dac_ctl_track in digital loop filter, false path
	logic [N_BB_GB-1:0] gain_bb_jtag;					// BB gain (2**(gain_bb)) for dco tracking , false path
	logic [N_BB_GDAC-1:0] gain_bb_dac_jtag;				// BB gain (2**(gain_dac)) for dac tracking, false path
	logic [$clog2(N_DIV)-1:0] sel_sdm_clk_jtag;	// sdm clock select from feedback divider 
	logic en_fcal_jtag;		// enable fcal mode
	logic [$clog2(N_FCAL_CNT)-1:0] fcal_ndiv_ref_jtag;	// divide clk_refp by 2**ndiv_ref to create a ref_pulse
	logic fcal_start_jtag;						// start counter (request)
	logic [N_DAC_BW-1:0] ctl_dac_bw_thm_jtag; 		// DAC bandwidth control (thermometer)
	logic [N_DAC_GAIN-1:0] ctlb_dac_gain_oc_jtag;	// r-dac gain control (one cold)
  logic [2:0] jm_sel_clk_jtag;    // select clock being measured
	logic jm_bb_out_pol_jtag;		// 1: take the internal bb_out_mon (inside the measurement module) as it is, 0: invert it

  // output in mdll_r1
	logic [N_FCAL_CNT-1:0] fcal_cnt_2jtag; // fcal counter value
	logic fcal_ready_2jtag;	// fcal result ready (acknowledge)
	logic [N_DCO_TI-1:0] dco_ctl_fine_mon_2jtag;
	logic [N_DAC_TI-1:0] dac_ctl_mon_2jtag;
	logic [N_JIT_CNT-1:0] jm_cdf_out_2jtag; // to jatag

    modport mdll_r1 ( 	
	    input rstn_jtag,
	    input en_osc_jtag,
	    input en_dac_sdm_jtag,
	    input en_monitor_jtag,
	    input inj_mode_jtag,
	    input freeze_lf_dco_track_jtag,
	    input freeze_lf_dac_track_jtag,
	    input load_lf_jtag,
	    input sel_dac_loop_jtag,
        input en_hold_jtag,
	    input fb_ndiv_jtag,
	    input load_offset_jtag,
	    input dco_ctl_offset_jtag,
	    input dco_ctl_track_lv_jtag,
	    input dac_ctl_track_lv_jtag,
	    input gain_bb_jtag,
	    input gain_bb_dac_jtag,
	    input sel_sdm_clk_jtag,
	    input en_fcal_jtag,
	    input fcal_ndiv_ref_jtag,
	    input fcal_start_jtag,
	    input ctl_dac_bw_thm_jtag,
	    input ctlb_dac_gain_oc_jtag,
        input jm_sel_clk_jtag,
	    input jm_bb_out_pol_jtag,
	    output fcal_cnt_2jtag,
	    output fcal_ready_2jtag,
	    output dco_ctl_fine_mon_2jtag,
	    output dac_ctl_mon_2jtag,
	    output jm_cdf_out_2jtag
    );
    
     modport jtag ( 	
	    output rstn_jtag,
	    output en_osc_jtag,
	    output en_dac_sdm_jtag,
	    output en_monitor_jtag,
	    output inj_mode_jtag,
	    output freeze_lf_dco_track_jtag,
	    output freeze_lf_dac_track_jtag,
	    output load_lf_jtag,
	    output sel_dac_loop_jtag,
        output en_hold_jtag,
	    output fb_ndiv_jtag,
	    output load_offset_jtag,
	    output dco_ctl_offset_jtag,
	    output dco_ctl_track_lv_jtag,
	    output dac_ctl_track_lv_jtag,
	    output gain_bb_jtag,
	    output gain_bb_dac_jtag,
	    output sel_sdm_clk_jtag,
	    output en_fcal_jtag,
	    output fcal_ndiv_ref_jtag,
	    output fcal_start_jtag,
	    output ctl_dac_bw_thm_jtag,
	    output ctlb_dac_gain_oc_jtag,
        output jm_sel_clk_jtag,
	    output jm_bb_out_pol_jtag,
	    input fcal_cnt_2jtag,
	    input fcal_ready_2jtag,
	    input dco_ctl_fine_mon_2jtag,
	    input dac_ctl_mon_2jtag,
	    input jm_cdf_out_2jtag
    );

endinterface 

`default_nettype wire
