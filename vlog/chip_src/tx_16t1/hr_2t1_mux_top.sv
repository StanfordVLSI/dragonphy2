//This is a half-rate 2 to 1 mux for 16:4 mux
`timescale 100ps/1ps   //  Unit_time / Time precision
module hr_2t1_mux_top (
    input wire clk_b,     // Half rate clock input
    input wire [1:0] din,  // Two-bit input data
    output wire dout
);

// wire [1:0] din;
// wire dout; 
wire D0L; // din[0] wire connection from DFF to D-Latch
wire D1M; // din[1] wire connection from DFF to MUX
wire L0M; // din[0] wire connection from D-Latch to MUX


//Instantiate the DFF, latch and MUX
ff_c dff_0 (.D(din[0]), .CP(clk_b), .Q(D0L)); // DFF on din[0] path
ff_c dff_1 (.D(din[1]), .CP(clk_b), .Q(D1M)); // DFF on din[0] path
dlatch_n latch_0 (clk_b, D0L, L0M); // D-Latch after din[0] 
mux mux_0 (L0M, D1M, clk_b, dout);

endmodule