`include "iotype.sv"

module input_divider #(
    parameter real t_lo=125e-12,
    parameter real t_hi=125e-12
) (
    input wire logic in,
    input wire logic in_mdll,
    input wire logic sel_clk_source,
    input wire logic en,
    input wire logic en_meas,
    input wire logic [2:0] ndiv,
    input wire logic bypass_div,
    input wire logic bypass_div2,
    output wire logic out,
    output wire logic out_meas
);
    // signals use for external I/O
    (* dont_touch = "true" *) logic emu_rst;
    (* dont_touch = "true" *) logic emu_clk;
    (* dont_touch = "true" *) `DECL_DT(emu_dt);
    (* dont_touch = "true" *) `DECL_DT(dt_req);

    // instantiate MSDSL model, passing through format information
    osc_model_core #(
        // pass through real-valued parameters
        .t_lo(t_lo),
        .t_hi(t_hi),
        // pass formatting information
        `PASS_REAL(emu_dt, emu_dt),
        `PASS_REAL(dt_req, dt_req)
    ) osc_model_core_i (
        .emu_rst(emu_rst),
        .emu_clk(emu_clk),
        .emu_dt(emu_dt),
        .dt_req(dt_req),
        .clk_val(out)
    );

    // out_meas is unused
    assign out_meas = 1'b0;
endmodule