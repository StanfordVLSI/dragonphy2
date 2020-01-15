`include "signals.sv"

module rx_adc #(
    parameter real v_ref_p=+1.0,
    parameter real v_ref_n=-1.0,
    parameter integer n_adc=8
) (
    `ANALOG_INPUT in,
    output var logic signed [(n_adc-1):0] out,
    input wire logic clk
);

    generate
        // alias input as a local signal
        `INTF_INPUT_TO_REAL(in.value, in_value);

        // scale input voltage to range -(2**(n_adc-1)) to (2**(n_adc-1))-1
        localparam real scale = (2.0**(n_adc) - 1.0) / (v_ref_p - v_ref_n);
        localparam real offset = -(scale * v_ref_n) - (2.0**(n_adc - 1));
        `MUL_CONST_REAL(scale, in_value, mul_val);
        `ADD_CONST_REAL(offset, mul_val, adc_val);

        // clamp to range -(2**(n_adc-1)) to (2**(n_adc-1))-1
        `MAKE_CONST_REAL(-(2.0**(n_adc - 1)), min_val);
        `MAKE_CONST_REAL((2.0**(n_adc - 1)) - 1, max_val);
        `MAX_REAL(adc_val, min_val, low_clamp);
        `MIN_REAL(low_clamp, max_val, out_real);

        // convert real-number output to an integer
        `REAL_TO_INT(out_real, n_adc, out_int);
        always @(posedge clk) begin
            out <= out_int;
        end
    endgenerate
endmodule
