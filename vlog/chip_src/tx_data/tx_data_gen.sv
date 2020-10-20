`default_nettype none

module tx_data_gen #(
    parameter integer Nprbs=32,
    parameter integer Nti=16
) (
    input wire logic clk,
    input wire logic rst,
    input wire logic cke,
    input wire logic semaphore,

    input wire logic [2:0] data_mode,
    input wire logic [15:0] data_per,
    input wire logic [(Nti-1):0] data_in,

    input wire logic [(Nprbs-1):0] prbs_init [(Nti-1):0],
    input wire logic [(Nprbs-1):0] prbs_eqn,
    input wire logic [(Nti-1):0] prbs_inj_err,
    input wire logic [1:0] prbs_chicken,

    output wire logic [(Nti-1):0] data_out
);

    genvar i;
    generate
        for(i=0; i<Nti; i=i+1) begin
            prbs_generator_syn #(
                .n_prbs(Nprbs)
            ) prbs_generator_syn_i (
                .clk(clk),
                .rst(rst),
                .cke(cke),
                .init_val(prbs_init[i]),
                .eqn(prbs_eqn),
                .inj_err(prbs_inj_err[i]),
                .inv_chicken(prbs_chicken),
                .out(data_out[i])
            );
        end
    endgenerate

endmodule

`default_nettype wire