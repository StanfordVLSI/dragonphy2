`include "signals.sv"

module clk_drv #(
    parameter init = 0
) (
    (* dont_touch = "true" *) input wire logic in,
    (* dont_touch = "true" *) output wire logic out
);

    logic unbuf = init;
    always @(posedge `EMU_CLK_2X) begin
        unbuf <= in;
    end
    (* dont_touch = "true" *) BUFG BUFG_i (.O(out), .I(unbuf));

endmodule
