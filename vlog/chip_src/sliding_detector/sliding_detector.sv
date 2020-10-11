module sliding_detector #(
    parameter integer seq_length=3,
    parameter integer width=16,
    parameter integer depth=30,
    parameter integer est_error_bitwidth=8,
    parameter integer est_channel_bitwidth=8,
    parameter integer max_bitwidth=8,
    parameter integer sliding_detector_depth=2
) (
    input logic signed [est_error_bitwidth-1:0]  errstream [width*sliding_detector_depth-1:0],
    input logic                                   bitstream [width*sliding_detector_depth-1:0],
    input logic signed [est_channel_bitwidth-1:0] channel [width-1:0][depth-1:0],

    output logic signed [est_error_bitwidth*2+2-1:0] sqr_inj_error [3:0][width-1:0][seq_length-1:0],
    output logic [1:0] mmse_err_pos [width-1:0]
);

    logic signed [est_channel_bitwidth-1:0] error [width:0][seq_length:0];
    logic signed [max_bitwidth*2+4-1:0] sqr_error [1:0][width-1:0][seq_length:0];
    logic        [max_bitwidth*2+4+$clog2(seq_length)-1:0] mse_err [3:0][width-1:0];

    logic        [max_bitwidth*2+4+$clog2(seq_length)-1:0] mmse_err [width-1:0];


    integer ii,jj,kk;
    always_comb begin
        //Select the correct polarity of the injected inverse-error-vector
        for(ii=0; ii<width; ii=ii+1) begin
            for(jj=0; jj<seq_length+1; jj=jj+1) begin
                error[ii][jj] = bitstream[ii] ? channel[ii][jj] : -channel[ii][jj];
            end
        end
        for(jj=0; jj<seq_length+1; jj=jj+1) begin
            error[width][jj] = bitstream[width] ? channel[0][jj] : -channel[0][jj];
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
                    mse_err[kk][ii] = mse_err[kk][ii] + sqr_inj_error[kk][ii][jj];
                end
            end
        end
        //Rank the sum square errors and return the position of the smallest error
        for(ii=0; ii<width; ii=ii+1) begin
            mmse_err[ii] = mse_err[0][ii];
            mmse_err_pos[ii] = 0;
            for(jj=1; jj<4; jj=jj+1) begin
                mmse_err[ii] = (mmse_err[ii] > mse_err[jj][ii]) ? mse_err[jj][ii] : mmse_err[ii];
                mmse_err_pos[ii] = (mmse_err[ii] > mse_err[jj][ii]) ? jj : mmse_err_pos[ii];
            end 
        end
    end



endmodule : sliding_detector
