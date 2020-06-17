module input_buffer (
	input inp,
	input inm,
	input pd,
	output clk,
	output clk_b
);

    assign clk = inp & (~pd);
    assign clk_b = inm & (~pd);

endmodule
