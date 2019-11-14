`include "signals.sv"

module tx #(
    parameter real v_lo=-1.0,
    parameter real v_hi=+1.0
) (
    input wire logic data_i,
    input wire logic clk_i,
    `ANALOG_OUTPUT data_ana_o
);

    localparam integer v_lo_fixed = v_lo * (2.0**(-(`ANALOG_EXPONENT)));
    localparam integer v_hi_fixed = v_hi * (2.0**(+(`ANALOG_EXPONENT)));

    always @(posedge clk_i) begin
        data_ana_o.value <= (data_i ? v_hi_fixed : v_lo_fixed);
    end

endmodule
