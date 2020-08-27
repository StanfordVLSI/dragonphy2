`timescale 1s/1ns
`include "svreal.sv"

module sim_ctrl (
    output reg cdf_rst,
    input [31:0] cdf_m6,
    input [31:0] cdf_m5,
    input [31:0] cdf_m4,
    input [31:0] cdf_m3,
    input [31:0] cdf_m2,
    input [31:0] cdf_m1,
    input [31:0] cdf_0,
    input [31:0] cdf_p1,
    input [31:0] cdf_p2,
    input [31:0] cdf_p3,
    input [31:0] cdf_p4,
    input [31:0] cdf_p5,
    input [31:0] cdf_p6,
    input [31:0] cdf_tot
);
    `include "anasymod.sv"

    integer i;

    initial begin
        // initialize outputs
        cdf_rst = 1'b1;

        // wait for reset to finish
        wait_emu_reset();

        // run for a little bit before releasing reset
        sleep_emu(1e-6);
        cdf_rst = 1'b0;

        // run for a little bit
        sleep_emu(10e-3);

        // print results
        $display("cdf_tot: %0d", cdf_tot);
        $display("cdf_m6: %0f", (1.0*cdf_m6)/(1.0*cdf_tot));
        $display("cdf_m5: %0f", (1.0*cdf_m5)/(1.0*cdf_tot));
        $display("cdf_m4: %0f", (1.0*cdf_m4)/(1.0*cdf_tot));
        $display("cdf_m3: %0f", (1.0*cdf_m3)/(1.0*cdf_tot));
        $display("cdf_m2: %0f", (1.0*cdf_m2)/(1.0*cdf_tot));
        $display("cdf_m1: %0f", (1.0*cdf_m1)/(1.0*cdf_tot));
        $display("cdf_0: %0f", (1.0*cdf_0)/(1.0*cdf_tot));
        $display("cdf_p1: %0f", (1.0*cdf_p1)/(1.0*cdf_tot));
        $display("cdf_p2: %0f", (1.0*cdf_p2)/(1.0*cdf_tot));
        $display("cdf_p3: %0f", (1.0*cdf_p3)/(1.0*cdf_tot));
        $display("cdf_p4: %0f", (1.0*cdf_p4)/(1.0*cdf_tot));
        $display("cdf_p5: %0f", (1.0*cdf_p5)/(1.0*cdf_tot));
        $display("cdf_p6: %0f", (1.0*cdf_p6)/(1.0*cdf_tot));

        // end simulation
        $finish;
    end
endmodule
