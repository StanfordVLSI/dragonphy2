module sync_divider (
    input wire logic in,
    input wire logic [2:0] ndiv,
    input wire logic rstb,
    output wire logic out
);
    // translated from a schematic
    logic [4:0] ndiv_thm;
    assign ndiv_thm[4] = ~(((~ndiv[0]) & (~ndiv[1])) | (~ndiv[2]));
    assign ndiv_thm[3] = ~(~ndiv[2]);
    assign ndiv_thm[2] = ~(((~ndiv[0]) | (~ndiv[1])) & (~ndiv[2]));
    assign ndiv_thm[1] = ~((~ndiv[1]) & (~ndiv[2]));
    assign ndiv_thm[0] = ~((~ndiv[0]) & (~ndiv[1]) & (ndiv[2]));

    logic rst;
    assign rst = ~rstb;

    // reset signals
    logic [5:0] dff_rstb;
    assign dff_rstb[0] = ~(rst | ndiv_thm[0]);
    assign dff_rstb[1] = ~(rst | ndiv_thm[1]);
    assign dff_rstb[2] = ~(rst | ndiv_thm[2]);
    assign dff_rstb[3] = ~(rst | ndiv_thm[3]);
    assign dff_rstb[4] = ~(rst | ndiv_thm[4]);
    assign dff_rstb[5] = ~(rst | 1'b0);

    // instantiate Mux+DFF blocks
    logic [5:0] qb;
    logic [4:0] q;
    logic [3:0] an;

    assign qb[0] = ~q[0];
    assign qb[1] = ~q[1];
    assign qb[2] = ~q[2];
    assign qb[3] = ~q[3];
    assign qb[4] = ~q[4];
    assign qb[5] = ~out;

    assign an[0] = qb[0] & qb[1];
    assign an[1] = an[0] & qb[2];
    assign an[2] = an[1] & qb[3];
    assign an[3] = an[2] & qb[4];

    mux_dff md0 (.sel(1'b1),  .in(qb[0]), .clk(in), .rstb(dff_rstb[0]), .out(q[0]));
    mux_dff md1 (.sel(qb[0]), .in(qb[1]), .clk(in), .rstb(dff_rstb[1]), .out(q[1]));
    mux_dff md2 (.sel(an[0]), .in(qb[2]), .clk(in), .rstb(dff_rstb[2]), .out(q[2]));
    mux_dff md3 (.sel(an[1]), .in(qb[3]), .clk(in), .rstb(dff_rstb[3]), .out(q[3]));
    mux_dff md4 (.sel(an[2]), .in(qb[4]), .clk(in), .rstb(dff_rstb[4]), .out(q[4]));
    mux_dff md5 (.sel(an[3]), .in(qb[5]), .clk(in), .rstb(dff_rstb[5]), .out(out));
endmodule