// modified from: https://esrd2014.blogspot.com/p/synchronous-static-ram.html

// update 09-21-20: use non-blocking assignment as described in several references:
// 1. https://inst.eecs.berkeley.edu/~cs150/sp13/agenda/lec/lec11-sram.pdf (page 28)
// 2. https://www.intel.com/content/www/us/en/programmable/support/support-resources/design-examples/design-software/verilog/ver-single-clock-syncram.html
// 3. https://www.chipverify.com/verilog/verilog-single-port-ram
// 4. https://riptutorial.com/verilog/example/10519/single-port-synchronous-ram

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
				MEMORY[A] <= DATA_I;
			end else begin
				// read 
				DATA_O <= MEMORY[A];
			end
		end
	end

endmodule

`default_nettype wire
