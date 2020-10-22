`timescale 1fs / 1fs

module test #(
    parameter integer Nprbs=32,
    parameter integer Nti=16
) (
    input wire logic clk,
    input wire logic rst,

    input wire logic [2:0] data_mode,
    input wire logic [15:0] data_per,
    input wire logic [(Nti-1):0] data_in,

    output wire logic [(Nti-1):0] data_out
);

    // assign the initial values
    logic [(Nprbs-1):0] prbs_init [(Nti-1):0];
    assign prbs_init[0]  = 32'h0ffd4066;
    assign prbs_init[1]  = 32'h38042b00;
    assign prbs_init[2]  = 32'h001fffff;
    assign prbs_init[3]  = 32'h39fbfe59;
    assign prbs_init[4]  = 32'h1ffd40cc;
    assign prbs_init[5]  = 32'h3e055e6a;
    assign prbs_init[6]  = 32'h03ff554c;
    assign prbs_init[7]  = 32'h3e0aa195;
    assign prbs_init[8]  = 32'h1f02aa60;
    assign prbs_init[9]  = 32'h31f401f3;
    assign prbs_init[10] = 32'h00000555;
    assign prbs_init[11] = 32'h300bab55;
    assign prbs_init[12] = 32'h1f05559f;
    assign prbs_init[13] = 32'h3f8afe65;
    assign prbs_init[14] = 32'h07ff5566;
    assign prbs_init[15] = 32'h7f8afccf;

    // instantiate the data generator
    tx_data_gen #(
        .Nprbs(Nprbs),
        .Nti(Nti)
    ) tx_data_gen_i (
        .clk(clk),
        .rst(rst),
        .cke(1'b1),
        .semaphore(1'b1),

        .data_mode(data_mode),
        .data_per(data_per),
        .data_in(data_in),

        .prbs_init(prbs_init),
        .prbs_eqn(32'h100002),
        .prbs_inj_err(16'd0),
        .prbs_chicken(2'b00),

        .data_out(data_out)
    );

endmodule
