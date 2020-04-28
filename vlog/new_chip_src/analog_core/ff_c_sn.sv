module ff_c_sn(
    input D,
    input CP,
    input SDN,
    output reg Q
);

always @(posedge CP or negedge SDN) begin
    if(!SDN) Q <= 1;
    else Q <= D;
end

endmodule
