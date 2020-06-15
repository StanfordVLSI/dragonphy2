`include "iotype.sv"

module input_divider (
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

    // t_lo
    `DECL_DT(t_lo);
    `ASSIGN_CONST_REAL(125e-12, t_lo);

    // t_hi
    `DECL_DT(t_hi);
    `ASSIGN_CONST_REAL(125e-12, t_hi);

    // instantiate MSDSL model, passing through format information
    osc_model_core #(
        `PASS_REAL(t_lo, t_lo),
        `PASS_REAL(t_hi, t_hi),
        `PASS_REAL(emu_dt, emu_dt),
        `PASS_REAL(dt_req, dt_req)
    ) osc_model_core_i (
        .emu_rst(emu_rst),
        .emu_clk(emu_clk),
        .t_lo(t_lo),
        .t_hi(t_hi),
        .emu_dt(emu_dt),
        .dt_req(dt_req),
        .clk_val(out)
    );

    // out_meas is unused
    assign out_meas = 1'b0;
endmodule