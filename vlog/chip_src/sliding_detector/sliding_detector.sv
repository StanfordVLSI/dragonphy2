module sliding_detector #(
    parameter integer seq_length=3,
    parameter integer width=16,
    parameter integer depth=30,
    parameter integer est_error_bitwidth=8,
    parameter integer est_channel_bitwidth=8,
    parameter integer max_bitwidth=8,
    parameter integer sliding_detector_depth=2,
    parameter integer t0_buff=1
) (
    input logic signed [est_error_bitwidth-1:0]  errstream [width*sliding_detector_depth-1:0],
    input logic                                   bitstream [width*sliding_detector_depth-1:0],
    input logic signed [est_channel_bitwidth-1:0] channel [width-1:0][depth-1:0],

    output logic signed [est_error_bitwidth*2+2-1:0] sqr_inj_error [3:0][width-1:0][seq_length-1:0],
    output logic [1:0] mmse_err_pos [width-1:0]
);

    localparam idx = t0_buff * width;

    logic signed [est_channel_bitwidth-1:0] error [width:0][seq_length:0];
    logic signed [max_bitwidth*2+4-1:0] sqr_single_error [width:0][seq_length:0];
    logic signed [max_bitwidth*2+4-1:0] sqr_double_error [width-1:0][seq_length-1:0];

    logic        [max_bitwidth*2+4+$clog2(seq_length)-1:0] mse_err [3:0][width-1:0];

    logic        [max_bitwidth*2+4+$clog2(seq_length)-1:0] mmse_err [width-1:0];


    integer ii,jj,kk;
    always_comb begin
        //Select the correct polarity of the injected inverse-error-vector
        for(ii=1; ii<width+1; ii=ii+1) begin
            for(jj=0; jj<seq_length+1; jj=jj+1) begin
                error[ii][jj] = bitstream[idx+ii-1] ? channel[ii-1][jj] : -channel[ii-1][jj];
            end
        end
        for(jj=0; jj<seq_length+1; jj=jj+1) begin
            error[0][jj] = bitstream[idx-1] ? channel[width-1][jj] : -channel[width-1][jj];
        end

        //Inject an IEV at the relevant position and then square the result
        for(ii=0; ii<width+1; ii=ii+1) begin
            for(jj=0; jj<seq_length+1; jj=jj+1) begin
                sqr_single_error[ii][jj] = (errstream[idx+ii+jj] + error[ii][jj])**2;
            end
        end

        for(ii=0; ii<width; ii=ii+1) begin
            sqr_double_error[ii][0] = (errstream[idx+ii] + error[ii][0])**2;
            for(jj=1; jj<seq_length; jj=jj+1) begin
                sqr_double_error[ii][jj] = (errstream[idx+ii+jj] + error[ii+1][jj-1] + error[ii][jj])**2;
            end
        end

        for(ii=0; ii<width; ii=ii+1) begin
            sqr_inj_error[0][ii][0] = errstream[idx+ii]**2;
            sqr_inj_error[1][ii][0] = 0;
            sqr_inj_error[2][ii][0] = sqr_single_error[ii][0];
            sqr_inj_error[3][ii][0] = sqr_double_error[ii][0];
            for(jj=1; jj<seq_length; jj=jj+1) begin
                sqr_inj_error[0][ii][jj] = errstream[idx+ii+jj]**2;
                sqr_inj_error[1][ii][jj] = sqr_single_error[ii+1][jj-1];
                sqr_inj_error[2][ii][jj] = sqr_single_error[ii][jj];
                sqr_inj_error[3][ii][jj] = sqr_double_error[ii][jj];
            end
        end
        //Sum up the squared err-errstreams
        for(kk=0; kk<4; kk=kk+1) begin
            for(ii=0; ii<width; ii=ii+1) begin
                mse_err[kk][ii] = 0;
                for(jj=0; jj<seq_length; jj=jj+1) begin
                    mse_err[kk][ii] = mse_err[kk][ii] + sqr_inj_error[kk][ii][jj];
                end
            end
        end
        //Rank the sum square errors and return the position of the smallest error
        for(ii=0; ii<width; ii=ii+1) begin
            mmse_err_pos[ii] = 0;
            for(jj=1; jj<4; jj=jj+1) begin
                mmse_err_pos[ii] = (mse_err[mmse_err_pos[ii]][ii] > mse_err[jj][ii]) ? jj : mmse_err_pos[ii];
            end 
        end
    end



endmodule : sliding_detector
