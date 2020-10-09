module channel_filter #(
    parameter integer width        = 16,
    parameter integer depth        = 30,
    parameter integer est_channel_bitwidth = 8,
    parameter integer est_code_bitwidth    = 8,
    parameter integer shift_bitwidth = 2
) (
    input logic bitstream [(depth-1)+width-1:0],
    
    input logic signed [est_channel_bitwidth-1:0] channel [width-1:0][depth-1:0],
    input logic [shift_bitwidth-1:0] shift[width-1:0],
    output logic signed [est_code_bitwidth-1:0] est_code [width-1:0]
);

    integer ii, jj;
    always_comb begin
        for(ii=0; ii<width; ii=ii+1) begin
            est_code[ii] = 0;
            for(jj=0; jj<depth; jj=jj+1) begin
                est_code[ii] = est_code[ii] + (bitstream[ii+jj] ? channel[ii][depth-jj-1] : -channel[ii][depth-jj-1]);
            end
            est_code[ii] = est_code[ii] >> shift;
        end
    end

endmodule : channel_filter