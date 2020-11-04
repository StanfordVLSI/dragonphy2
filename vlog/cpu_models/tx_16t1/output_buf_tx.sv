module output_buf_tx (
	input wire logic DINN,
	input wire logic DINP,
	input wire logic [17:0] CTL_SLICE_N0,
	input wire logic [17:0] CTL_SLICE_N1,
    input wire logic [17:0] CTL_SLICE_P0,
	input wire logic [17:0] CTL_SLICE_P1,
	output wire logic DOUTN,
    output wire logic DOUTP
);
	// Internal connections
    // wire logic BTN; // Buffer to Termination -
    // wire logic BTP; // Buffer to Termination +

assign DOUTN = DINN;
assign DOUTP = DINP;


endmodule