module output_buf_tx (
	input wire logic DINN,
	input wire logic DINP,
	input wire logic [7:0] CTL_SLICE_N,
    input wire logic [7:0] CTL_SLICE_P,
	output wire logic DOUTN,
    output wire logic DOUTP
);
	// Internal connections
    // wire logic BTN; // Buffer to Termination -
    // wire logic BTP; // Buffer to Termination +

assign DOUTN = DINN;
assign DOUTP = DINP;


endmodule