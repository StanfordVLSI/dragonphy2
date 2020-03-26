`include "svreal.sv"
`include "signals.sv"

module rx_adc #(
    parameter real v_ref_p=+1.0,
    parameter real v_ref_n=-1.0,
    parameter integer n_adc=8
) (
    `ANALOG_INPUT in,
    output wire logic signed [(n_adc-1):0] out,
    `CLOCK_INPUT clk,
    input wire logic rst
);
    // signals use for external I/O
    (* dont_touch = "true" *) logic __emu_rst;
    (* dont_touch = "true" *) logic __emu_clk;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt_req;

    // declare format for timestep
    `REAL_FROM_WIDTH_EXP(DT_FMT, `DT_WIDTH, `DT_EXPONENT);

    // set maximum value for timestep
    `REAL_FROM_WIDTH_EXP(dt_req_max, `DT_WIDTH, `DT_EXPONENT);
    `ASSIGN_CONST_REAL(((2.0**((`DT_WIDTH)-1))-1.0)*2.0**(`DT_EXPONENT), dt_req_max);

    generate
        rx_adc_core #(
            `INTF_PASS_REAL(in_, in.value),
            `PASS_REAL(emu_dt, DT_FMT),
            `PASS_REAL(dt_req, DT_FMT),
            `PASS_REAL(dt_req_max, DT_FMT)
        ) rx_adc_core_i (
            // main I/O: input, output, and clock
            .in_(in.value),
            .in_valid(in.valid),
            .out(out),
            .clk_val(clk.value),
            // timestep control: DT request and response
            .dt_req(__emu_dt_req),
            .emu_dt(__emu_dt),
            // emulator clock and reset
            .emu_clk(__emu_clk),
            .emu_rst(__emu_rst),
            // additional input: maximum timestep
            .dt_req_max(dt_req_max)
        );
    endgenerate
endmodule
