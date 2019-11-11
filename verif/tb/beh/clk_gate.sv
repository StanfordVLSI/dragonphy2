`default_nettype none

module clk_gate (
    input wire logic en,
    input wire logic clk,
    output wire logic gated
);
    reg en_latched = 0;
    
    always @* begin
        if (clk == 1'b0) begin
            en_latched <= en;
        end
    end

    assign gated = clk & en_latched;
endmodule

`default_nettype wire
