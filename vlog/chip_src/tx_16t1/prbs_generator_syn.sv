`default_nettype none
`timescale 100ps/1ps  // Remove this line before synthesis
module prbs_generator_syn #(
    parameter integer n_prbs=32
) (
    // basic clock and reset for this block
    input wire logic clk,
    input wire logic rst,

    // clock gating
    input wire logic cke,

    // define the PRBS initialization
    input wire logic [(n_prbs-1):0] init_val,

    // define the PRBS equation
    input wire logic [(n_prbs-1):0] eqn,

    // signal for injecting errors
    input wire logic inj_err,

    // "chicken" bits for flipping the sign of various bits
    input wire logic [1:0] inv_chicken,

    // output
    output wire logic out
);
    // register inj_err signal
    logic [3:0] inj_err_mem;
    always @(posedge clk) begin
        if (rst) begin
            inj_err_mem <= 0;
        end else if (cke) begin
            inj_err_mem <= {inj_err_mem[2:0], inj_err};
        end else begin
            inj_err_mem <= inj_err_mem;
        end
    end

    // determine if we should inject an error
    // this should happen on the rising edge of inj_err
    logic inj_error_pulse;
    assign inj_error_pulse = (~inj_err_mem[3]) & (inj_err_mem[2]);

    // select bits for the LFSR equation
    logic [(n_prbs-1):0] prbs_state;
    logic [(n_prbs-1):0] prbs_select;
    assign prbs_select = prbs_state & eqn;

    // xor selected bits
    logic prbs_xor;
    assign prbs_xor = ^prbs_select;

    // update the LFSR state
    always @(posedge clk) begin
        if (rst) begin
            prbs_state <= init_val;
        end else if (cke) begin
            prbs_state <= {prbs_state[(n_prbs-2):0], (prbs_xor^inv_chicken[0])};
        end else begin
            prbs_state <= prbs_state;
        end
    end

    // compute output
    logic out_reg;
    always @(posedge clk) begin
        #0.1; // Buffer and wire delay 6*FO4
        if (rst) begin
            out_reg <= 0;
        end else if (cke) begin
            out_reg <= prbs_state[n_prbs-1] ^ inj_error_pulse ^ inv_chicken[1];
        end else begin
            out_reg <= out_reg; 
        end
    end

    // output assignment
    assign out = out_reg;
endmodule

`default_nettype wire