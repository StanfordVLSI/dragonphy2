module sram_small #(
	parameter integer ADR_BITS=8,
	parameter integer DAT_BITS=64
) (
	input wire logic CLK,
	input wire logic CEB,
	input wire logic WEB,
	input wire logic [(ADR_BITS-1):0] A,
	input wire logic [(DAT_BITS-1):0] D,
	output wire logic [(DAT_BITS-1):0] Q
);
    // instantiate the FreePDK macro
    sram_64_256_freepdk45 sram_i (
        .clk0(CLK),
        .csb0(CEB),
        .web0(WEB),
        .addr0(A),
        .din0(D),
        .dout0(Q)
    );
endmodule
