`default_nettype none
module comb_ffe #(
	parameter integer codeBitwidth=8,
	parameter integer weightBitwidth=11,
	parameter integer resultBitwidth=8,
	parameter integer shiftBitwidth=5,
	parameter integer ffeDepth=5,
	parameter integer numChannels=16,
	parameter integer numBuffers=2,
	parameter integer t0_buff=1
) (
	input wire logic signed [weightBitwidth-1:0] weights [ffeDepth-1:0][numChannels-1:0],
	input wire logic signed [codeBitwidth-1:0] flat_codes [numBuffers*numChannels-1:0],
	input wire logic [shiftBitwidth-1:0] shift_index [numChannels-1:0],


	output logic signed [resultBitwidth-1:0] estimated_bits [numChannels-1:0]

);

localparam productBitwidth   = codeBitwidth + weightBitwidth;
localparam sumBitwidth	 = $clog2(ffeDepth) + productBitwidth;
localparam idx = t0_buff * numChannels;

logic signed [sumBitwidth-1:0] result [numChannels-1:0];


genvar gi;
generate
	for(gi=0; gi<numChannels; gi=gi+1) begin
		always_comb begin 
			integer ii;
			result[gi] = 0;
			for(ii=0; ii<ffeDepth; ii=ii+1) begin
				result[gi] = result[gi] + weights[ii][gi] * flat_codes[idx - ii + gi];
			end
			estimated_bits[gi] = (result[gi] >>> shift_index[gi]);
		end
	end
endgenerate

endmodule : comb_ffe
`default_nettype wire