module ff_cn_sn_rn_fixed(
    input D,
    input CPN,
    input CDN,
    input SDN,
    output reg Q
);


always @(negedge CPN or negedge CDN or negedge SDN)
    if(!CDN) Q <= 0;
    else if(!SDN) Q <= 1;
    else Q <= D;


endmodule
