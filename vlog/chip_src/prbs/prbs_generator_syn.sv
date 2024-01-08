`default_nettype none

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
    output wire logic out,
    output wire logic [n_prbs-1:0] prbs_state_ext,


    input wire logic late_load,
    input wire logic [n_prbs-1:0] late_load_val,
    input wire logic early_load,
    input wire logic [n_prbs-1:0] early_load_val,
    input wire logic run_twice,
    input wire logic stall

);
    //// register inj_err signal
    //logic [3:0] inj_err_mem;
    //always @(posedge clk) begin
    //    if (rst) begin
    //        inj_err_mem <= 0;
    //    end else if (cke) begin
    //        inj_err_mem <= {inj_err_mem[2:0], inj_err};
    //    end else begin
    //        inj_err_mem <= inj_err_mem;
    //    end
    //end
//
    //// determine if we should inject an error
    //// this should happen on the rising edge of inj_err
    //logic inj_error_pulse;
    //assign inj_error_pulse = (~inj_err_mem[3]) & (inj_err_mem[2]);

    // select bits for the LFSR equation
    logic [(n_prbs-1):0] prbs_state, next_prbs_state, next_next_prbs_state;
    logic [(n_prbs-1):0] prbs_input;
    assign prbs_state_ext = prbs_state;

    always_comb begin
        if (late_load) begin
            prbs_input = late_load_val;
        end else if (early_load) begin
            prbs_input = early_load_val;
        end else begin
            prbs_input = prbs_state;
        end
    end

    logic [(n_prbs-1):0] prbs_select;
    logic prbs_xor;


    assign prbs_select = prbs_input & eqn;
    // XOR selected bits
    assign prbs_xor = ^prbs_select;

    assign next_prbs_state = {prbs_input[(n_prbs-2):0], (prbs_xor)};

    logic [(n_prbs-1):0] next_prbs_select;
    logic next_prbs_xor;
    
    assign next_prbs_select = next_prbs_state & eqn;
    // XOR selected bits
    assign next_prbs_xor = ^next_prbs_select;

    assign next_next_prbs_state = {next_prbs_state[(n_prbs-2):0], (next_prbs_xor)};


    // update the LFSR state
    always @(posedge clk) begin
        if (rst) begin
            prbs_state <= init_val;
        end else if (cke) begin
            prbs_state <= stall ? prbs_input : (run_twice ? next_next_prbs_state : next_prbs_state);
        end else begin
            prbs_state <= prbs_state;
        end
    end

    // compute output
    logic out_reg;
    always @(posedge clk) begin
        if (rst) begin
            out_reg <= 0;
        end else if (cke) begin
            out_reg <= stall ? prbs_input : (run_twice ? next_prbs_state[n_prbs-1] : prbs_state[n_prbs-1]);
        end else begin
            out_reg <= out_reg;
        end
    end

    // output assignment
    assign out = out_reg;
endmodule

`default_nettype wire