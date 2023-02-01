`include "svreal.sv"

`ifndef FUNC_DATA_WIDTH
    `define FUNC_DATA_WIDTH 18
`endif

module test_analog_slice #(
    parameter integer chunk_width=8,
    parameter integer bits_per_symbol=2,
    parameter integer num_chunks=4,
    parameter integer pi_ctl_width=9,
    parameter integer slices_per_bank=4,
    parameter integer n_adc=8
) (
    input wire logic [(chunk_width*bits_per_symbol-1):0] chunk,
    input wire logic [($clog2(num_chunks)-1):0] chunk_idx,
    input wire logic [(pi_ctl_width-1):0] pi_ctl,
    input wire logic [($clog2(slices_per_bank)-1):0] slice_offset,
    input wire logic sample_ctl,
    input wire logic incr_sum,
    input wire logic write_output,
    output wire logic out_sgn,
    output wire logic [(n_adc-1):0] out_mag,
    input wire logic clk,
    input wire logic rst,
    input real jitter_rms,
    input real noise_rms,
    input wire logic [((`FUNC_DATA_WIDTH)-1):0] wdata0,
    input wire logic [((`FUNC_DATA_WIDTH)-1):0] wdata1,
    input wire logic [8:0] waddr,
    input wire logic we
);
    // declare svreal types for jitter and noise
    `MAKE_REAL(jitter_rms_int, 10e-12);
    `MAKE_REAL(noise_rms_int, 10e-3);

    // assign real-number types to svreal types
    assign `FORCE_REAL(jitter_rms, jitter_rms_int);
    assign `FORCE_REAL(noise_rms, noise_rms_int);

    // instantiate the slice
    analog_slice #(
        `PASS_REAL(jitter_rms, jitter_rms_int),
        `PASS_REAL(noise_rms, noise_rms_int)
    ) analog_slice_i (
        .chunk(chunk),
        .chunk_idx(chunk_idx),
        .pi_ctl(pi_ctl),
        .slice_offset(slice_offset),
        .sample_ctl(sample_ctl),
        .incr_sum(incr_sum),
        .write_output(write_output),
        .out_sgn(out_sgn),
        .out_mag(out_mag),
        .clk(clk),
        .rst(rst),
        .jitter_seed(0), // unused in this test
        .jitter_rms(jitter_rms_int),
        .noise_seed(0), // unused in this test
        .noise_rms(noise_rms_int),
        // runtime-defined function controls
        .wdata0(wdata0),
        .wdata1(wdata1),
        .waddr(waddr),
        .we(we)
    );
endmodule
