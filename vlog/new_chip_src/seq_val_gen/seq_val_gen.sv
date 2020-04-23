module seq_val_gen #(
    parameter integer nbit=1,
    parameter integer cbit=0
) (
    input wire logic signed [mlsd_gpack::estimate_precision-1:0]  channel_est [mlsd_gpack::width-1:0][mlsd_gpack::estimate_depth-1:0],

    output logic signed [mlsd_gpack::estimate_precision-1:0]   precalc_seq_vals [2**nbit-1:0][mlsd_gpack::width-1:0][mlsd_gpack::length-1:0]
);
    logic signed [nbit+mlsd_gpack::estimate_precision-1:0] sum_precalc_seq_vals [2**nbit-1:0][mlsd_gpack::width-1:0][mlsd_gpack::length-1:0];
    logic signed [1:0] precalc_bit_vector [2**nbit-1:0][nbit-1:0];

    int ii, jj, kk, ll;

    always_comb begin
        for(ii=0; ii<2**nbit; ii=ii+1) begin
            for(jj=0; jj<nbit; jj=jj+1) begin
               precalc_bit_vector[ii][jj] = ((ii >> jj) & 1 == 1) ? 1 : -1;
            end
        end

        //Calculate Static MLSD Sequences 
        for(ii=0; ii<mlsd_gpack::width; ii=ii+1) begin
            for(jj=0; jj<mlsd_gpack::length; jj=jj+1) begin
                for(kk=0; kk<2**nbit; kk=kk+1) begin
                    sum_precalc_seq_vals[kk][ii][jj] = 0;
                    for(ll=0; ll<nbit; ll=ll+1) begin
                        sum_precalc_seq_vals[kk][ii][jj] = sum_precalc_seq_vals[kk][ii][jj] + $signed((jj+cbit >= ll) ? (precalc_bit_vector[kk][ll]*channel_est[ii][jj+cbit-ll]): 0);
                    end
                    precalc_seq_vals[kk][ii][jj] =  sum_precalc_seq_vals[kk][ii][jj];
                end
            end
        end
    end


endmodule : seq_val_gen
