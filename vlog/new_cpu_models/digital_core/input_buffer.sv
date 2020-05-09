module input_buffer (
	input wire logic inp,
	input wire logic inm,
	input wire logic pd,
	
	output wire clk,
	output wire clk_b

);

    assign clk = pd ? 1'b0 : inp;
    assign clk_b = pd ? 1'b0 : inm;

endmodule
