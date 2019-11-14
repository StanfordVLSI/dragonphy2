`include "signals.sv"

module rx_adc #(
    parameter real v_ref_p=+1.0,
    parameter real v_ref_n=-1.0,
    parameter integer n_adc=8
) (
    `ANALOG_INPUT in,
    output var logic signed [(n_adc-1):0] out = 0,
    input wire logic clk
);

    integer code_raw, code;
    always @(posedge clk) begin
        // convert input to code mapping [v_ref_n, v_ref_p] to [0, ((1<<n_adc)-1)]
        code_raw = integer'(((2.0**n_adc)-1.0)*(in.value-v_ref_n)/(v_ref_p-v_ref_n));

        // clamp code to [0, ((1<<n_adc)-1)]
        if (code_raw < 0) begin
            code = 0;
        end else if (code_raw > ((1<<n_adc)-1)) begin
            code = (1<<n_adc)-1;
        end else begin
            code = code_raw;
        end

        // shift output to range -(1<<(n_adc-1)), +(1<<(n_adc-1)) - 1
        out = code - (1<<(n_adc-1));
    end

endmodule
