module channel_filter #(
    parameter integer width        = 16,
    parameter integer depth        = 30,
    parameter integer est_channel_bitwidth = 8,
    parameter integer est_code_bitwidth    = 8,
    parameter integer shift_bitwidth = 2,
    parameter integer sym_bitwidth = 2
) (
    input logic signed [2**sym_bitwidth-1-1:0] symstream [(depth-1)+width-1:0],
    
    input logic signed [est_channel_bitwidth-1:0] channel [width-1:0][depth-1:0],
    input logic [shift_bitwidth-1:0] shift[width-1:0],

    output logic signed [est_code_bitwidth-1:0] est_code [width-1:0]
);


    localparam idx = depth - 1;


    localparam hp_depth = 6;
    localparam mp_depth = 6;
    localparam lp_depth = 18;

    localparam hp_bitwidth = est_channel_bitwidth;
    localparam mp_bitwidth = est_channel_bitwidth-2;
    localparam lp_bitwidth = est_channel_bitwidth-4;

    logic signed [hp_bitwidth-1:0] channel_hp [hp_depth-1:0];
    logic signed [mp_bitwidth-1:0] channel_mp [mp_depth-1:0];
    logic signed [lp_bitwidth-1:0] channel_lp [lp_depth-1:0];

    integer ii, jj, kk;

    always_comb begin
        for (kk = 0; kk < hp_depth; kk = kk + 1) begin
            channel_hp[kk] = {hp_bitwidth{1'b1}} & channel[0][kk];
        end
        for (kk = 0; kk < mp_depth; kk = kk + 1) begin
            channel_mp[kk] = {mp_bitwidth{1'b1}} & channel[0][kk+hp_depth];
        end
        for (kk = 0; kk < lp_depth; kk = kk + 1) begin
            channel_lp[kk] = {lp_bitwidth{1'b1}} & channel[0][kk+hp_depth+mp_depth];
        end
    end

    logic signed [est_channel_bitwidth+$clog2(depth)+ (2**2-1)-1:0] int_est_code [width-1:0];
    //logic signed [est_channel_bitwidth+$clog2(depth)+ (2**2-1)-1:0] int_est_code_tmp [width-1:0];
    //logic signed [est_channel_bitwidth+$clog2(depth)+ (2**2-1)-1:0] diff_int_est_code_tmp [width-1:0];

    logic signed [hp_bitwidth+$clog2(hp_depth)+ (2**2-1)-1:0] int_est_code_hp [width-1:0];
    logic signed [mp_bitwidth+$clog2(mp_depth)+ (2**2-1)-1:0] int_est_code_mp [width-1:0];
    logic signed [lp_bitwidth+$clog2(lp_depth)+ (2**2-1)-1:0] int_est_code_lp [width-1:0];


    always_comb begin
        for(ii=0; ii<width; ii=ii+1) begin
            int_est_code[ii] = 0;
            int_est_code_hp[ii] = 0;
            int_est_code_mp[ii] = 0;
            int_est_code_lp[ii] = 0;
            //int_est_code_tmp[ii] = 0;
            //diff_int_est_code_tmp[ii] = 0;
            //for(jj=0; jj<depth; jj=jj+1) begin
            //    int_est_code[ii] = int_est_code[ii] + symstream[ii+idx-jj]*channel[0][jj];
            //end
            for(jj=0; jj<hp_depth; jj=jj+1) begin
                int_est_code_hp[ii] = int_est_code_hp[ii] + symstream[ii+idx-jj]*channel_hp[jj];
            end
            for(jj=0; jj<mp_depth; jj=jj+1) begin
                int_est_code_mp[ii] = int_est_code_mp[ii] + symstream[ii+idx-jj - hp_depth]*channel_mp[jj];
            end
            for(jj=0; jj<lp_depth; jj=jj+1) begin
                int_est_code_lp[ii] = int_est_code_lp[ii] + symstream[ii+idx-jj - hp_depth - mp_depth]*channel_lp[jj];
            end

            int_est_code[ii] = int_est_code_hp[ii] + int_est_code_mp[ii] + int_est_code_lp[ii];

            est_code[ii] = int_est_code[ii] >>> shift[ii];
            //diff_int_est_code_tmp[ii] = int_est_code_tmp[ii] - int_est_code[ii];
        end
    end

endmodule : channel_filter