module error_injector #(

) (
    input logic signed [est_bitwidth-1:0] errstream [width+2-1:0],
    input logic signed bitstream [width:0],
    input logic signed [est_bitwidth-1:0] centered_channel [seq_length-1:0],

    output logic signed [est_bitwidth*2-1:0] sqr_inj_error [3:0][width-1:0][seq_length-2:0]
);
    logic signed [est_bitwidth-1:0] error [width:0][seq_length-1:0];
    logic signed [est_bitwidth*2-1:0] sqr_error [1:0][width-1:0][seq_length-1:0];

    //You need the extra bit for the stitching to work!
    error_selector #(
        .seq_length  (seq_length),
        .est_bitwidth(est_bitwidth),
        .width(width+1)
    ) err_sel_i (
        .bitstream(bitstream),
        .centered_channel(centered_channel),
        .error(error)
    );

    integer ii,jj;

    always_comb begin
        for(ii=0; ii<width; ii=ii+1) begin
            for(jj=0; jj<seq_length-1; jj=jj+1) begin
                sqr_error[0][ii][jj] = (errstream[ii+jj] + error[ii][jj])**2;
                sqr_error[1][ii][jj] = (errstream[ii+jj] + error[ii+1][jj] + error[ii][jj+1])**2;
            end
            sqr_error[0][ii][jj] = (errstream[ii+jj] + error[ii][jj])**2;

            for(jj=0; jj<seq_length-1; jj=jj+1) begin
                sqr_inj_error[0][ii][jj] = errstream[ii+jj]**2;
                sqr_inj_error[1][ii][jj] = sqr_error[0][ii][jj+1];
                sqr_inj_error[2][ii][jj] = sqr_error[0][ii+1][jj];
                sqr_inj_error[3][ii][jj] = sqr_error[1][ii][jj];
            end
        end
    end


endmodule : error_injector