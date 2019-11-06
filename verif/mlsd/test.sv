module shiftTestBench();
	parameter integer channelWidth = 32;
	parameter integer codeBitwidth = 8;
	parameter integer estBitwidth  = 8;
	parameter integer estDepth     = 11;
	parameter integer seqLength    = 10;

	parameter integer numPastBuffers  = $ceil(real'(estDepth-1)*1.0/channelWidth);
	parameter integer numFutureBuffers = $ceil(real'(seqLength-1)*1.0/channelWidth);

	parameter integer bufferDepth   = numPastBuffers + numFutureBuffers + 1;
	parameter integer centerBuffer  = numPastBuffers;


	parameter integer testLength   = channelWidth*(bufferDepth*2 + 1);

	logic clk;
	logic rstb;

	logic start;
	integer pos; 

	logic signed [estBitwidth-1:0]   channel_est [channelWidth-1:0][estDepth-1:0];
	logic signed [codeBitwidth-1:0]  dataStream  [channelWidth-1:0][testLength-1:0];
	logic 							 bitStream   [channelWidth-1:0][testLength-1:0];

	logic signed [codeBitwidth-1:0]  data 		 [channelWidth-1:0];
	logic 							 bits 		 [channelWidth-1:0];	
    
    logic signed [1:0]               s_bits  	 [channelWidth*testLength-1:0];
    logic signed [codeBitwidth-1:0]  s_codes 	 [channelWidth*testLength-1:0];
	logic signed [codeBitwidth-1:0]  est_seq_out [1:0][channelWidth-1:0][seqLength-1:0];
	logic 							 p_bit 		 [channelWidth-1:0];
	logic signed [1:0] 				 sp_bits 	 [channelWidth*testLength-1:0];

	logic signed [codeBitwidth-1:0] prev_mlsd_energy [1:0][channelWidth-1:0];

	flat_mlsd #(
		.numChannels (channelWidth),
		.codeBitwidth(codeBitwidth),
		.estBitwidth (estBitwidth),
		.estDepth    (estDepth),
		.seqLength   (seqLength)
	) flat_mlsd_i (
		.codes         (data),
		.channel_est   (channel_est),
		.estimate_bits(bits),
		.clk           (clk),
		.rstb          (rstb),
		.predict_bits          (p_bit)
	);

	integer ii, jj, kk, fid1, fid2, fid3;
	initial begin
		start = 0;
		clk   = 0;
		rstb  = 0;
		pos   = 0;
		for(ii=0; ii<channelWidth; ii=ii+1) begin
			data[ii] = 0;
			bits[ii] = 0;
			for(jj=0; jj<testLength; jj=jj+1) begin
				bitStream[ii][jj]  = $urandom() & 1;
			end

			for(jj=1; jj<estDepth; jj=jj+1) begin
				channel_est[ii][jj] = estDepth - jj - 1;
			end
			channel_est[ii][0] = $floor((estDepth-1)/2.0);
		end

		//Linearize the Bits from the Bit Stream
        for(ii=0; ii<channelWidth; ii=ii+1) begin
            for(jj=0; jj<testLength; jj=jj+1) begin
                s_bits[jj*channelWidth + ii] = 2*bitStream[ii][jj] - 1;
            end
        end

        //Calculate the convolution of the bits with the triangular channel response
        fid1 = $fopen("conv_codes.txt", "w");
        fid2 = $fopen("conv_bits.txt", "w");
        fid3 = $fopen("mlsd_seq.txt", "w");
        for(ii=0; ii<channelWidth*testLength; ii=ii+1) begin
            s_codes[ii] = 0;
            $fwrite(fid2, "%d\n", s_bits[ii]);
            for(jj=0; jj<estDepth; jj=jj+1) begin
                if(ii >= jj) begin
                    s_codes[ii] = s_codes[ii] + s_bits[ii-jj]*channel_est[0][jj];
                end
            end
            $fwrite(fid1, "%d\n", s_codes[ii]);
        end

        //Convert convolution into channelized response
        for(ii=0; ii<channelWidth; ii=ii+1) begin
        	for(jj=0; jj<testLength; jj=jj+1) begin
				dataStream[ii][jj] = s_codes[jj*channelWidth+ii];
			end
		end
        $fclose(fid1);
        $fclose(fid2);
		toggle_clk();
		rstb = 1;
		repeat(5) toggle_clk();
		start = 1;
		repeat(3) toggle_clk();
        repeat(testLength-3)  begin
            toggle_clk();
            for(jj=0; jj<channelWidth; jj=jj+1) begin
                for(ii=0; ii<seqLength; ii=ii+1) begin
                    $fwrite(fid3, "%d ", flat_mlsd_i.est_seq[0][jj][ii]);
                end
                $fwrite(fid3, "|");
                for(ii=0; ii<seqLength; ii=ii+1) begin
                    $fwrite(fid3, "%d ", flat_mlsd_i.est_seq[1][jj][ii]);
                end
                $fwrite(fid3, "| %d %d ", p_bit[jj], bitStream[jj][pos-4]);
                $fwrite(fid3, "| %d ", $signed(dataStream[jj][pos-4]));
                $fwrite(fid3, "| %d %d", prev_mlsd_energy[0][jj], prev_mlsd_energy[1][jj]);
                $fwrite(fid3, "\n");
            end
            $fwrite(fid3, "-------------------------------------------------------------------------------------\n");
        end
	end


	always @(posedge clk) begin
		if((pos < testLength) && start) begin
			foreach( data[ii] ) begin
				data[ii] = dataStream[ii][pos];
				bits[ii] = bitStream[ii][pos];
			end
			pos = pos + 1;
		end else begin
			foreach( data[ii] ) begin
				data[ii] = 0;
				bits[ii] = 0;
			end
		end

		for(ii=0; ii<channelWidth; ii=ii+1) begin
			prev_mlsd_energy[0][ii] = flat_mlsd_i.comb_mlsd_dec_i.error_energ[0][ii];
			prev_mlsd_energy[1][ii] = flat_mlsd_i.comb_mlsd_dec_i.error_energ[1][ii];
		end
	end

	task toggle_clk;
		#500ps clk = 1;
		#500ps clk = 0;
	endtask

endmodule : shiftTestBench
