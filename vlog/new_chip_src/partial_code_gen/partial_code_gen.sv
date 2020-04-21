module partial_code_gen #(
	parameter integer partial_est_depth=11,
	parameter integer estBitwidth=10,
	parameter integer outBitwidth=8
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
	wire logic signed [estBitwidth-1:0] sel_channel_est [partial_est_depth-1:0];


	genvar gi;
	generate
		for(gi=0; gi<partial_est_depth; gi=gi+1) begin
			assign sel_channel_est[gi] = channel_est[gi][bits[gi]];
		end
	endgenerate

	always @(sel_channel_est) begin
		integer ii;
		result = 0;
		for(ii=0; ii<partial_est_depth; ii=ii+1) begin
			result = result + sel_channel_est[ii];
		end
	end


	always_ff @(posedge clk or negedge rstb) begin
		integer ii;
		if(~rstb) begin
			for(ii=0; ii<partial_est_depth; ii=ii+1) begin
				channel_est[ii][0] <= 0;
				channel_est[ii][1] <= 0;
			end
			partial_est_code <= 0;
		end else begin
			for(ii=0; ii<partial_est_depth; ii=ii+1) begin
				channel_est[ii][0] <= -new_channel_est[partial_est_depth - 1 - ii];
				channel_est[ii][1] <= new_channel_est[partial_est_depth  - 1 - ii];
			end
			partial_est_code <= result; // (result >>> (resultBitwidth-outBitwidth));
		end
	end



endmodule : partial_code_gen
