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
    // TODO: make more generic
    always @(posedge clk) begin
        if (`SVREAL_SIGNIFICAND(in.value) < 0) begin
            out <= -(1<<(n_adc-1))+0;
        end else begin
            out <= +(1<<(n_adc-1))-1;
        end
    end
endmodule
