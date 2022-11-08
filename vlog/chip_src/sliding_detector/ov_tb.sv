module overflow_testbench ();

    import test_vectors::num_of_vects;
    import test_vectors::chan_vals;
    import test_vectors::positions;
    import test_vectors::errs_test_vectors;
    import test_vectors::bits_test_vectors;


    parameter integer seq_length = 4;
    parameter integer est_error_bitwidth = 9;
    parameter integer est_channel_bitwidth = 9;
    parameter integer num_of_flip_patterns = 5;
    parameter integer flip_pattern_depth = 4;
    parameter integer flip_patterns[num_of_flip_patterns-1:0][flip_pattern_depth-1:0] = '{'{1,1,1,1},'{0,1,1,1},'{0,1,0,1},'{0,0,1,1}, '{0,0,1,0}};
    parameter integer ener_bitwidth = 18;

    //Inputs
    logic signed [est_error_bitwidth-1:0] est_err [seq_length-1:0];
    logic bits [seq_length-1:0];
    logic signed [est_channel_bitwidth-1:0] chan [flip_pattern_depth + seq_length-2:0];

    //Outputs
    logic [$clog2(num_of_flip_patterns)-1:0] err_flag ;
    logic signed [ener_bitwidth-1:0] mmse_val;

    sliding_detector_single_slice #(
        .seq_length(seq_length), 
        .est_error_bitwidth(est_error_bitwidth), 
        .est_channel_bitwidth(est_channel_bitwidth),
        .num_of_flip_patterns(num_of_flip_patterns),
        .flip_pattern_depth  (flip_pattern_depth),
        .flip_patterns(flip_patterns),
        .ener_bitwidth(ener_bitwidth)
    ) sd_slice_i (
        .residual_error_trace(est_err),
        .bits(bits),
        .channel(chan),
        .error_flag(err_flag),
        .mmse_val(mmse_val)
    );


    integer fid;
    initial begin
        #1
        #1
        /*fid = $fopen("possible_vectors.txt", "w");
        for(int ii = 0; ii < num_of_vects; ii += 1) begin
            est_err = errs_test_vectors[ii];
            bits = bits_test_vectors[ii];
            chan = chan_vals;
            #1
            if(err_flag) begin
                $display("est_errs: %p\nbits: %p", est_err, bits);
                $display("err_flag: %d\nmmse_val: %d", err_flag, mmse_val);
                $display("mmse_vals: %p", sd_slice_i.mse_val);
                $fwrite(fid, "%d, ", ii);
            end
        end
        $fclose(fid);*/

        for(int ii =56; ii < 57; ii += 1) begin
            est_err = errs_test_vectors[positions[ii]][3:0];
            bits = bits_test_vectors[positions[ii]][3:0];
            chan = chan_vals[6:0];
            #1
            $display("est_errs: %p\nbits: %p", est_err, bits);
            $display("err_flag: %d\nmmse_val: %d", err_flag, mmse_val);
            $display("mmse_vals: %p", sd_slice_i.mse_val);
        end
    end

endmodule : overflow_testbench