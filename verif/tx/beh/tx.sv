`include "signals.sv"

module tx #(
    parameter real v_lo=-1.0,
    parameter real v_hi=+1.0
) (
    input wire logic data_i,
    input wire logic clk_i,
    `ANALOG_OUTPUT data_ana_o
);
    import impulse_pack::*;
    logic [(impulse_length-1):0] mem = '0;

    real tmp;
    always @(posedge clk_i) begin
        mem = (mem << 1) | data_i;
        tmp = 0;
        for (int i = 0; i < impulse_length; i=i+1) begin
            tmp += (mem[i] ? v_hi : v_lo) * impulse_values[i];
        end
        data_ana_o.value <= tmp;
    end
endmodule
