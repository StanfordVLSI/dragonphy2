`include "svreal.sv"

module test_osc_model #(
    parameter real t_lo=0.5e-9,
    parameter real t_hi=0.5e-9
) (
    output wire logic clk_val,
    input real dt_req,
    output real emu_dt,
    input wire logic emu_clk,
    input wire logic emu_rst
);
    // format for timesteps
    `REAL_FROM_WIDTH_EXP(emu_dt_int, `DT_WIDTH, `DT_EXPONENT);
    `REAL_FROM_WIDTH_EXP(dt_req_ext, `DT_WIDTH, `DT_EXPONENT);
    `REAL_FROM_WIDTH_EXP(dt_req_clk, `DT_WIDTH, `DT_EXPONENT);

    // wire to external real values
    assign `FORCE_REAL(dt_req, dt_req_ext);
    assign emu_dt = `TO_REAL(emu_dt_int);

    // monitor the time delay requested by the delay block
    real dt_req_clk_real;
    assign dt_req_clk_real = `TO_REAL(dt_req_clk);

    // implement basic timestep management
    `MIN_INTO_REAL(dt_req_ext, dt_req_clk, emu_dt_int);

    // instantiate MSDSL model, passing through format information
    osc_model_core #(
        // pass through real-valued parameters
        .t_lo(t_lo),
        .t_hi(t_hi),
        // pass formatting information
        `PASS_REAL(emu_dt, emu_dt_int),
        `PASS_REAL(dt_req, dt_req_clk)
    ) osc_model_core_i (
        // main I/O: output clock values
        .clk_val(clk_val),
        // timestep control: DT request and response
        .dt_req(dt_req_clk),
        .emu_dt(emu_dt_int),
        // emulator clock and reset
        .emu_clk(emu_clk),
        .emu_rst(emu_rst),
        // unused (related to clock buffer)
        .clk_i(1'b0),
        .clk_o()
    );
endmodule