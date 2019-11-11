module ffe #(
	parameter integer maxWeightLength=16,
	parameter integer numChannels=16,
	parameter integer codeBitwidth=8,
	parameter integer weightBitwidth=8,
	parameter integer resultBitwidth=8,
	parameter integer shiftBitwidth=5
)(
	input wire logic signed [weightBitwidth-1:0]      new_weights [numChannels-1:0][maxWeightLength-1:0],
	input wire logic signed [codeBitwidth-1:0]  codes   [numChannels-1:0],
	input wire logic [shiftBitwidth-1:0] new_shift_index,

	input wire logic clk,
	input wire logic rstb,

	output reg signed [resultBitwidth-1:0] results [numChannels-1:0]
);


parameter integer numBuffers 	   = int'($ceil(real'(maxWeightLength-1)/real'(numChannels)))+1; 
// This can be made more efficient by separating the last buffer
parameter integer sumPipelineDepth = $clog2(maxWeightLength);
parameter integer numSum 		   = 2**sumPipelineDepth-1 ; 
parameter integer productBitwidth  = codeBitwidth + weightBitwidth;
parameter integer sumBitwidth      = $clog2(maxWeightLength) + productBitwidth;

wire logic signed [codeBitwidth-1:0] 	 flatBuffer    [numChannels*numBuffers-1:0];

logic signed [codeBitwidth-1:0] 	     buffers   	   [numChannels-1:0][numBuffers-1:0];
wire logic signed [codeBitwidth-1:0] 	 next_buffers  [numChannels-1:0][numBuffers-2:0];

logic signed [weightBitwidth-1:0] 	     weights       [numChannels-1:0][maxWeightLength-1:0];

logic signed [productBitwidth-1:0]       products  	   [numChannels-1:0][maxWeightLength-1:0];
wire logic signed [productBitwidth-1:0]  next_products [numChannels-1:0][maxWeightLength-1:0];

logic signed [sumBitwidth-1:0]           sum   	  	   [numChannels-1:0][numSum-1:0];
wire logic signed [sumBitwidth-1:0]      next_sum	   [numChannels-1:0][numSum-1:0];

logic [shiftBitwidth-1:0] 		 shift_index;

always@(posedge clk, negedge rstb) begin
	if(!rstb) begin
		shift_index <= 0;
	end else begin
		shift_index <= new_shift_index;
	end
end

integer ii,jj;
genvar gh, gi, gj;
generate
//Initiate the State of the Circular Buffers as [0, 1, 2...numBuffer-1];
for(gh = 0; gh < numChannels; gh = gh+1) begin
	for(gi = 0; gi < numBuffers; gi = gi+1) begin
	    initial begin
			buffers[gh][gi] = 0;
		end
	end //wt.new_weights   


	for(gi=0; gi<numBuffers-1; gi=gi+1) begin
		assign next_buffers[gh][gi] = buffers[gh][gi];
	end

	//Flatten the Buffer Interface to make it easier to write the elementwise product
	//The buffers have to be flattened backwards if time is respected as older -> newer => small index -> big index

	for(gi=0; gi<numBuffers; gi=gi+1) begin
		assign flatBuffer[gi*numChannels + gh] = buffers[gh][numBuffers - gi - 1];
	end

	//Generate a tree of adders that will optimally sum the largest possible FIR length

	//assign next_sum[gh][numSum-1] = sum[gh][numSum-2] + sum[gh][numSum-3];
	assign results[gh] = (sum[gh][numSum-1]) >>> shift_index;
	for(gi=0; gi<sumPipelineDepth-1; gi=gi+1) begin
		for(gj=0; gj<2**gi; gj=gj+1) begin
			assign next_sum[gh][numSum-gj-2**gi] = sum[gh][numSum-2**(gi+1)- 2*gj] 
												 + sum[gh][numSum-2**(gi+1)-2*gj - 1];
		end
	end 

	//The leaf nodes on the summation tree may (and most likely will not be) a power of 2.
	//The balanced tree assumes there is 2^M leaf nodes where M is the ceiling of log2(maxWeightLength).
	
	//When the leaf nodes do not equal a power of two, there are 2^M - maxWeightLength leaf nodes
	//that will need to be summed in the next layer of the tree - up a pipeline stage - to properly build
	//the tree. This could also potentially be done at the top of the tree.
	
	//Error here in the elaboration?
	for(gi=0; gi<(maxWeightLength-2**(sumPipelineDepth-1)); gi=gi+1) begin
		assign next_sum[gh][numSum-2**(sumPipelineDepth-1) - gi] = 	products[gh][2*gi  ]
															     +  products[gh][2*gi+1];
	end



	for(gi=0; gi<2**(sumPipelineDepth)-maxWeightLength; gi=gi+1) begin
		assign next_sum[gh][numSum - maxWeightLength - gi] = products[gh][gi+2*(maxWeightLength-2**(sumPipelineDepth-1))];
	end

	//Weight and Value Multiplication - go through weights backward to simplify alignment
	for(gi=0; gi<maxWeightLength; gi=gi+1) begin
		assign next_products[gh][gi] = (weights[gh][maxWeightLength-gi-1] * flatBuffer[gi + gh]);// >>> (codeBitwidth-sumPipelineDepth);
	end

	//Run the pipeline at the clock rate.
	always @(posedge clk, negedge rstb) begin
	    if (!rstb) begin
	        for(jj=0;jj<numBuffers;jj=jj+1) begin
	   	        buffers[gh][jj] <= 0;
	   	    end
	        results[gh] <= 0;
	    end else begin
			for(jj=0; jj<numBuffers-1; jj=jj+1) begin
				buffers[gh][jj+1] <= next_buffers[gh][jj];
			end
		    buffers[gh][0] <= codes[gh];

		    for(jj=0; jj<numSum; jj=jj+1) begin
		       	sum[gh][jj] <= next_sum[gh][jj];
		    end

		    for(jj=0; jj<maxWeightLength; jj=jj+1) begin
		    	weights[gh][jj] <= new_weights[gh][jj];
		    	products[gh][jj] <= next_products[gh][jj];
		    end
		end
	end
end

endgenerate
endmodule
