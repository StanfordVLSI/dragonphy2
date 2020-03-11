`include "signals.sv"

module tx #(
    parameter real v_lo=-1.0,
    parameter real v_hi=+1.0
) (
    input wire logic data_i,
    `ANALOG_OUTPUT data_ana_o,
    input wire logic clk_i
);
    always @(posedge clk_i) begin
        data_ana_o.value = data_i ? v_hi : v_lo;
    end
endmodule
