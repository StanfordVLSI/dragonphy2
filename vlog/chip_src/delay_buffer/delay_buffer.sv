module delay_buffer #(
	parameter integer numChannels = 16,
	parameter integer bitwidth 	  = 8,
	parameter integer depth       = 5
) (
	input wire logic [bitwidth-1:0] in [numChannels-1:0],

	input wire logic clk,
	input wire logic rstb,

	output logic [bitwidth-1:0] out [numChannels-1:0]
);

logic [bitwidth-1:0] internal_pipeline [numChannels-1:0][depth-1:0];

buffer #(
	.numChannels(numChannels),
	.bitwidth   (bitwidth),
	.depth      (depth)
) buff_i (
	.in    (in),
	.clk   (clk),
	.rstb  (rstb),
	.buffer(internal_pipeline)
);

genvar gi;
generate
	for (int gi = 0; gi < numChannels; gi=gi+1) begin
		assign out[gi] = internal_pipeline[gi][depth-1]; 
	end
endgenerate

endmodule : delay_buffer