
module dlatch_n (
    input wire clk,
    input wire din,
    output reg dout
);

always @ (clk or din) begin
    if (!clk)
    dout = din;
end
endmodule