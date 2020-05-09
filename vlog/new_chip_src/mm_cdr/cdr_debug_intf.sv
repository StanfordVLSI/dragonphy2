`default_nettype none

interface cdr_debug_intf;

	import const_pack::*;

	logic signed [Nadc-1:0] pd_offset_ext;
	logic signed [Nadc+1+phase_est_shift:0] Ki;
	logic signed [Nadc+1+phase_est_shift:0] Kp;
	logic signed [Nadc+1+phase_est_shift:0] Kr;
	logic en_ext_pi_ctl;
	logic signed [Npi-1:0] ext_pi_ctl;
	logic en_freq_est;
	logic en_ramp_est;
	logic signed [Npi+1+phase_est_shift:0] phase_est;
    logic signed [Npi+1+phase_est_shift:0] freq_est;
    logic signed [Npi+1+phase_est_shift:0] ramp_est;
    logic sel_inp_mux;

	logic sample_state;

	modport cdr (
	 input  pd_offset_ext,
	 input  Ki,
	 input  Kp,
	 input  Kr,
	 input en_ext_pi_ctl,
	 input ext_pi_ctl,
	 input en_freq_est,
	 input en_ramp_est,
	 output phase_est,
	 output freq_est,
	 output ramp_est,
	 input sel_inp_mux,
	 input sample_state
	);

	modport jtag (
	 output pd_offset_ext,
	 output Ki,
	 output Kp,
	 output Kr,
	 output en_ext_pi_ctl,
	 output ext_pi_ctl,
	 output en_freq_est,
	 output en_ramp_est,
	 input phase_est,
     input freq_est,
     input ramp_est,
     output sel_inp_mux,
	 output sample_state
	);

endinterface

`default_nettype wire
