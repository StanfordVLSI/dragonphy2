module test ();
   
   parameter integer N_test = 100;
   parameter integer dataWidth = 5;

   logic clk;
   logic rstb;

   logic signed [7:0] weights    [dataWidth-1:0][12:0];
   logic signed [7:0] dataStream [dataWidth-1:0][N_test-1:0];
   logic signed [7:0] data 	  [dataWidth-1:0];
   wire logic signed [7:0] out  	  [dataWidth-1:0];

   ffe_weight_scales #(
   		.maxWeightLength(13),
	 		.numChannels(dataWidth),
	 		.codeBitwidth(8),
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

   		weights[0] <= '{1,-1,1,0,0,0,0,-1,1,0,0,0,0};
   		weights[1] <= '{-1,1,1,0,0,0,0,-1,1,0,0,0,0};
         weights[2] <= '{-1,1,0,0,0,0,0,-1,1,0,0,0,0};
         weights[3] <= '{1,-1,1,0,0,0,0,-1,1,0,0,0,0};
         weights[4] <= '{-1,1,1,0,0,0,0,-1,1,0,0,0,0};

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
