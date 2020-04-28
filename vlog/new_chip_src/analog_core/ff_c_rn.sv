module ff_c_rn(
    input D,
    input CP,
    input CDN,
    output reg Q
);

always @(posedge CP or negedge CDN) begin
    if(!CDN) Q <= 0;
    else Q <= D;
end

endmodule
