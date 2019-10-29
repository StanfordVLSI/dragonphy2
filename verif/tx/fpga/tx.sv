`include "signals.sv"

module tx (
    input wire logic data_i,
    input wire logic clk_i,
    `ANALOG_OUTPUT data_ana_o
);

    `DECL_ANALOG(volt0);
    `DECL_ANALOG(volt1);
    `DECL_ANALOG(out_imm);

    `SVREAL_ASSIGN_CONST(volt0, -1);
    `SVREAL_ASSIGN_CONST(volt1, +1);
    `SVREAL_MUX(data_i, volt0, volt1, out_imm);

    always @(posedge clk_i) begin
        data_ana_o.value <= out_imm.value;
    end

endmodule
