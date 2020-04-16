module sram #(
	parameter integer ADR_BITS=10,
	parameter integer DAT_BITS=128
) (
	input CLK,
	input CEB,
	input WEB,
	input [(ADR_BITS-1):0] A,
	input [(DAT_BITS-1):0] D,
	output [(DAT_BITS-1):0] Q
);
endmodule
