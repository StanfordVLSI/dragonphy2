module channel_filter #(
    parameter integer width        = 16,
    parameter integer depth        = 30,
    parameter integer est_bitwidth = 8
) (
    input logic bitstream [(depth-1)+width-1:0],
    
    input logic signed [est_bitwidth-1:0] pchannel [depth-1:0],
    input logic signed [est_bitwidth-1:0] nchannel [depth-1:0],

    output logic signed [est_bitwidth-1:0] est_code [width-1:0]
);

    logic signed [est_bitwidth-1:0] channel [1:0][depth-1:0];

    always_comb begin
        channel[1] <= pchannel;
        channel[0] <= nchannel;
    end

    integer ii;
    always_comb begin
        for(ii=0; ii<width; ii=ii+1) begin
            est_code[ii] = 0;
            for(jj=0; jj<depth; jj=jj+1) begin
                est_code[ii] = est_code[ii] + channel[bitstream[offset+ii-jj]][offset+ii-jj];
            end
        end
    end

endmodule : channel_filter