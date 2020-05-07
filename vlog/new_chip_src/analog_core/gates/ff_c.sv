module ff_c #(
) (
    input D,
    input CP,
    output reg Q
);
    always @(posedge CP) begin
        Q <=  D;
    end
endmodule


