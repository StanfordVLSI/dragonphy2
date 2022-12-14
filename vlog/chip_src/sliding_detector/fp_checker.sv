module fp_checker #(
        parameter integer seq_length = 3,
        parameter integer flip_pattern_depth = 3,
        parameter integer est_err_bitwidth=8,
        parameter integer flip_pattern [flip_pattern_depth-1:0] = {0,1, 0},
        parameter integer cp=2,
        parameter integer est_channel_bitwidth = 8,
        parameter integer ener_bitwidth = 18
)(
        input logic signed [est_err_bitwidth-1:0]       seq [seq_length-1:0],
        input logic                            bits     [seq_length-1:0],
        input logic signed [est_channel_bitwidth-1:0] channel  [(seq_length+flip_pattern_depth-1)-1:0],
        input logic [3:0] channel_shift,
        output logic overflow,
        output logic [ener_bitwidth-1:0] mse_val
);
    localparam integer shift_factor = 0;
    localparam integer chan_shift_factor = 3;
    logic signed [est_channel_bitwidth+1-1:0] partial_error [flip_pattern_depth-1:0][seq_length-1:0];
    logic signed [est_err_bitwidth+$clog2(flip_pattern_depth)+1-1:0] error [seq_length-1:0];
    logic signed [est_err_bitwidth+$clog2(flip_pattern_depth)+1-1-chan_shift_factor:0] div_one_error [seq_length-1:0];
    logic signed [est_err_bitwidth+$clog2(flip_pattern_depth)+1-1-chan_shift_factor-shift_factor:0] div_two_error [seq_length-1:0];
    logic [ener_bitwidth-2*shift_factor-1:0] sqr_val;


    genvar gi;
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

    logic err_sign, prt_err_sign, pst_op_err_sign, dv_one_err_sign, seq_sign, pst_op_dv_one_err_sign;
    logic signed [ener_bitwidth-1:0] prev_op_mse_val;


    always_comb begin
        overflow = 0;
        for(int ii = 0; ii < seq_length; ii = ii + 1) begin
            error[ii] = 0;
            for(int jj = 0; jj < flip_pattern_depth; jj = jj + 1) begin
                err_sign = error[ii][est_err_bitwidth+$clog2(flip_pattern_depth)+1-1];
                prt_err_sign = partial_error[jj][ii][est_channel_bitwidth+1-1];
                error[ii] += partial_error[jj][ii];
                pst_op_err_sign = error[ii][est_err_bitwidth+$clog2(flip_pattern_depth)+1-1];

                overflow = overflow || (err_sign == prt_err_sign) && (err_sign != pst_op_err_sign);
            end
            div_one_error[ii] = error[ii][est_err_bitwidth+$clog2(flip_pattern_depth)+1-1:chan_shift_factor];

            dv_one_err_sign = div_one_error[ii][est_err_bitwidth+$clog2(flip_pattern_depth)+1-1-chan_shift_factor];
            seq_sign = seq[ii][est_err_bitwidth-1];

            div_one_error[ii] += seq[ii];

            pst_op_dv_one_err_sign = div_one_error[ii][est_err_bitwidth+$clog2(flip_pattern_depth)+1-1-chan_shift_factor];
            overflow = overflow || (dv_one_err_sign == seq_sign) && (dv_one_err_sign != pst_op_dv_one_err_sign);
        end
        mse_val = 0;
        sqr_val = 0;
        for (int ii = 0; ii < seq_length; ii = ii + 1) begin
            div_two_error[ii] = div_one_error[ii][est_err_bitwidth+$clog2(flip_pattern_depth)+1-1-chan_shift_factor:shift_factor];
            sqr_val = ((div_two_error[ii])**2 );

            prev_op_mse_val = mse_val;
            mse_val += sqr_val;

            overflow = overflow || (prev_op_mse_val > mse_val);
        end
    end


endmodule // fp_checker