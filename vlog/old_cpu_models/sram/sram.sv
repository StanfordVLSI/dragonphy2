// modified from: https://esrd2014.blogspot.com/p/synchronous-static-ram.html

`default_nettype none

module sram #(
	parameter integer ADR_BITS=10,
	parameter integer DAT_BITS=128
) (
	input wire logic CLK,
	input wire logic CEB,
	input wire logic WEB,
	input wire logic [(ADR_BITS-1):0] A,
	input wire logic [(DAT_BITS-1):0] D,
	output wire logic [(DAT_BITS-1):0] Q
);

	// input
	logic [(DAT_BITS-1):0] DATA_I;
	assign DATA_I = D;

	// output
	logic [(DAT_BITS-1):0] DATA_O;
	assign Q = DATA_O;

	// internal memory
	localparam DEPTH = 1<<ADR_BITS;
	logic [(DAT_BITS-1):0] MEMORY [(DEPTH-1):0];

	// main behavior
	always @ (posedge CLK) begin
		if (CEB == 1'b0) begin
			if (WEB == 1'b0) begin
				// write
				MEMORY[A] = DATA_I;
			end else begin
				// read 
				DATA_O = MEMORY[A];
			end
		end
	end

endmodule

`default_nettype wire
