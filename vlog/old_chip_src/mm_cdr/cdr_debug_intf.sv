`default_nettype none

interface cdr_debug_intf;

	import const_pack::*;

	logic signed [Nadc-1:0] pd_offset_ext;
	logic signed [21:0] p_val;
	logic signed [21:0] i_val;

	modport cdr (
		input pd_offset_ext,
		input p_val,
		input i_val
	);

	modport jtag (
		output pd_offset_ext,
		output p_val,
		output i_val
	);

endinterface

`default_nettype wire
