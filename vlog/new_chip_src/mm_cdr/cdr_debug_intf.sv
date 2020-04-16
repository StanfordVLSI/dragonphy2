`default_nettype none

interface cdr_debug_intf;

	import const_pack::*;

	logic signed [Nadc-1:0] pd_offset_ext;
	logic signed [Nadc+1+phase_est_shift:0] Ki;
	logic signed [Nadc+1+phase_est_shift:0] Kp;
	logic en_ext_pi_ctl;
	logic en_freq_est;
	logic signed [Npi-1:0] phase_out;
	logic sample_phase_out;

	modport cdr (
	 input  pd_offset_ext,
	 input  Ki,
	 input  Kp,
	 input en_ext_pi_ctl,
	 input en_freq_est,
	 output phase_out,
	 input sample_phase_out
	);

	modport jtag (
	 output pd_offset_ext,
	 output Ki,
	 output Kp,
	 output en_ext_pi_ctl,
	 output en_freq_est,
	 input phase_out,
	 output sample_phase_out
	);

endinterface

`default_nettype wire
