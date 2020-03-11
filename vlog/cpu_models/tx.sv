`include "signals.sv"

module tx #(
    parameter real v_lo=-1.0,
    parameter real v_hi=+1.0
) (
    input wire logic data_i,
    `ANALOG_OUTPUT data_ana_o,
    input wire logic clk_i
);
    import pulse_resp_pack::*;
    logic [(pulse_resp_length-1):0] mem = '0;

    real tmp;
    always @(posedge clk_i) begin
        mem = (mem << 1) | data_i;
        tmp = 0;
        for (int i = 0; i < pulse_resp_length; i=i+1) begin
            tmp += (mem[i] ? v_hi : v_lo) * pulse_resp_values[i];
        end
        data_ana_o.value <= tmp;
    end
endmodule
