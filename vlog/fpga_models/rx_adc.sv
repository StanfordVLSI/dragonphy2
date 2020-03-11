`include "svreal.sv"
`include "signals.sv"

module rx_adc #(
    parameter real v_ref_p=+1.0,
    parameter real v_ref_n=-1.0,
    parameter integer n_adc=8
) (
    `ANALOG_INPUT in,
    output var logic signed [(n_adc-1):0] out,
    input wire logic clk,
    // TODO: figure out a cleaner way to pass clk_o_val
    input wire logic clk_val,
    input wire logic rst
);
    generate
        rx_adc_core #(
            `INTF_PASS_REAL(in_, in.value)
        ) rx_adc_core_i (
            .in_(in.value),
            .out(out),
            .clk(clk),
            .clk_val(clk_val),
            .rst(rst)
        );
    endgenerate   
endmodule
