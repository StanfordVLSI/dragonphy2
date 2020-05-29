module ff_c_rn #(
) (
    input D,
    input CP,
    input CDN,
    output reg Q
);
    always @(posedge CP or negedge CDN) begin
        if (!CDN) begin
            Q <= 0;
        end else begin
            Q <= D;
        end
    end
endmodule


