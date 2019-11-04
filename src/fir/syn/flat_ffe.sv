module flat_ffe #(
	parameter integer codeBitwidth=8,
	parameter integer weightBitwidth=8,
	parameter integer resultBitwidth=8,
	parameter integer shiftBitwidth=5,
	parameter integer ffeDepth=16,
	parameter integer numChannels=16

) (
	input wire logic signed [weightBitwidth-1:0]    new_weights [ffeDepth-1:0][numChannels-1:0],
	input wire logic signed [codeBitwidth-1:0]  	codes   [numChannels-1:0],
	input wire logic [shiftBitwidth-1:0] 			new_shift_index [numChannels-1:0],

	input wire logic clk,
	input wire logic rstb,

	output reg signed [resultBitwidth-1:0] results [numChannels-1:0]
);

localparam integer numFutureBuffers = $ceil(real'(ffeDepth-1)/real'(numChannels));
localparam integer bufferDepth = numFutureBuffers + 1;
localparam integer centerBuffer = 0;


logic signed [weightBitwidth-1:0] weights [ffeDepth-1:0][numChannels-1:0];
logic [shiftBitwidth-1:0]  shift_index [numChannels-1:0];


wire logic [codeBitwidth-1:0] ucodes      [numChannels-1:0];
wire logic [codeBitwidth-1:0] uflat_codes [numChannels*bufferDepth-1:0];
logic signed [codeBitwidth-1:0]   flat_codes [numChannels*bufferDepth-1:0];

wire logic signed [resultBitwidth-1:0] next_results [numChannels-1:0];

genvar gi;
generate
	for(gi=0; gi<numChannels; gi= gi + 1) begin
		assign ucodes[gi] = $unsigned(codes[gi]);
	end

	for(gi=0; gi<numChannels*bufferDepth; gi=gi+1) begin
		assign flat_codes[gi] = $signed(uflat_codes[gi]);
	end
endgenerate


// Range: 0 (oldest) to numChannels*depth (newest)
flat_buffer #(
	.numChannels(numChannels),
	.bitwidth   (codeBitwidth),
	.depth      (bufferDepth)
) fb_i (
	.in      (ucodes),
	.clk     (clk),
	.rstb    (rstb),
	.flat_out(uflat_codes)
);

comb_ffe #(
	.codeBitwidth(codeBitwidth),
	.weightBitwidth(weightBitwidth),
	.resultBitwidth(resultBitwidth),
	.shiftBitwidth(shiftBitwidth),
	.ffeDepth(ffeDepth),
	.numChannels(numChannels),
	.numBuffers    (bufferDepth),
	.centerBuffer  (centerBuffer)
) cffe_i (
	.weights       (weights),
	.flat_codes    (flat_codes),
	.shift_index   (shift_index),
	.estimated_bits(next_results)
);

integer ii, jj;

always_ff @(posedge clk or negedge rstb) begin
	if(~rstb) begin
		for(ii = 0; ii < numChannels; ii=ii+1) begin
			for(jj=0; jj < ffeDepth; jj=jj+1) begin
				weights[jj][ii] <= 0;
			end
			shift_index[ii] <= 0;
			results[ii] <= 0;
		end
	end else begin
		for(ii = 0; ii < numChannels; ii=ii+1) begin
			for(jj=0; jj < ffeDepth; jj=jj+1) begin
				weights[jj][ii] <= new_weights[jj][ii];
			end
			results[ii] <= next_results[ii];
			shift_index[ii] <= new_shift_index[ii];
		end
	end
end
	
endmodule : flat_ffe