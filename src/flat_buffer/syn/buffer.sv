module buffer #(
	parameter integer numChannels = 16,
	parameter integer bitwidth 	  = 8,
	parameter integer depth       = 5
) (
	input wire logic [bitwidth-1:0] in [numChannels-1:0],

	input wire logic clk,
	input wire logic rstb,

	output logic [bitwidth-1:0] buffer [numChannels-1:0][depth-1:0]
);

integer ii;

genvar gi;
generate
	for(gi=0; gi<numChannels;gi=gi+1) begin
		always @(posedge clk or negedge rstb) begin
			if(~rstb) begin
				 for(ii=0;ii<depth; ii=ii+1) begin
				 	buffer[gi][ii] <= 0;
				 end
			end else begin
				buffer[gi][0] <= in[gi];
				for(ii=1; ii<depth; ii=ii+1) begin
					buffer[gi][ii] <= buffer[gi][ii-1];
				end
			end
		end
	end
endgenerate

endmodule 
