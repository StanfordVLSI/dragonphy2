`include "svreal.sv"

`define DT_WIDTH 27
`define DT_EXPONENT -46

module test_adc_model #(
    parameter integer n=8
) (
    input real in_,
    input wire logic clk_val,
    output wire logic [(n-1):0] out_mag,
    output wire logic out_sgn,
    input wire logic emu_rst,
    input wire logic emu_clk
);
    // Convert real to fixed-point
    `MAKE_REAL(in_int, 10);
    assign `FORCE_REAL(in_, in_int);

    // Create signal for ADC timestep request
    `REAL_FROM_WIDTH_EXP(dt_req, `DT_WIDTH, `DT_EXPONENT);

    // Instantiate model
    rx_adc_core #(
        `PASS_REAL(in_, in_int),
        `PASS_REAL(emu_dt, dt_req),
        `PASS_REAL(dt_req, dt_req),
        `PASS_REAL(dt_req_max, dt_req)
    ) rx_adc_core_i (
        // main I/O: input, output, and clock
        .in_(in_int),
        .out_mag(out_mag),
        .out_sgn(out_sgn),
        .clk_val(clk_val),
        // emulator I/O
        .dt_req(dt_req),
        .emu_dt(dt_req),
        .emu_clk(emu_clk),
        .emu_rst(emu_rst),
        .dt_req_max({1'b0, {((`DT_WIDTH)-1){1'b1}}})
    );
endmodule