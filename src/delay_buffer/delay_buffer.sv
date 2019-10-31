module delay_buffer #(
	parameter integer numChannels = 16,
	parameter integer bitwidth 	  = 8,
	parameter integer depth       = 5
) (
	input wire logic [bitwidth-1:0] in [numChannels-1:0],

	input wire logic clk,
	input wire logic rstb,

	output reg [bitwidth-1:0] out [numChannels-1:0]
);

localparam integer intern_depth = depth-1;

logic [bitwidth-1:0] internal_pipeline [numChannels-1:0][intern_depth-1:0];
integer ii;

genvar gi;
generate
	for(gi=0; gi<numChannels;gi=gi+1) begin
		always @(posedge clk or negedge rstb) begin
			if(~rstb) begin
				 out[gi] <= 0;
				 for(ii=0;ii<intern_depth; ii=ii+1) begin
				 	internal_pipeline[gi][ii] <= 0;
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