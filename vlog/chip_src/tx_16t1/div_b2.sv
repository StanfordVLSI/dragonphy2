`timescale 100ps/1ps   //  unit_time / time precision

module div_b2 (
    input wire clkin,
    input wire rst,
    input wire cke,
    output reg clkout
);

initial begin
    clkout = 1'b0;
end

always@(posedge clkin) begin
    if (rst) begin
        clkout <= 0;  // Reset
    end else if (cke) begin
        clkout <= clkout; // Clock gated
    end else begin
    clkout = ~clkout;
    end
endmodule


// Add the rst and cke 