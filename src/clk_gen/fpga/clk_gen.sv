`include "signals.sv"

module clk_gen #(
    parameter integer t_per=2
) (
    output wire logic clk_o
);

    // logic to determine next time step
    `DECL_DT(dt_req);
    logic clk_val;
    always @(posedge `EMU_CLK) begin
        if (`EMU_RST == 1'b1) begin
            clk_val <= 0;
            dt_req <= t_per / 2;
        end else if (dt_req - `EMU_DT == 0) begin
            clk_val <= ~clk_val;
            dt_req <= t_per / 2;
        end else begin
            clk_val <= clk_val;
            dt_req <= dt_req - `EMU_DT;
        end
    end

    // circuitry to drive clock
    clk_drv clk_drv_i (
        .in(`EMU_RST ? `EMU_CLK_VAL : clk_val),
        .out(clk_o)
    );

endmodule
