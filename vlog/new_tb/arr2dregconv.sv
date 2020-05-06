module arr2dregconv #(
    parameter integer width=16
)(
    input logic signed [1:0] arr [width-1:0],
    output logic [2*width-1:0] d_reg
);
    genvar gi;
    generate
        for(gi=0; gi<width; gi=gi+1) begin
            assign d_reg[2*gi+1:2*gi] = arr[gi];
        end
    endgenerate
endmodule 