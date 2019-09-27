`include "signals.sv"

module clk_gen #(
    parameter integer t_hi=1,
    parameter integer t_lo=1
) (
    output wire logic clk_o
);

    // signals wired up at top level
    (* dont_touch = "true" *) logic clk_int;
    (* dont_touch = "true" *) `DECL_DT(dt_req);
    
    // drive output clock
    assign clk_o = clk_int;
    
    // logic to control the clock
    (* dont_touch = "true" *) logic clk_val;
    always @(posedge `EMU.clk) begin
        if (`EMU.rst == 1'b1) begin
            clk_val <= 1'b0;
            dt_req <= t_lo;
        end else if (dt_req == `EMU.dt) begin
            if (clk_val == 1'b0) begin
                clk_val <= 1'b1;
                dt_req <= t_hi;
            end else begin
                clk_val <= 1'b0;
                dt_req <= t_lo;
            end
        end else begin
            clk_val <= clk_val;
            dt_req <= dt_req - `EMU.dt;
        end
    end

endmodule
