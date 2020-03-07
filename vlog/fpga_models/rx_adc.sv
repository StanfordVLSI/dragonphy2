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
    input wire logic rst
);
    generate
        // run ADC as combo logic
        logic signed [(n_adc-1):0] out_imm;
        rx_adc_core #(
            `INTF_PASS_REAL(in_, in.value)
        ) rx_adc_core_i (
            .in_(in.value),
            .out(out_imm)
        );

        // synchronize output
        always @(posedge clk) begin
            if (rst == 1'b1) begin
                out <= 'd0;
            end else begin
                out <= out_imm;
            end
        end
    endgenerate   
endmodule
