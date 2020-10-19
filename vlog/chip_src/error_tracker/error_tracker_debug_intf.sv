`default_nettype none

interface error_tracker_debug_intf #(
    parameter integer addrwidth = 12
);

	import const_pack::*;

	logic [addrwidth-1:0] addr;
	logic [addrwidth-1:0] number_stored_frames;
	logic read;
	logic enable;

	logic [31:0] output_data_frame[4:0];

	modport tracker (
		input addr,
		input read,
		input enable,
		output output_data_frame,
		output number_stored_frames
	);

	modport  jtag (
	 output addr,
	 output read,
	 output enable,
	 input output_data_frame,
	 input number_stored_frames
	);

endinterface

`default_nettype wire
