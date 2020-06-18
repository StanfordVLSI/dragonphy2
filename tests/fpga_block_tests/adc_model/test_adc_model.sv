`include "svreal.sv"

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

    // Instantiate model
    rx_adc_core #(
        `PASS_REAL(in_, in_int)
    ) rx_adc_core_i (
        // main I/O: input, output, and clock
        .in_(in_int),
        .out_mag(out_mag),
        .out_sgn(out_sgn),
        .clk_val(clk_val),
        // emulator I/O
        .emu_clk(emu_clk),
        .emu_rst(emu_rst)
    );
endmodule