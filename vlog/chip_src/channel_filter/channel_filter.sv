module channel_filter #(
    parameter integer width        = 16,
    parameter integer depth        = 30,
    parameter integer est_channel_bitwidth = 8,
    parameter integer est_code_bitwidth    = 8,
    parameter integer shift_bitwidth = 2
) (
    input logic signed [2**constant_gpack::sym_bitwidth-1-1:0] symstream [(depth-1)+width-1:0],
    
    input logic signed [est_channel_bitwidth-1:0] channel [width-1:0][depth-1:0],
    input logic [shift_bitwidth-1:0] shift[width-1:0],

    output logic signed [est_code_bitwidth-1:0] est_code [width-1:0]
);


    localparam idx = depth - 1;

    logic signed [est_channel_bitwidth+$clog2(depth)+$clog2(2**2-1)-1:0] int_est_code [width-1:0];


    integer ii, jj;
    always_comb begin
        for(ii=0; ii<width; ii=ii+1) begin
            int_est_code[ii] = 0;
            for(jj=0; jj<depth; jj=jj+1) begin
                int_est_code[ii] = int_est_code[ii] + symstream[ii+idx-jj]*channel[ii][jj];
            end
            est_code[ii] = int_est_code[ii] >>> shift[ii];
        end
    end

endmodule : channel_filter