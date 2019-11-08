`include "signals.sv"

module clk_gen #(
    parameter real t_hi=0.5e-9,
    parameter real t_lo=0.5e-9
) (
    output wire logic clk_o
);

    // Pass through "clk_i" to "clk_o"
    // "dont_touch" is used because clk_i
    // is written hierarchically, even though
    // it does not appear as a module input
    (* dont_touch = "true" *) logic clk_i;
    assign clk_o = clk_i;

    // Main control logic.  "dont_touch" is used
    // because the dt_req and clk_val signals are
    // read hierarchically, even though they are
    // not outputs of the module
    (* dont_touch = "true" *) `DT_T dt_req;
    (* dont_touch = "true" *) logic clk_val;
    always @(posedge `EMU.clk) begin
        if (`EMU.rst == 1'b1) begin
            clk_val <= 1'b0;
            dt_req <= `DT_CONST(t_lo);
        end else if (dt_req == `EMU.dt) begin
            if (clk_val == 1'b0) begin
                clk_val <= 1'b1;
                dt_req <= `DT_CONST(t_hi);
            end else begin
                clk_val <= 1'b0;
                dt_req <= `DT_CONST(t_lo);
            end
        end else begin
            clk_val <= clk_val;
            dt_req <= dt_req - `EMU.dt;
        end
    end

endmodule
