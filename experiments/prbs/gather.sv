`timescale 1s/1fs

module gather(
    input wire clk,
    input wire rst,
    output wire out
);

    prbs_generator_syn #(
        .n_prbs(32)
    ) prbs_i (
        .clk(clk),
        .rst(rst),
        .cke(1'b1),
        .init_val(32'h428f020c),
        .eqn(32'h48000000),
        .inj_err(1'b0),
        .inv_chicken(2'b00),
        .out(out)
    );

endmodule
