module buffer #(
	parameter integer numChannels = 16,
	parameter integer bitwidth 	  = 8,
	parameter integer depth       = 5,
	parameter integer is_signed   = 0
) (
	in,

	input wire logic clk,
	input wire logic rstb,

	buffer	
);


generate
	if(is_signed==1) begin
		input wire logic signed [bitwidth-1:0] in [numChannels-1:0];
		if(depth>0) begin
			output logic signed  [bitwidth-1:0] buffer [numChannels-1:0][depth-1:0];
		end else begin
			output logic signed  [bitwidth-1:0] buffer [numChannels-1:0];
		end
	end else begin
		input wire logic [bitwidth-1:0] in [numChannels-1:0];
		if(depth>0) begin
			output logic [bitwidth-1:0] buffer [numChannels-1:0][depth-1:0];
		end else begin
			output logic [bitwidth-1:0] buffer [numChannels-1:0];
		end

	end
endgenerate

integer ii;
genvar gi;

generate
	for(gi=0; gi<numChannels;gi=gi+1) begin
		if(depth>0) begin
			always @(posedge clk or negedge rstb) begin
				if(~rstb) begin
					 for(ii=0;ii<depth; ii=ii+1) begin
					 	buffer[gi][ii] = 0;
					 end
				end else begin
					if(depth > 1) begin
						for(ii=0; ii<depth-1; ii=ii+1) begin
							buffer[gi][depth-ii-1] = buffer[gi][depth-2-ii];
						end
					end
					buffer[gi][0] = in[gi];
				end
			end
		end else begin
			always_comb begin
				buffer[gi] = in[gi];
			end
		end
	end
endgenerate

endmodule : buffer
