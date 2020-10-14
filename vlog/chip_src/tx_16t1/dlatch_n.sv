//This a D latch for MUX
`timescale 100ps/1ps  // Remove this line before synthesis
module dlatch_n (
    input wire clk,
    input wire din,
    output reg dout
);

always @ (clk or din)
begin
    #0.15; // remove #0.15 before synthesis
    if (!clk)
    dout = din;
end

endmodule