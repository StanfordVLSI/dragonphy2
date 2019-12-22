module comb_partial_code_gen #(
	parameter integer partial_est_depth=11,
	parameter integer estBitwidth=10,
	parameter integer outBitwidth=8
) (
	input wire logic bits[partial_est_depth-1:0],
	input wire logic signed [estBitwidth-1:0] channel_est [partial_est_depth-1:0],

	output logic signed  [outBitwidth-1:0] partial_est_code
);

	localparam integer resultBitwidth = estBitwidth + $clog2(partial_est_depth);
	logic signed [resultBitwidth-1:0] result;

	always @(*) begin
		integer ii;
		result = 0;
		for(ii=0; ii<partial_est_depth; ii=ii+1) begin
			result = bits[ii] ? result + channel_est[partial_est_depth - 1 -ii] : result - channel_est[partial_est_depth - 1 -ii];
		end
		partial_est_code = result;
	end
endmodule : comb_partial_code_gen
