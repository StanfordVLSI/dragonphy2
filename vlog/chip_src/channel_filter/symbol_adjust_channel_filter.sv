module symbol_adjust_channel_filter #(
    parameter integer width        = 16,
    parameter integer sym_bitwidth = 2,
    parameter integer depth        = 30,
    parameter integer est_channel_bitwidth = 8,
    parameter integer est_code_bitwidth    = 8,
    parameter integer shift_bitwidth = 2
) (
    input logic signed [(2**sym_bitwidth-1)-1:0] flpstream [(depth-1)+width-1:0],

    input logic signed [est_channel_bitwidth-1:0] channel [width-1:0][depth-1:0],
    input logic [shift_bitwidth-1:0] shift [width-1:0],


    output logic signed [est_code_bitwidth-1:0] error_out [width-1:0]

);
    localparam idx = depth - 1;

    logic signed [est_channel_bitwidth+$clog2(depth)-1:0] unshifted_error_out [width-1:0];
    logic signed [est_channel_bitwidth+$clog2(depth)-1:0] product;
    integer ii, jj;
    always_comb begin
        for(ii=0; ii<width; ii=ii+1) begin
            unshifted_error_out[ii] = 0;
            for(jj=0; jj<depth; jj=jj+1) begin
                product = flpstream[ii+idx-jj]*2*channel[ii][jj];
                unshifted_error_out[ii] = unshifted_error_out[ii] - product;
            end
            error_out[ii] = unshifted_error_out[ii] >>> shift[ii];
        end
    end

endmodule : symbol_adjust_channel_filter