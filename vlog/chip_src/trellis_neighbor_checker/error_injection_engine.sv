module error_injection_engine #(
        parameter integer seq_length = 3,
        parameter integer trellis_pattern_depth = 3,
        parameter integer branch_bitwidth = 2,
        parameter integer num_of_trellis_patterns = 3,
        parameter integer cp=2,
        parameter integer est_channel_bitwidth = 8
)(

) (
    input logic signed [est_channel_bitwidth-1:0] channel  [(seq_length+flip_pattern_depth-1)-1:0],
    input logic signed [branch_bitwidth-1:0] trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0],
    input logic nrz_mode,

    output logic signed [est_error_bitwidth-1:0] injection_error_seqs [2*num_of_trellis_patterns-1:0][seq_length-1:0]
) ;

    always_comb begin
        // Initialize Injection Error Sequences to Zero
        for(ii = 0; ii < num_of_trellis_patterns; ii += 1) begin
            for(int jj =0; jj < seq_length; kk += 1) begin
                injection_error_seqs[2*ii][jj] = 0;
                injection_error_seqs[2*ii+1][jj]] = 0;
            end
        end

        // Calculate the two types of injectable errors (the polarity inversed and polarity normal versions of the trellis pattern)
        for(ii = 0; ii < num_of_trellis_patterns; ii += 1) begin
            for (int jj = 0; jj < seq_length; jj += 1) begin
                for(int kk =0; kk < trellis_pattern_depth; kk += 1) begin
                    if( cp- kk + jj > 0) begin
                        injection_error_seqs[2*ii][jj]   += trellis_patterns[ii][kk]*2*channel[(cp-kk) + jj];
                        injection_error_seqs[2*ii+1][jj] += -trellis_patterns[ii][kk]*2*channel[(cp-kk) + jj];
                        if(nrz_mode) begin
                            injection_error_seqs[2*ii][jj]   += 3*trellis_patterns[ii][kk]*2*channel[(cp-kk) + jj];
                            injection_error_seqs[2*ii+1][jj] += -3*trellis_patterns[ii][kk]*2*channel[(cp-kk) + jj];
                        end
                    end
                end
            end
        end
    end


endmodule 