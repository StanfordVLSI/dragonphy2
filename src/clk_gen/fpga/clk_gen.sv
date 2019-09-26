module clk_gen #(
    parameter integer t_per=2
) (
    output wire logic clk_o
);

    // logic to determine next time step
    `DECL_DT(dt_req);
    logic clk_val_int;
    always @(posedge `EMU_CLK) begin
        if (`EMU_RST == 1'b1) begin
            clk_val_int <= 0;
            dt_req <= t_per / 2;
        end else if (dt_req - `EMU_DT == 0) begin
            clk_val_int <= ~clk_val_int;
            dt_req <= t_per / 2;
        end else begin
            clk_val_int <= clk_val_int;
            dt_req <= dt_req - `EMU_DT;
        end
    end

    // circuitry to drive clock
    logic clk_int;
    always @(posedge `EMU_CLK_2X) begin
        if (`EMU_RST == 1'b1) begin
            clk_int <= `EMU_CLK_VAL;
        end else begin
            clk_int <= clk_val_int;
        end
    end
    BUFG BUFG_i (.O(clk_o), .I(clk_int));

endmodule
