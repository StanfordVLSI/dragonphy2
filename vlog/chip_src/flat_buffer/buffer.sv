module buffer #(
	parameter integer numChannels = 16,
	parameter integer bitwidth 	  = 8,
	parameter integer depth       = 1
) (
	input  logic [bitwidth-1:0] in [numChannels-1:0],
	input  logic clk,
	input  logic rstb,
	output logic [bitwidth-1:0] buffer [numChannels-1:0][depth:0]
);




integer ii;
genvar gi;

generate
	for(gi=0; gi<numChannels;gi=gi+1) begin
		always @(posedge clk or negedge rstb) begin
			if(~rstb) begin
				 for(ii=1;ii<depth+1; ii=ii+1) begin
				 	buffer[gi][ii] <= 0;
				 end
			end else begin
				if(depth > 0) begin
					for(ii=0; ii<depth; ii=ii+1) begin
						buffer[gi][depth-ii] <= buffer[gi][depth-1-ii];
					end
				end
			end
		end
		always_comb begin
			if(~rstb) begin
				buffer[gi][0] = 0;
			end else begin
				buffer[gi][0] = in[gi];
			end
		end
	end
endgenerate

endmodule : buffer
