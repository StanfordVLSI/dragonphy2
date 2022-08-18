module fp_checker #(
        parameter integer seq_length = 3,
        parameter integer flip_pattern_depth = 3,
        parameter integer est_err_bitwidth=8,
        parameter integer flip_pattern [flip_pattern_depth-1:0] = {0,1, 0},
        parameter integer cp=2,
        parameter integer max_bitwidth = 10,
        parameter integer est_channel_bitwidth = 8,
        parameter integer ener_bitwidth = 18
)(
        input logic signed [est_err_bitwidth-1:0]       seq [seq_length-1:0],
        input logic                            bits     [seq_length-1:0],
        input logic signed [est_channel_bitwidth-1:0] channel  [(seq_length+flip_pattern_depth-1)-1:0],
        output logic [ener_bitwidth-1:0] mse_val
);

    logic signed [est_channel_bitwidth+$clog2(flip_pattern_depth)-1:0] partial_error [flip_pattern_depth-1:0][seq_length-1:0];
    logic signed [est_channel_bitwidth+$clog2(flip_pattern_depth)-1:0] error [seq_length-1:0];
    logic [max_bitwidth*2+4-1:0] sqr_val;

    genvar gi;
/*
    initial begin
    //    $monitor("%p, partial_error[0]: %p", flip_pattern, partial_error[0]);
    //    $monitor("%p, partial_error[1]: %p", flip_pattern, partial_error[1]);
    //    $monitor("%p, partial_error[2]: %p", flip_pattern, partial_error[2]);
        $monitor("%m, %p, error: %p", flip_pattern, error);
        $monitor("%m, %p, rsd:   %p", flip_pattern, seq);
    end*/

    generate
        for(gi = 0; gi < flip_pattern_depth; gi += 1) begin
            if(flip_pattern[gi]) begin
                always_comb begin
                    for (int ii = 0; ii < seq_length; ii += 1) begin
                        if( cp-gi + ii > 0) begin
                            partial_error[gi][ii] = bits[gi] ? -2*channel[(cp-gi) + ii] : 2*channel[(cp-gi) + ii];
                        end else begin
                            partial_error[gi][ii] = 0;
                        end
                    end
                end
            end else begin
                always_comb begin
                    for (int ii = 0; ii < seq_length; ii += 1) begin
                        partial_error[gi][ii] = 0;
                    end                    
                end
            end
        end
    endgenerate


    always_comb begin
        for(int ii = 0; ii < seq_length; ii = ii + 1) begin
            error[ii] = seq[ii];
            for(int jj = 0; jj < flip_pattern_depth; jj = jj + 1) begin
                error[ii] += partial_error[jj][ii];
            end
        end

        mse_val = 0;
        sqr_val = 0;
        for (int ii = 0; ii < seq_length; ii = ii + 1) begin
            sqr_val = (error[ii])**2;
            mse_val += sqr_val[ener_bitwidth-1:0];
        end
    end


endmodule // fp_checker