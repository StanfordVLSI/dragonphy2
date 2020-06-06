`include "svreal.sv"

module osc_model #(
    parameter real t_lo=31.25e-12,
    parameter real t_hi=31.25e-12
) (
    output wire logic clk_o_val
);
    // signals use for external I/O
    (* dont_touch = "true" *) logic emu_rst;
    (* dont_touch = "true" *) logic emu_clk;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] emu_dt;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] dt_req;

    // declare format for timestep
    `REAL_FROM_WIDTH_EXP(DT_FMT, `DT_WIDTH, `DT_EXPONENT);

    // instantiate MSDSL model, passing through format information
    osc_model_core #(
        // pass through real-valued parameters
        .t_lo(t_lo),
        .t_hi(t_hi),
        // pass formatting information
        `PASS_REAL(emu_dt, DT_FMT),
        `PASS_REAL(dt_req, DT_FMT)
    ) osc_model_core_i (
        .emu_rst(emu_rst),
        .emu_clk(emu_clk),
        .emu_dt(emu_dt),
        .dt_req(dt_req),
        .clk_val(clk_o_val)
    );
endmodule