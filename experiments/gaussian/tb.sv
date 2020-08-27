`include "svreal.sv"

module tb;
    // digital signals
    (* dont_touch = "true" *) logic cdf_rst;
    (* dont_touch = "true" *) logic [31:0] cdf_m6;
    (* dont_touch = "true" *) logic [31:0] cdf_m5;
    (* dont_touch = "true" *) logic [31:0] cdf_m4;
    (* dont_touch = "true" *) logic [31:0] cdf_m3;
    (* dont_touch = "true" *) logic [31:0] cdf_m2;
    (* dont_touch = "true" *) logic [31:0] cdf_m1;
    (* dont_touch = "true" *) logic [31:0] cdf_0;
    (* dont_touch = "true" *) logic [31:0] cdf_p1;
    (* dont_touch = "true" *) logic [31:0] cdf_p2;
    (* dont_touch = "true" *) logic [31:0] cdf_p3;
    (* dont_touch = "true" *) logic [31:0] cdf_p4;
    (* dont_touch = "true" *) logic [31:0] cdf_p5;
    (* dont_touch = "true" *) logic [31:0] cdf_p6;
    (* dont_touch = "true" *) logic [31:0] cdf_tot;

    // model
    model model_i (
        .cdf_rst(cdf_rst),
        .cdf_m6(cdf_m6),
        .cdf_m5(cdf_m5),
        .cdf_m4(cdf_m4),
        .cdf_m3(cdf_m3),
        .cdf_m2(cdf_m2),
        .cdf_m1(cdf_m1),
        .cdf_0(cdf_0),
        .cdf_p1(cdf_p1),
        .cdf_p2(cdf_p2),
        .cdf_p3(cdf_p3),
        .cdf_p4(cdf_p4),
        .cdf_p5(cdf_p5),
        .cdf_p6(cdf_p6),
        .cdf_tot(cdf_tot)
    );
endmodule
