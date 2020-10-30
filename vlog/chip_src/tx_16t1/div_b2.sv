`default_nettype none

module div_b2 (
    input wire logic clkin,
    input wire logic rst,
    output reg clkout
);

always @(posedge clkin or posedge rst) begin
    if (rst) begin
        clkout <= 0;
    end else begin
        clkout <= ~clkout;
    end
end

endmodule

`default_nettype wire
