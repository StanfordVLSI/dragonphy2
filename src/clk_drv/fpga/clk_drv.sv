module clk_drv #(
    parameter init = 0
) (
    input wire logic in,
    output wire logic out
);

    logic unbuf = init;
    always @(posedge `EMU_CLK_2X) begin
        unbuf <= in;
    end
    BUFG BUFG_i (.O(out), .I(unbuf));

endmodule
