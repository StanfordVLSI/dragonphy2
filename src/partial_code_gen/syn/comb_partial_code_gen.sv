module comb_partial_code_gen #(
	parameter integer partial_est_depth=11,
	parameter integer estBitwidth=10,
	parameter integer outBitwidth=8,
) (
	input wire logic bits[partial_est_depth-1:0],
	input wire logic signed [estBitwidth-1:0] new_channel_est [partial_est_depth-1:0],

	input logic clk,
	input logic rstb,

	output logic signed  [outBitwidth-1:0] partial_est_code
);

	localparam integer resultBitwidth = estBitwidth + $clog2(partial_est_depth);

	logic signed [resultBitwidth-1:0] result;
	logic signed [estBitwidth-1:0] channel_est [partial_est_depth-1:0][1:0];

	always @(*) begin
		integer ii;
		result = 0;
		for(ii=0; ii<partial_est_depth; ii=ii+1) begin
			result = result + channel_est[ii][bits[ii]];
		end
		partial_est_code = result;
	end


	always_ff @(posedge clk or negedge rstb) begin
		integer ii;
		if(~rstb) begin
			for(ii=0; ii<partial_est_depth; ii=ii+1) begin
				channel_est[ii][0] <= 0;
				channel_est[ii][1] <= 0;
			end
		end else begin
			for(ii=0; ii<partial_est_depth; ii=ii+1) begin
				channel_est[ii][0] <= -new_channel_est[partial_est_depth - 1 - ii];
				channel_est[ii][1] <= new_channel_est[partial_est_depth  - 1 - ii];
			end
		end
	end



endmodule : partial_code_gen
