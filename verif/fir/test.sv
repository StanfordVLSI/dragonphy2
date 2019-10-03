module test(); 
   
   import constant_pack::*;
   
   import test_pack;
   import ffe_pack;

   logic clk;
   logic rstb;

   logic signed [code_precision-1:0] dataStream       [channel_width-1:0][test_pack::num_of_codes-1:0];


   logic signed [ffe_pack::weight_precision-1:0] weights         [ffe_pack::width-1:0][ffe_pack::length-1:0];
   logic signed [ffe_pack:input_precision-1:0]   data            [ffe_pack::width-1:0];
   logic signed [ffe_pack:output_precision-1:0]  out  	        [ffe_pack::width-1:0];

   ffe #(
   		.maxWeightLength(ffe_pack::length),
	 		.numChannels(ffe_pack::width),
	 		.codeBitwidth(ffe_pack::input_precision),
	 		.weightBitwidth(ffe_pack::weight_precision),
	 		.resultBitwidth(ffe_pack::output_precision)
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

         for(jj=0;jj<ffe_pack::width;jj=jj+1) begin
            data[jj] <=0;
         end


         repeat(5) toggle_clk();

   		for(ii=0;ii<test_pack::num_of_codes;ii=ii+1) begin
            for(jj=0;jj<dataWidth;jj=jj+1) begin
               //Do fscanf here
   			   dataStream[jj][ii] <= (jj + ii*dataWidth) >> ($clog2(test_pack::num_of_codes*dataWidth) - 7); //$random();
            end
   		end

   		repeat(150) toggle_clk();
   	end

   	always @(posedge clk) begin
   		if(pos < test_pack::num_of_codes) begin 
            for(jj=0;jj<ffe_pack::width;jj=jj+1) begin
     			    data[jj]  = dataStream[jj][pos];
            end
   			pos   = pos + 1;
   		end else begin
            for(jj=0;jj<ffe_pack::width;jj=jj+1) begin
                data[jj]  = 0;
            end
         end
   	end

   	task toggle_clk;
   		#1ns clk = 1;
   		#1ns clk = 0;
   	endtask

endmodule
