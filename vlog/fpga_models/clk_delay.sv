`timescale 1s/1fs
`include "svreal.sv"

module clk_delay (
    input wire logic [7:0] code,
    input wire logic clk_i,
    input wire logic clk_i_val,
    output wire logic clk_o,
    output wire logic clk_o_val
);
    // signals use for external I/O
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt_req;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt;
    (* dont_touch = "true" *) logic __emu_clk;
    (* dont_touch = "true" *) logic __emu_rst;
    (* dont_touch = "true" *) logic __emu_clk_val;
    (* dont_touch = "true" *) logic __emu_clk_i;

    // format for timesteps
    `REAL_FROM_WIDTH_EXP(DT_FMT, `DT_WIDTH, `DT_EXPONENT);

    // instantiate MSDSL model, passing through format information
    clk_delay_core #(
        `PASS_REAL(emu_dt, DT_FMT),
        `PASS_REAL(dt_req, DT_FMT),
        `PASS_REAL(dt_req_max, DT_FMT)
    ) clk_delay_core_i (
        // main I/O: delay code, clock in/out values
        .code(code),
        .clk_i_val(clk_i_val),
        .clk_o_val(clk_o_val),
        // timestep control: DT request and response
        .dt_req(__emu_dt_req),
        .emu_dt(__emu_dt),
        // emulator clock and reset
        .emu_clk(__emu_clk),
        .emu_rst(__emu_rst),
        // additional input: maximum timestep
        // TODO: clean this up because it is not compatible with the `FLOAT_REAL option
        .dt_req_max({1'b0, {((`DT_WIDTH)-1){1'b1}}})
    );

    // wire up output clock value
    assign __emu_clk_val = clk_o_val;

    // wire up the output clock signal
    assign clk_o = __emu_clk_i;
endmodule
