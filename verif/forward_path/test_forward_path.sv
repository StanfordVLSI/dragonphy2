module forward_testbench();
    parameter integer nbit         = mlsd_gpack::bit_length;
    parameter integer cbit         = mlsd_gpack::est_center;
    parameter integer num_of_test_cycles  = int'(test_gpack::num_of_codes/constant_gpack::channel_width);


	logic clk;
	logic rstb;
	logic start;
	integer pos; 


    logic signed [constant_gpack::code_precision-1:0]  	test_codes  [constant_gpack::channel_width-1:0][num_of_test_cycles-1:0];
	logic signed [constant_gpack::code_precision-1:0]  	data 	   [constant_gpack::channel_width-1:0];
	
	logic signed [ffe_gpack::weight_precision-1:0] 		ffe_weights [ffe_gpack::length-1:0][ffe_gpack::width-1:0];
	logic 		 [ffe_gpack::shift_precision-1:0]  		ffe_shift   [ffe_gpack::width-1:0];

	logic		 								   		update_weights   [ffe_gpack::length-1:0][ffe_gpack::width-1:0];
	logic 										   		update_ffe_shift [ffe_gpack::width-1:0];

	logic signed [cmp_gpack::thresh_precision-1:0] 	thresh [cmp_gpack::width-1:0];
	logic 		 									 	update_thresh [cmp_gpack::width-1:0];

	logic signed [mlsd_gpack::estimate_precision-1:0]  	channel_est 	   [mlsd_gpack::width-1:0][mlsd_gpack::estimate_depth-1:0];
	logic 		 [mlsd_gpack::shift_precision-1:0] 	   	mlsd_shift  	   [mlsd_gpack::width-1:0];
	logic signed [mlsd_gpack::estimate_precision-1:0]  	precalc_seq_vals [2**nbit-1:0][mlsd_gpack::width-1:0][mlsd_gpack::length-1:0];

    logic signed [nbit+mlsd_gpack::estimate_precision-1:0] sum_precalc_seq_vals [2**nbit-1:0][mlsd_gpack::width-1:0][mlsd_gpack::length-1:0];
    logic        [nbit+mlsd_gpack::estimate_precision-1:0] sum_precalc_mask;

    logic signed [1:0] precalc_bit_vector [2**nbit-1:0][nbit-1:0];

	logic 		 									   	update_channel_est [mlsd_gpack::width-1:0][mlsd_gpack::estimate_depth-1:0];
	logic 											   	update_mlsd_shift  [mlsd_gpack::width-1:0];
	logic 											   	update_precalc	   [2**nbit-1:0][mlsd_gpack::width-1:0][mlsd_gpack::length-1:0];

	logic 	[nbit-1:0]											checked_bits	   [mlsd_gpack::width-1:0];
	logic 	[nbit-1:0]											out_bits 		   [mlsd_gpack::width-1:0][num_of_test_cycles-1:0];

	logic signed [constant_gpack::code_precision-1:0] read_test_code [test_gpack::num_of_codes-1:0];

    assign sum_precalc_mask = ({mlsd_gpack::estimate_precision+nbit{1'b1}} >> nbit);

	forward_path forward_path_i (
		.codes (data),

    	.new_weights(ffe_weights),
   		.update_weights(update_weights),
	 	
	 	.new_ffe_shift (ffe_shift),    
    	.update_ffe_shift (update_ffe_shift),   
	    
	    .new_thresh  (thresh),
    	.update_thresh(update_thresh),
		
		.new_channel_est (channel_est),
    	.update_channel_est (update_channel_est),
	  	
	  	.new_mlsd_shift(mlsd_shift),    
    	.update_mlsd_shift(update_mlsd_shift),
	 	
	 	.new_precalc_seq_vals(precalc_seq_vals),
    	.update_precalc(update_precalc),
	 	
	 	.clk(clk),
		.rstb(rstb),
		
		.checked_bits(checked_bits)
	);

	integer ii, jj, kk, ll, fid;
	initial begin
		start = 0;
		clk   = 0;
		rstb  = 0;
		pos   = 0;
		reset_all_updates();


	    load_ffe_values();  //Load FFE weights and shift value
	  	load_comp_values(); // Load Comparator Threshold
		load_mlsd_values(); // Load Channel Estimate and Shift Value

        for(ii=0; ii<2**nbit; ii=ii+1) begin
            for(jj=0; jj<nbit; jj=jj+1) begin
               precalc_bit_vector[ii][jj] = ((ii >> jj) & 1 == 1) ? 1 : -1;
            end
        end

	  	//Calculate Static MLSD Sequences 
	  	for(ii=0; ii<mlsd_gpack::width; ii=ii+1) begin
			for(jj=0; jj<mlsd_gpack::length; jj=jj+1) begin
				for(kk=0; kk<2**nbit; kk=kk+1) begin
					sum_precalc_seq_vals[kk][ii][jj] = 0;
					for(ll=0; ll<nbit; ll=ll+1) begin
						sum_precalc_seq_vals[kk][ii][jj] = sum_precalc_seq_vals[kk][ii][jj] + $signed((jj+cbit >= ll) ? (precalc_bit_vector[kk][ll]*channel_est[ii][jj+cbit-ll]): 0);
					end
                    precalc_seq_vals[kk][ii][jj] =  sum_precalc_seq_vals[kk][ii][jj];
				end
			end
		end

		//Load Test Code Sequence
		fid = $fopen(test_gpack::test_codes_filename, "r");
		for(ii=0; ii<test_gpack::num_of_codes; ii=ii+1) begin
			void'($fscanf(fid, "%d\n", read_test_code[ii]));
			test_codes[ii % constant_gpack::channel_width][int'(ii/constant_gpack::channel_width)] = read_test_code[ii];
		end
		$fclose(fid);

		toggle_clk();
		rstb = 1'b1;

		toggle_clk();
		toggle_all_updates();
		
		toggle_clk();
		toggle_all_updates();

		repeat(2) toggle_clk();
		start = 1'b1;
		repeat(num_of_test_cycles) toggle_clk();
		start = 1'b0;

		save_out_bits(pos, test_gpack::output_filename);
	end

	always @(posedge clk) begin
		if((pos < num_of_test_cycles) && start) begin
			foreach( data[ii] ) begin
				data[ii] = test_codes[ii][pos];
			end

			foreach(out_bits[ii]) begin
				out_bits[ii][pos] = checked_bits[ii];
			end
			pos = pos + 1;
		end else begin
			foreach( data[ii] ) begin
				data[ii] = 0;
			end
		end
	end

	task toggle_clk;
		#500ps clk = 1;
		#500ps clk = 0;
	endtask

	task save_out_bits(integer final_pos, string output_filename);
		integer fid, ii, jj, kk;
		fid = $fopen(output_filename, "w");
		for(kk=0; kk<final_pos; kk=kk+1) begin
			foreach(out_bits[ii]) begin
				$fwrite(fid, "%d\n", out_bits[ii][kk]);
			end
		end
		$fclose(fid);
	endtask

	task load_ffe_values;
		integer fid, ii, jj;
		logic signed [ffe_gpack::weight_precision-1:0] read_weights [ffe_gpack::length-1:0];
		logic [ffe_gpack::shift_precision-1:0]  read_ffe_shift;
		fid = $fopen(test_gpack::ffe_values_filename, "r");
	    foreach(ffe_weights[ii]) begin
	       void'($fscanf(fid, "%d\n", read_weights[ii]));
	       foreach(ffe_weights[ii][jj]) begin
	          ffe_weights[ii][jj] = read_weights[ii];
	       end
	    end
	   	void'($fscanf(fid, "%d\n", read_ffe_shift));
		foreach(ffe_shift[ii]) begin
			ffe_shift[ii] = read_ffe_shift;
		end
		$fclose(fid);
	endtask

	task load_comp_values;
		integer fid, ii, jj;
		logic signed [cmp_gpack::thresh_precision-1:0] read_thresh;
	  	fid = $fopen(test_gpack::cmp_thresh_filename, "r");
	  	void'($fscanf(fid, "%d\n", read_thresh));
	    foreach(thresh[ii]) begin
			thresh[ii] = read_thresh;
	    end
	    $fclose(fid);
	endtask

	task load_mlsd_values;
		integer fid, ii, jj;
		logic signed [mlsd_gpack::estimate_precision-1:0] read_channel_est[mlsd_gpack::estimate_depth-1:0];
		logic [mlsd_gpack::shift_precision-1:0] read_mlsd_shift;
	    fid = $fopen(test_gpack::mlsd_values_filename, "r");

	    for(ii=0; ii<mlsd_gpack::estimate_depth; ii=ii+1) begin
	    	void'($fscanf(fid, "%d\n", read_channel_est[ii]));
			for(jj=0; jj<mlsd_gpack::width; jj=jj+1)begin
		        	channel_est[jj][ii] = read_channel_est[ii];
		    end
	    end

	   	//Load Shift Value
		void'($fscanf(fid, "%d\n", read_mlsd_shift));
		for(ii=0; ii<mlsd_gpack::width; ii=ii+1) begin
			mlsd_shift[ii] = read_mlsd_shift;
		end
		$fclose(fid);
	endtask

	task set_all_update_weights;
		integer ii, jj;
		foreach(update_weights[ii])
			foreach(update_weights[ii][jj])
				update_weights[ii][jj] = 1'b1;
	endtask

	task set_all_update_channel_est;
		integer ii, jj;
		foreach(update_channel_est[ii])
			foreach(update_channel_est[ii][jj])
				update_channel_est[ii][jj] = 1'b1;
	endtask

	task set_all_update_ffe_shift;
		integer ii;
		foreach(update_ffe_shift[ii])
			update_ffe_shift[ii] = 1'b1;
	endtask

	task set_all_update_mlsd_shift;
		integer ii;
		foreach(update_mlsd_shift[ii])
			update_mlsd_shift[ii] = 1'b1;
	endtask

	task set_all_update_thresh;
		integer ii;
		foreach(update_thresh[ii])
			update_thresh[ii] = 1'b1;
	endtask

	task set_all_update_precalc;
		integer ii, jj, kk;
		foreach(update_precalc[ii])
			foreach(update_precalc[ii][jj])
				foreach(update_precalc[ii][jj][kk])
					update_precalc[ii][jj][kk] = 1'b1;
	endtask

	task set_all_updates;
		set_all_update_weights();
		set_all_update_channel_est();
		set_all_update_ffe_shift();
		set_all_update_mlsd_shift();
		set_all_update_thresh();
		set_all_update_precalc();
	endtask

	task reset_all_update_weights;
		integer ii, jj;
		foreach(update_weights[ii])
			foreach(update_weights[ii][jj])
				update_weights[ii][jj] = 1'b0;
	endtask


	task reset_all_update_channel_est;
		integer ii, jj;
		foreach(update_channel_est[ii])
			foreach(update_channel_est[ii][jj])
				update_channel_est[ii][jj] = 1'b0;
	endtask

	task reset_all_update_ffe_shift;
		integer ii;
		foreach(update_ffe_shift[ii])
			update_ffe_shift[ii] = 1'b0;
	endtask

	task reset_all_update_mlsd_shift;
		integer ii;
		foreach(update_mlsd_shift[ii])
			update_mlsd_shift[ii] = 1'b0;
	endtask

	task reset_all_update_thresh;
		integer ii;
		foreach(update_thresh[ii])
			update_thresh[ii] = 1'b0;
	endtask

	task reset_all_update_precalc;
		integer ii, jj, kk;
		foreach(update_precalc[ii])
			foreach(update_precalc[ii][jj])
				foreach(update_precalc[ii][jj][kk])
					update_precalc[ii][jj][kk] = 1'b0;
	endtask

	task reset_all_updates;
		reset_all_update_weights();
		reset_all_update_channel_est();
		reset_all_update_ffe_shift();
		reset_all_update_mlsd_shift();
		reset_all_update_thresh();
		reset_all_update_precalc();
	endtask


	task toggle_all_update_weights;
		integer ii, jj;
		foreach(update_weights[ii])
			foreach(update_weights[ii][jj])
				update_weights[ii][jj] = !update_weights[ii][jj];
	endtask

	task toggle_all_update_channel_est;
		integer ii, jj;
		foreach(update_channel_est[ii])
			foreach(update_channel_est[ii][jj])
				update_channel_est[ii][jj] = !update_channel_est[ii][jj];
	endtask

	task toggle_all_update_ffe_shift;
		integer ii;
		foreach(update_ffe_shift[ii])
			update_ffe_shift[ii] = !update_ffe_shift[ii];
	endtask

	task toggle_all_update_mlsd_shift;
		integer ii;
		foreach(update_mlsd_shift[ii])
			update_mlsd_shift[ii] = !update_mlsd_shift[ii];
	endtask

	task toggle_all_update_thresh;
		integer ii;
		foreach(update_thresh[ii])
			update_thresh[ii] = !update_thresh[ii];
	endtask

	task toggle_all_update_precalc;
		integer ii, jj, kk;
		foreach(update_precalc[ii])
			foreach(update_precalc[ii][jj])
				foreach(update_precalc[ii][jj][kk])
					update_precalc[ii][jj][kk] = !update_precalc[ii][jj][kk];
	endtask

	task toggle_all_updates;
		toggle_all_update_weights();
		toggle_all_update_channel_est();
		toggle_all_update_ffe_shift();
		toggle_all_update_mlsd_shift();
		toggle_all_update_thresh();
		toggle_all_update_precalc();
	endtask

endmodule : forward_testbench
