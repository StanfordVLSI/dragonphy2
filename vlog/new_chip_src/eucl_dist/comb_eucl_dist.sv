module comb_eucl_dist #(
	parameter integer inWidth 	  = 8,
	parameter integer outWidth    = 8,
	parameter integer shiftWidth  = 4,
	parameter integer seqLength   = 5
) (
	input wire logic signed [inWidth-1:0] est_seq [seqLength-1:0],
	input wire logic signed [inWidth-1:0] code_seq [seqLength-1:0],
	input wire logic [shiftWidth-1:0] shift_index,

	output reg  [outWidth-1:0] distance
);

	logic [$clog2(seqLength) + inWidth - 1:0] next_dist; // Squaring removes need for signed consideration

	always_comb begin
		integer ii;
		next_dist = 0;
		for(ii=0; ii<seqLength; ii=ii+1) begin
			next_dist = next_dist + $unsigned((code_seq[ii]-est_seq[ii])*(code_seq[ii]-est_seq[ii]));
		end
		distance = next_dist >>> shift_index;
	end

endmodule : comb_eucl_dist