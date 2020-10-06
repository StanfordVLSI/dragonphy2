module error_comperator #(
    parameter integer width=16,
    parameter integer bitwidth=8
) (
    input logic signed [bitwidth-1:0] codes [width-1:0],
    input logic signed [bitwidth-1:0] thresholds [1:0],

    output logic signed [2:0] trit[width-1:0]
);

    integer ii;
    always_comb begin
        for(ii=0; ii<width; ii=ii+1) begin
            trit[ii] = 2*{codes[ii] < thresholds[1], codes[ii] > thresholds[0]};
        end
    end

endmodule : error_comperator