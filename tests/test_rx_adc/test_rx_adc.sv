`include "svreal.sv"

module test_rx_adc (
    input real in_,
    output wire logic signed [7:0] out,
    input wire logic clk_val,
    output real dt_req,
    input wire logic emu_clk,
    input wire logic emu_rst
);
    // format for timesteps
    `REAL_FROM_WIDTH_EXP(emu_dt_int, `DT_WIDTH, `DT_EXPONENT);
    `REAL_FROM_WIDTH_EXP(dt_req_int, `DT_WIDTH, `DT_EXPONENT);

    // format for input
    `REAL_FROM_WIDTH_EXP(in_int, 18, -12);

    // wire to external real values
    assign `FORCE_REAL(in_, in_int);
    assign dt_req = `TO_REAL(dt_req_int);

    // set maximum value for timestep
    `REAL_FROM_WIDTH_EXP(dt_req_max, `DT_WIDTH, `DT_EXPONENT);
    `ASSIGN_CONST_REAL(((2.0**((`DT_WIDTH)-1))-1.0)*2.0**(`DT_EXPONENT), dt_req_max);

    // instantiate ADC core
    rx_adc_core #(
        `PASS_REAL(in_, in_int),
        `PASS_REAL(emu_dt, emu_dt_int),
        `PASS_REAL(dt_req, dt_req_int),
        `PASS_REAL(dt_req_max, dt_req_max)
    ) rx_adc_core_i (
        // main I/O: input, output, and clock
        .in_(in_int),
        .out(out),
        .clk_val(clk_val),
        // timestep control: DT request and response
        .dt_req(dt_req_int),
        .emu_dt(),
        // emulator clock and reset
        .emu_clk(emu_clk),
        .emu_rst(emu_rst),
        // additional input: maximum timestep
        .dt_req_max(dt_req_max)
    );
endmodule