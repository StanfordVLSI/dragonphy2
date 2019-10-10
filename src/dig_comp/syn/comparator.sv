module comparator #(
	parameter integer numChannels=16,
	parameter integer inputBitwidth=8,
	parameter integer confidenceBitwidth=8,
	parameter integer thresholdBitwidth=8
) (
	input wire logic signed [inputBitwidth-1:0] codes [numChannels-1:0],
	input wire logic signed [thresholdBitwidth-1:0] new_thresh [numChannels-1:0],

	input wire logic clk,
	input wire logic rstb,

	output reg bit_out [numChannels-1:0]
	output reg [confidenceBitwidth-1:0] confidence [numChannels-1:0]
);

	parameter integer input_shift = inputBitwidth-thresholdBitwidth;
	parameter integer conf_shift  = thresholdBitwidth - confidenceBitwidth;

	wire logic signed [thresholdBitwidth-1:0]  inp_minus_thresh	[numChannels-1:0];
	wire logic comparison_out [numChannels-1:0];
	wire logic [confidenceBitwidth-1:0] conf_out 	  [numChannels-1:0];

	logic signed [inputBitwidth-1:0] 	  compare_codes [numChannels-1:0];
	logic signed [thresholdBitwidth-1:0]  thresh [numChannels-1:0];

	//Given the input is clocked by an external stage, this should probably just let codes be clocked externally

	genvar gc;
	generate
		for(gc=0; gc<numChannels; gc=gc+1) begin
			assign conf_out[gc] 		  =  (inp_minus_thresh[gc] >= 0) ? ((inp_minus_thresh[gc]) >> conf_shift) : ((-inp_minus_thresh[gc]) >> conf_shift);
			assign comparison_out[gc] 	  =  (inp_minus_thresh[gc] >= 0) ? 1'b1 : 1'b0;
			assign inp_minus_thresh[gc]   =  ((compare_codes[gc] >>> input_shift) - thresh[gc]);
		
			always_ff @(posedge clk, negedge rstb) begin
				if(!rstb) begin
					thresh[gc] 		  <= 0;
					bit_out[gc] 	  <= 1'b0;
					confidence[gc] 	  <= 0;
					compare_codes[gc] <= 0;
				end else begin 
					thresh[gc]  	  <= new_thresh[gc];
					bit_out[gc] 	  <= comparison_out[gc];
					confidence[gc] 	  <= conf_out[gc];
					compare_codes[gc] <= codes[gc];
				end
			end
		end
	endgenerate


endmodule : comparator