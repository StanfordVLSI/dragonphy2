module ff_c_sn #(
) (
    input D,
    input CP,
    input SDN,
    output reg Q
);
    always @(posedge CP or negedge SDN) begin
        if (!SDN) begin
            Q <=  1;
        end else begin
            Q <=  D;
        end
    end
endmodule


