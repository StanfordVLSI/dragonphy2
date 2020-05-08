module sram #(
	parameter integer ADR_BITS=10,
	parameter integer DAT_BITS=144
) (
	input wire logic CLK,
	input wire logic CEB,
	input wire logic WEB,
	input wire logic [(ADR_BITS-1):0] A,
	input wire logic [(DAT_BITS-1):0] D,
	output wire logic [(DAT_BITS-1):0] Q
);
	// enable writing to all bits
	logic [(DAT_BITS-1):0] BWEB;
	assign BWEB = {(DAT_BITS-1){1'b0}};

	// instantiate memory
	TS1N16FFCLLSBLVTC1024X144M4SW memory (
		// user-provided signals
		.CLK(CLK),
		.CEB(CEB),
		.WEB(WEB),
		.A(A),
		.D(D),
		.Q(Q),
		// additional connections
		.BWEB(BWEB),
		.RTSEL(2'b01),
		.WTSEL(2'b00)
	);
endmodule
