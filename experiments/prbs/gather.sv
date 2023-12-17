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
        .init_val(32'h00000001),
        .eqn(32'h4000_0004),
        .inj_err(1'b0),
        .inv_chicken(2'b00),
        .out(out),
        .stall(0),
        .early_load(0),
        .late_load(0),
        .run_twice(0)
    );


endmodule
