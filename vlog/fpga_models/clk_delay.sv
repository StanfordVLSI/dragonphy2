`timescale 1s/1fs
`include "svreal.sv"
`include "signals.sv"

module clk_delay (
    input wire logic [7:0] code,
    `CLOCK_INPUT clk_i,
    `CLOCK_OUTPUT clk_o
);
    // signals use for external I/O
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt_req;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt;
    (* dont_touch = "true" *) logic __emu_clk;
    (* dont_touch = "true" *) logic __emu_rst;
    (* dont_touch = "true" *) logic __emu_clk_val;
    (* dont_touch = "true" *) logic __emu_clk_i;

    // format for emu_dt / dt_req
    `REAL_FROM_WIDTH_EXP(DT_FMT, `DT_WIDTH, `DT_EXPONENT);

    // set maximum value for timestep
    `REAL_FROM_WIDTH_EXP(dt_req_max, `DT_WIDTH, `DT_EXPONENT);
    `ASSIGN_CONST_REAL(((2.0**((`DT_WIDTH)-1))-1.0)*2.0**(`DT_EXPONENT), dt_req_max);

    // instantiate MSDSL model, passing through format information
    clk_delay_core #(
        `PASS_REAL(emu_dt, DT_FMT),
        `PASS_REAL(dt_req, DT_FMT),
        `PASS_REAL(dt_req_max, dt_req_max)
    ) clk_delay_core_i (
        // main I/O: delay code, clock in/out values
        .code(code),
        .clk_i_val(clk_i.value),
        .clk_o_val(clk_o.value),
        // timestep control: DT request and response
        .dt_req(__emu_dt_req),
        .emu_dt(__emu_dt),
        // emulator clock and reset
        .emu_clk(__emu_clk),
        .emu_rst(__emu_rst),
        // additional input: maximum timestep
        .dt_req_max(dt_req_max)
    );

    // wire up output clock value
    assign __emu_clk_val = clk_o.value;

    // wire up the output clock signal
    assign clk_o.clock = __emu_clk_i;
endmodule
