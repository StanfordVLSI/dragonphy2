`default_nettype none

interface error_tracker_debug_intf #(
    parameter integer addrwidth = 12
);

	import const_pack::*;

	logic [addrwidth-1:0] addr;
	logic read;
	logic enable;

	logic [31:0] output_data_frame[4:0];

	modport tracker (
		input addr,
		input read,
		input enable,
		output output_data_frame
	);

	modport  jtag (
	 output addr,
	 output read,
	 output enable,
	 input output_data_frame

	);

endinterface

`default_nettype wire
