module delay_buffer #(
	parameter integer numChannels = 16,
	parameter integer bitwidth 	  = 8,
	parameter integer depth       = 5
) (
	input wire logic [bitwidth-1:0] in [numChannels-1:0],

	input wire logic clk,
	input wire logic rstb,

	output reg [bitwidth-1:0] out [numChannels-1:0],
	output reg [bitwidth-1:0] flat_out [numChannels*depth-1:0]
);

parameter integer intern_depth = depth-1;

logic [bitwidth-1:0] internal_pipeline [numChannels-1:0][intern_depth-1:0];

genvar gi, gj;
generate
	for(gj=0; gj<numChannels; gj=gj+1) begin
		for(gi=0; gi<intern_depth-1; gi=gi+1) begin
			assign flat_out[gi*numChannels + gj] = internal_pipeline[gj][gi];
		end
		assign flat_out[(intern_depth-1)*numChannels + gj] = out[gj];
	end

	for(gi=0; gi<numChannels;gi=gi+1) begin
		integer ii, jj;

		always_ff @(posedge clk or negedge rstb) begin
			if(~rstb) begin
				 out[gi] <= 0;
				 for(jj=0;jj<intern_depth; jj=jj+1) begin
				 	internal_pipeline[gi][jj] <= 0;
				 end
			end else begin
				internal_pipeline[gi][0] <= in[gi];
				for(ii=1; ii<intern_depth; ii=ii+1) begin
					internal_pipeline[gi][ii] <= internal_pipeline[gi][ii-1];
				end
				out[gi] <= internal_pipeline[gi][intern_depth-1];
			end
		end
	end
endgenerate

endmodule : delay_buffer