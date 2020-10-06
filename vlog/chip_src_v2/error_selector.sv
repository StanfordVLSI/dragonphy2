module error_selector #(
    parameter integer seq_length=4,
    parameter integer est_bitwidth=8,
    parameter integer width=16
) (
    input logic bitstream [width-1:0],
    input logic signed [est_bitwidth-1:0] centered_channel [seq_length-1:0],

    output logic signed [est_bitwidth-1:0] error [width-1:0][seq_length-1:0]
);
    integer ii,jj;

    always_comb begin
        for(ii=0; ii<width; ii=ii+1) begin
            for(jj=0; jj<seq_length; jj=jj=1) begin
                error[ii][jj] = bitstream[ii] ? centered_channel[jj] : -centered_channel[jj];
            end
        end
    end

endmodule : error_selector