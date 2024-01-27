`default_nettype none

interface cdr_debug_intf;

	import const_pack::*;

	logic signed [Nadc-1:0] pd_offset_ext;
	logic signed [Nadc+1+phase_est_shift:0] Ki;
	logic signed [Nadc+1+phase_est_shift:0] Kp;
	logic en_ext_pi_ctl;
	logic signed [Npi-1:0] ext_pi_ctl;
	logic en_freq_est;
    logic sel_inp_mux;

	modport cdr (
		input  pd_offset_ext,
		input  Ki,
		input  Kp,
		input en_ext_pi_ctl,
		input ext_pi_ctl,
		input en_freq_est,
		input sel_inp_mux
	);

	modport jtag (
		output pd_offset_ext,
		output Ki,
		output Kp,
		output en_ext_pi_ctl,
		output ext_pi_ctl,
		output en_freq_est,
		output sel_inp_mux
	);

endinterface

`default_nettype wire
