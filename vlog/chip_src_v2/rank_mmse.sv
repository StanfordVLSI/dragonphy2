module rank_mmse #(

) (
    input logic [est_bitwidth*2-1:0] sqr_inj_err [3:0][width-1:0][seq_length-1:0],

    output logic [1:0] mmse_err_pos [width-1:0]
);

    logic  [est_bitwidth*2+1:0] mse_err [3:0][width-1:0];
    logic  [1:0] int_mmse_err_pos [1:0][width-1:0];

    integer ii,jj,kk;

    always_comb begin
        for(kk=0; kk<4; kk=kk+1) begin
            for(ii=0; ii<width; ii=ii+1) begin
                for(jj=0; jj<seq_length; jj=jj+1) begin
                    mse_err[kk][ii] = mse_err[kk][ii] + sqr_inj_err[kk][ii][jj];
                end
            end
        end

        for(ii=0; ii<width; ii=ii+1) begin
            int_mmse_err_pos[0][ii] = mse_err[0][ii] < mse_err[1][ii] ? 0 : 1;
            int_mmse_err_pos[1][ii] = mse_err[2][ii] < mse_err[3][ii] ? 2 : 3;
            mmse_err_pos[ii]        = mse_err[int_mmse_err_pos[0]][ii] < mse_err[int_mmse_err_pos[1]][ii] ? 
                                      int_mmse_err_pos[0][ii] : int_mmse_err_pos[1][ii];
        end
    end


endmodule : rank_mmse