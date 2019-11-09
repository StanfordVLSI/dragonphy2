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
    `IMPORT_EMU_DT;
    `DECL_DT_LOCAL(dt_req);
    (* dont_touch = "true" *) logic clk_val;

    // check if the emulator timestep matches the 
    // requested timestep
    logic dt_req_eq_emu_dt;
    `SVREAL_EQ(dt_req, emu_dt, dt_req_eq_emu_dt);

    // compute difference between requested 
    `DECL_DT_LOCAL(dt_req_minus_emu_dt);
    `SVREAL_SUB(dt_req, emu_dt, dt_req_minus_emu_dt);

    // compute the duration of the next half period
    `DECL_DT_LOCAL(next_half_period);
    `DT_CONST(t_hi_const, t_hi);
    `DT_CONST(t_lo_const, t_lo);
    `SVREAL_MUX(clk_val, t_hi_const, t_lo_const, next_half_period);

    // determine the next value of dt_req
    `DECL_DT_LOCAL(dt_req_imm);
    `SVREAL_MUX(dt_req_eq_emu_dt, dt_req_minus_emu_dt, next_half_period, dt_req_imm);

    // assign to dt_req with memory
    `SVREAL_DFF(dt_req_imm, dt_req, `EMU.rst, `EMU.clk, 1'b1, t_lo_const);

    // clock toggling logic
    always @(posedge `EMU.clk) begin
        if (`EMU.rst == 1'b1) begin
            clk_val <= 1'b0;
        end else if (dt_req_eq_emu_dt == 1'b1) begin
            clk_val <= ~clk_val;
        end else begin
            clk_val <= clk_val;
        end
    end

endmodule
