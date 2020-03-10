`include "signals.sv"

module osc_model (
    output wire logic clk_o
);
    // signals use for external I/O
    (* dont_touch = "true" *) logic __emu_clk_val;
    (* dont_touch = "true" *) logic __emu_rst;
    (* dont_touch = "true" *) logic __emu_clk;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt_req;
    (* dont_touch = "true" *) logic __emu_clk_i;

    // declare format for timestep
    `REAL_FROM_WIDTH_EXP(DT_FMT, `DT_WIDTH, `DT_EXPONENT);

    // instantiate MSDSL model, passing through format information
    osc_model_core #(
        `PASS_REAL(emu_dt, DT_FMT),
        `PASS_REAL(dt_req, DT_FMT)
    ) osc_model_core_i (
        .emu_rst(__emu_rst),
        .emu_clk(__emu_clk),
        .emu_dt(__emu_dt),
        .dt_req(__emu_dt_req),
        .clk_val(__emu_clk_val),
        .clk_i(__emu_clk_i),
        .clk_o(clk_o)
    );
endmodule
