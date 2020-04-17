module input_buffer (
	input wire logic inp,
	input wire logic inm,
	input wire logic pd,
	
	output wire clk
);

    assign clk = pd ? 1'b0 : inp;

endmodule
