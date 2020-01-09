`include "signals.sv"

module osc_model #(
    parameter real t_hi=0.5e-9,
    parameter real t_lo=0.5e-9
) (
    output wire logic clk_o
);

    // signals use for external I/O
    (* dont_touch = "true" *) logic __emu_clk_val;
    (* dont_touch = "true" *) logic __emu_rst;
    (* dont_touch = "true" *) logic __emu_clk;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt_req;
    (* dont_touch = "true" *) logic __emu_clk_i;

    // assign output clock (note that a module output pin cannot be directly
    // written hierachically)
    assign clk_o = __emu_clk_i;

    // import emu_dt as a svreal signal
    `DECL_DT(emu_dt);
    assign emu_dt = __emu_dt;

    // import emu_dt_req as a svreal signal
    `DECL_DT(dt_req);
    assign __emu_dt_req = dt_req;

    // check if the emulator timestep matches the requested timestep
    `EQ_REAL(dt_req, emu_dt, dt_req_granted);

    // compute difference between requested timestep and granted timestep
    `DECL_DT(dt_req_minus_emu_dt);
    `SUB_INTO_REAL(dt_req, emu_dt, dt_req_minus_emu_dt);

    // select the next half period duration based on the current clock value
    // should be "t_lo" if the clock is currently high, otherwise "t_hi" if
    // the clock is currently low.
    `DT_CONST(t_lo_const, t_lo);
    `DT_CONST(t_hi_const, t_hi);
    `DECL_DT(next_half_period);
    `ITE_INTO_REAL(__emu_clk_val, t_lo_const, t_hi_const, next_half_period);

    // determine the next requested timestep, advancing to the next half period
    // if the timestep was granted, otherwise subtracting the actual timestep
    // from the requested timestep
    `DECL_DT(dt_req_imm);
    `ITE_INTO_REAL(dt_req_granted, next_half_period, dt_req_minus_emu_dt, dt_req_imm);

    // assign to dt_req with memory
    `DFF_INTO_REAL(dt_req_imm, dt_req, __emu_rst, __emu_clk, 1'b1, t_lo);

    // clock toggling logic
    always @(posedge __emu_clk) begin
        if (__emu_rst == 1'b1) begin
            __emu_clk_val <= 1'b0;
        end else if (dt_req_granted == 1'b1) begin
            __emu_clk_val <= ~__emu_clk_val;
        end else begin
            __emu_clk_val <= __emu_clk_val;
        end
    end

endmodule
