module weight_clock #(
    parameter real delay=0ps,
    parameter real period=10ns
) (
    input logic en,
    output reg clk
);

    logic int_clk;

    initial begin
        int_clk = 0;
        #delay
        forever begin #(period/2.0) int_clk = ~int_clk; end
    end

    always_comb begin
        clk = en ? int_clk : 0;
    end
endmodule : weight_clock