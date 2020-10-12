//This is a half-rate 4 to 1 mux for 16:4 mux
`timescale 100ps/1ps   //  Unit_time / Time precision
module hr_4t1_mux_top (
    input wire clk_b,     // Half rate clock input
    input wire [3:0] din,  // Two-bit input data
    output wire dout,
    input wire clk_half  // Divide clock , same as the prbs generator clock
);


wire [1:0] hd; // Din[0] wire connection from DFF to D-Latch

// Instantiate the hr_2t1_mux_top, low speed portion

hr_2t1_mux_top hr_2t1_mux_0 (.clk_b(clk_half), .din(din[1:0]), .dout(hd[0])); // DFF on din[1:0] path
hr_2t1_mux_top hr_2t1_mux_1 (.clk_b(clk_half), .din(din[3:2]), .dout(hd[1])); // DFF on din[3:2] path

// High speed hr_2t1_mux_top
hr_2t1_mux_top hr_2t1_mux_2 (.clk_b(clk_b), .din(hd[1:0]), .dout(dout));

endmodule