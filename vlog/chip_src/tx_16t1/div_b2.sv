`timescale 100ps/1ps   //  unit_time / time precision

module div_b2 (
    input wire clkin,
    input wire rst,
    output reg clkout
);

initial begin
    clkout = 1'b0;
end

always@(posedge clkin) begin
    if (rst) begin
        clkout <= 0;
    end else begin
        clkout <= ~clkout;
    end
end
endmodule
