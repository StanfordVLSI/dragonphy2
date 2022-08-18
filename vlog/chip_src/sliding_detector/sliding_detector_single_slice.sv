
module sliding_detector_single_slice #( 
    parameter integer seq_length=3,
    parameter integer num_of_flip_patterns = 4,
    parameter integer flip_pattern_depth   = 3,
    parameter integer flip_patterns[num_of_flip_patterns-1:0][flip_pattern_depth-1:0] = '{'{0,1,0}, '{0,1,1}, '{1,1,1},'{1,0,1}},
    parameter integer est_error_bitwidth = 8,
    parameter integer est_channel_bitwidth = 8,
    parameter integer ener_bitwidth = 18,
    parameter integer max_bitwidth = 8
) (
    input logic signed [est_error_bitwidth-1:0] residual_error_trace [seq_length-1:0],
    input logic bits [seq_length-1:0],
    input logic signed [est_channel_bitwidth-1:0] channel [flip_pattern_depth+seq_length-1-1:0],

    output logic [$clog2(num_of_flip_patterns+1)-1:0] error_flag,
    output logic [ener_bitwidth-1:0] mmse_val
);
    logic [ener_bitwidth-1:0] mse_val [num_of_flip_patterns:0];
    logic [max_bitwidth*2+4-1:0] sqr_val ;

//    initial begin
//        $monitor("MSE_VAL: %p", mse_val);
//    end

    always_comb begin
        mse_val[0] = 0;
        sqr_val = 0;
        for(int ii = 0; ii < seq_length; ii = ii + 1) begin
            sqr_val = (residual_error_trace[ii])**2;
            mse_val[0] += sqr_val;
        end
    end

    genvar gi;
    generate
        for(gi = 0; gi < num_of_flip_patterns; gi += 1) begin
            fp_checker #(
                .flip_pattern_depth(flip_pattern_depth),
                .est_err_bitwidth(est_error_bitwidth),
                .flip_pattern(flip_patterns[gi]),
                .seq_length(seq_length),
                .cp(2),
                .max_bitwidth(max_bitwidth),
                .est_channel_bitwidth(est_channel_bitwidth),
                .ener_bitwidth(ener_bitwidth)
            ) fpc_i (
                .seq(residual_error_trace),
                .bits(bits),
                .channel(channel),
                .mse_val(mse_val[gi+1])
            );
        end
    endgenerate

    always_comb begin
        error_flag = 0;
        for(int ii = 1; ii < num_of_flip_patterns+1; ii = ii + 1) begin
            error_flag = (mse_val[error_flag] > mse_val[ii]) ? ii : error_flag;
        end
        mmse_val = mse_val[error_flag][ener_bitwidth-1:0];
    end
    

endmodule // sliding_detector_single_slice