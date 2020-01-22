// dragon uses rx_adc_core

`include "signals.sv"

module rx_adc #(
    parameter real v_ref_p=+1.0,
    parameter real v_ref_n=-1.0,
    parameter integer n_adc=8
) (
    `ANALOG_INPUT in,
    output wire logic signed [(n_adc-1):0] out,
    input wire logic clk
);
    generate
        rx_adc_core #(
            `INTF_PASS_REAL(in_, in.value)
        ) rx_adc_core_i (
            .in_(in.value),
            .out(out),
            .clk(clk),
            .rst(1'b0)
        );
    endgenerate   
endmodule
