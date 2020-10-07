module flat_buffer #(
	parameter integer numChannels = 16,
	parameter integer bitwidth 	  = 8,
	parameter integer depth       = 5
) (
	input  logic [bitwidth-1:0] in [numChannels-1:0],
	input  logic clk,
	input  logic rstb,
	output 	   logic [bitwidth-1:0] flat_out [numChannels*depth-1:0]
);


	logic  [bitwidth-1:0] internal_pipeline [numChannels-1:0][depth-1:0];




buffer #(
	.numChannels(numChannels),
	.bitwidth   (bitwidth),
	.depth      (depth),
	.is_signed  (is_signed)
) buff_i (
	.in    (in),
	.clk   (clk),
	.rstb  (rstb),
	.buffer(internal_pipeline)
);

flatten_buffer #(
	.numChannels(numChannels),
	.bitwidth   (bitwidth),
	.depth      (depth),
	.is_signed(is_signed)
) fbuff_i (
	.buffer     (internal_pipeline),
	.flat_buffer(flat_out)
);

endmodule : flat_buffer
