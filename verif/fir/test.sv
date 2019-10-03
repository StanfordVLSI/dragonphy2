module test import constant_pack::*; (); 
   
   parameter integer N_test = 100;
   parameter integer dataWidth = 5;

   logic clk;
   logic rstb;

   logic signed [7:0] weights    [channel_width-1:0][ffe_length-1:0];
   logic signed [7:0] dataStream [channel_width-1:0][N_test-1:0];
   logic signed [7:0] data 	  [channel_width-1:0];
   wire logic signed [7:0] out  	  [channel_width-1:0];

   ffe #(
   		.maxWeightLength(ffe_length),
	 		.numChannels(channel_width),
	 		.codeBitwidth(code_precision),
	 		.weightBitwidth(8),
	 		.resultBitwidth(8)
	    ) 
   ffe_inst1
   		(
   			.clk(clk),
   			.rstb       (rstb),
   			.new_weights(weights),
   			.codes      (data),
   			.results    (out)
   		);

   	integer ii,jj, pos;

   	initial begin
         clk        <= 0;
         pos        <= 0;

         for(jj=0;jj<dataWidth;jj=jj+1) begin
            data[jj] <=0;
         end


         repeat(5) toggle_clk();

   		for(ii=0;ii<N_test;ii=ii+1) begin
            for(jj=0;jj<dataWidth;jj=jj+1) begin
   			   dataStream[jj][ii] <= (jj + ii*dataWidth) >> ($clog2(N_test*dataWidth) - 7); //$random();
            end
   		end

   		repeat(150) toggle_clk();
   	end

   	always @(posedge clk) begin
   		if(pos < N_test) begin 
            for(jj=0;jj<dataWidth;jj=jj+1) begin
     			    data[jj]  = dataStream[jj][pos];
            end
   			pos   = pos + 1;
   		end else begin
            for(jj=0;jj<dataWidth;jj=jj+1) begin
                data[jj]  = 0;
            end
         end
   	end

   	task toggle_clk;
   		#1ns clk = 1;
   		#1ns clk = 0;
   	endtask

endmodule
