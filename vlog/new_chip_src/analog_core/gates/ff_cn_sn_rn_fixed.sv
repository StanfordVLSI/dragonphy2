module ff_cn_sn_rn_fixed #(
) (
    input D,
    input CPN,
    input CDN,
    input SDN,
    output reg Q
);
    always @(negedge CPN or negedge CDN or negedge SDN) begin
        if (!CDN) begin
            Q <=  0;
        end else if(!SDN) begin
            Q <=  1;
        end else begin
            Q <=  D;
        end
    end
endmodule


