module error_injection_engine #(
        parameter integer seq_length = 3,
        parameter integer est_err_bitwidth = 9,
        parameter integer trellis_pattern_depth = 3,
        parameter integer branch_bitwidth = 2,
        parameter integer num_of_trellis_patterns = 3,
        parameter integer cp=2,
        parameter integer est_channel_bitwidth = 8
) (
    input logic signed [est_channel_bitwidth-1:0] channel  [(seq_length+trellis_pattern_depth-1)-1:0],
    input logic signed [branch_bitwidth-1:0] trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0],
    input logic nrz_mode,

    output logic signed [est_err_bitwidth-1:0] injection_error_seqs [2*num_of_trellis_patterns-1:0][seq_length-1:0]
) ;

    always_comb begin
        // Initialize Injection Error Sequences to Zero
        for(int ii = 0; ii < num_of_trellis_patterns; ii += 1) begin
            for(int jj =0; jj < seq_length; jj += 1) begin
                injection_error_seqs[2*ii][jj] = 0;
                injection_error_seqs[2*ii+1][jj] = 0;
            end
        end

        // Calculate the two types of injectable errors (the polarity inversed and polarity normal versions of the trellis pattern)
        for(int ii = 0; ii < num_of_trellis_patterns; ii += 1) begin
            for (int jj = 0; jj < seq_length; jj += 1) begin
                for(int kk =0; kk < trellis_pattern_depth; kk += 1) begin
                    if( cp- kk + jj > 0) begin
                        injection_error_seqs[2*ii][jj]   += ((nrz_mode) ? 3 : 1)*trellis_patterns[ii][kk]*2*channel[(cp-kk) + jj];
                        injection_error_seqs[2*ii+1][jj] += ((nrz_mode) ? -3 : -1)*trellis_patterns[ii][kk]*2*channel[(cp-kk) + jj];
                    end
                end
            end
        end
    end


endmodule 