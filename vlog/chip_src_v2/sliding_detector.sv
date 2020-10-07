module sliding_detector #(
    parameter integer seq_length=3,
    parameter integer width=16,
    parameter integer est_error_bitwidth=8,
    parameter integer est_channel_bitwidth=8,
    parameter integer sliding_detector_depth=2
) (
    input logic signed [est_errror_bitwidth-1:0]  errstream [width*sliding_detector_depth-1:0],
    input logic                                   bitstream [width*sliding_detector_depth-1:0],
    input logic signed [est_channel_bitwidth-1:0] channel [seq_length-1:0],

    output logic signed [est_bitwidth*2+2-1:0] sqr_inj_error [3:0][width-1:0][seq_length-1:0]
    output logic [1:0] mmse_err_pos [width-1:0]
);

    logic signed [est_channel_bitwidth-1:0] error [width:0][seq_length:0];
    generate
        if(est_error_bitwidth > est_channel_bitwidth) begin
            logic signed [est_error_bitwidth*2+4-1:0] sqr_error [1:0][width-1:0][seq_length:0];
            logic  [est_error_bitwidth*2+4+1:0] mse_err [3:0][width-1:0];
        end else begin
            logic signed [est_channel_bitwidth*2+4-1:0] sqr_error [1:0][width-1:0][seq_length:0];
            logic  [est_channel_bitwidth*2+4+1:0] mse_err [3:0][width-1:0];
        end
    endgenerate

    logic  [1:0] int_mmse_err_pos [1:0][width-1:0];

    integer ii,jj,kk;
    always_comb begin
        //Select the correct polarity of the injected inverse-error-vector
        for(ii=0; ii<width+1; ii=ii+1) begin
            for(jj=0; jj<seq_length+1; jj=jj=1) begin
                error[ii][jj] = bitstream[ii] ? channel[jj] : -channel[jj];
            end
        end

        //Inject an IEV at the relevant position and then square the result
        for(ii=0; ii<width; ii=ii+1) begin
            for(jj=0; jj<seq_length+1; jj=jj+1) begin
                sqr_error[0][ii][jj] = (errstream[ii+jj] + error[ii][jj])**2;
                sqr_error[1][ii][jj] = (errstream[ii+jj] + error[ii+1][jj] + error[ii][jj+1])**2;
            end
            sqr_error[0][ii][jj] = (errstream[ii+jj] + error[ii][jj])**2;

            for(jj=0; jj<seq_length; jj=jj+1) begin
                sqr_inj_error[0][ii][jj] = errstream[ii+jj]**2;
                sqr_inj_error[1][ii][jj] = sqr_error[0][ii][jj+1];
                sqr_inj_error[2][ii][jj] = sqr_error[0][ii+1][jj];
                sqr_inj_error[3][ii][jj] = sqr_error[1][ii][jj];
            end
        end
        //Sum up the squared err-errstreams
        for(kk=0; kk<4; kk=kk+1) begin
            for(ii=0; ii<width; ii=ii+1) begin
                for(jj=0; jj<seq_length; jj=jj+1) begin
                    mse_err[kk][ii] = mse_err[kk][ii] + sqr_inj_err[kk][ii][jj];
                end
            end
        end
        //Rank the sum square errors and return the position of the smallest error
        for(ii=0; ii<width; ii=ii+1) begin
            int_mmse_err_pos[0][ii] = mse_err[0][ii] < mse_err[1][ii] ? 0 : 1;
            int_mmse_err_pos[1][ii] = mse_err[2][ii] < mse_err[3][ii] ? 2 : 3;
            mmse_err_pos[ii]        = mse_err[int_mmse_err_pos[0]][ii] < mse_err[int_mmse_err_pos[1]][ii] ? 
                                      int_mmse_err_pos[0][ii] : int_mmse_err_pos[1][ii];
        end
    end



endmodule : sliding_detector