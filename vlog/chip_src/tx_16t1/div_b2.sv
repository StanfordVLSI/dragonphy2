`timescale 100ps/1ps   //  unit_time / time precision

module div_b2 (
    input wire clkin,
    output reg clkout
);

initial begin
    clkout = 1'b0;
end

always@(posedge clkin) begin
    #0.3;
    clkout = ~clkout;
end

endmodule