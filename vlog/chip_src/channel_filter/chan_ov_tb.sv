module tb();

    logic act_backwards_vector [35:0];
    logic act_forwards_vector [35:0];
    logic est_backwards_vector [35:0];
    logic est_forwards_vector [35:0];

    logic act_bitstream [30:0];
    logic est_bitstream [30:0];

    logic signed [9:0] chan_est [15:0];
    logic signed [9:0] multi_chan_est [15:0][15:0];
    logic signed [7:0] est_code [15:0];
    logic signed [7:0] act_code [15:0];
    logic signed [8:0] est_error [15:0];

    logic [1:0] multi_shift [15:0];

    channel_filter #(
        .width(16), 
        .depth(16), 
        .est_channel_bitwidth(10), 
        .est_code_bitwidth(8), 
        .shift_bitwidth(2)
    ) est_chan_i (
        .bitstream      (est_bitstream),
        .channel        (multi_chan_est),
        .shift          (multi_shift),
        .est_code       (est_code)
    );

    channel_filter #(
        .width(16), 
        .depth(16), 
        .est_channel_bitwidth(10), 
        .est_code_bitwidth(8), 
        .shift_bitwidth(2)
    ) act_chan_i (
        .bitstream      (act_bitstream),
        .channel        (multi_chan_est),
        .shift          (multi_shift),
        .est_code       (act_code)
    );

    always_comb begin
        for(int ii = 0; ii < 36; ii += 1) begin
            act_forwards_vector[ii] = act_backwards_vector[35-ii];
            est_forwards_vector[ii] = est_backwards_vector[35-ii];
        end
        for(int ii = 0; ii < 16; ii += 1) begin
            for(int jj = 0; jj < 16; jj += 1) begin
                multi_chan_est[ii][jj] = chan_est[jj];
            end
            multi_shift[ii] = 3;
        end
    end

    initial begin
        chan_est         = '{6, 7, 8, 9, 10, 13, 16, 19, 26, 36, 53, 86, 160, 302, 79, 0};
        est_backwards_vector = '{1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1};
        act_backwards_vector   = '{1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1};
        for(int jj = 0; jj < 5; jj += 1) begin
            #1
            for(int ii = 0; ii < 31; ii += 1) begin
                act_bitstream[ii] = act_forwards_vector[ii+jj];
                est_bitstream[ii] = est_forwards_vector[ii+jj];
            end
            #1
            for(int ii = 0; ii < 16; ii += 1) begin
                est_error[ii] = est_code[ii] - act_code[ii];
            end
            $display("est_code: %p | act_code: %p", est_code, act_code);
            $display("est_error: %p",est_error);

        end

    end

endmodule : tb