// This is a half-rate 2:1 mux for the 16:4 mux

`timescale 100ps/1ps   //  Unit_time / Time precision

`default_nettype none

module hr_2t1_mux_top (
    input wire logic clk_b,     // Half rate clock input
    input wire logic [1:0] din,  // Two-bit input data
    output wire logic dout
);

wire D0L; // din[0] wire connection from DFF to D-Latch
wire D1M; // din[1] wire connection from DFF to MUX


//Instantiate the DFF, latch and MUX
ff_c dff_0 (.D(din[0]), .CP(clk_b), .Q(D0L)); // DFF on din[0] path
ff_c dff_1 (.D(din[1]), .CP(clk_b), .Q(D1M)); // DFF on din[0] path

mux mux_0 (.in0(D0L), .in1(D1M), .sel(clk_b), .out(dout));

endmodule

`default_nettype wire
