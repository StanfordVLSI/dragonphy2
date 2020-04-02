`default_nettype none

module test (
	input wire logic [7:0] a,
	input wire logic [7:0] b,
	output var logic [7:0] c
);

	assign c = a+b;

endmodule

`default_nettype wire
