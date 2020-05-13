`default_nettype none

module prbs_checker_core #(
    parameter integer n_prbs=32
) (
    // basic clock and reset for this block
    input wire logic clk,
    input wire logic rst,
    // clock gating
    input wire logic cke,
    // define the PRBS equation
    input wire logic [(n_prbs-1):0] eqn,
    // "chicken" bits for flipping the sign of various bits
    input wire logic [1:0] inv_chicken,
    // input bit
    input wire logic rx_bit,
    // output signal indicating if there is an error
    output wire logic err
);
    // register input
    logic rx_bit_reg;
    always @(posedge clk) begin
        if (rst) begin
            rx_bit_reg <= 0;
        end else if (cke) begin
            rx_bit_reg <= rx_bit;
        end else begin
            rx_bit_reg <= rx_bit_reg;
        end
    end

    // create memory of past inputs, with chicken bit to flip
    // the polarity of the input, if desired
    logic [(n_prbs-1):0] rx_mem;
    always @(posedge clk) begin
        if (rst) begin
            rx_mem <= 0;
        end else if (cke) begin
            rx_mem <= {rx_mem[(n_prbs-2):0], (rx_bit_reg^inv_chicken[0])};
        end else begin
            rx_mem <= rx_mem;
        end
    end

    // select bits for the LFSR equation
    logic [(n_prbs-1):0] rx_mem_select;
    assign rx_mem_select = rx_mem & eqn;

    // xor selected bits
    logic rx_mem_xor;
    assign rx_mem_xor = ^rx_mem_select;

    // determine if an error occured
    logic err_imm;
    assign err_imm = rx_mem_xor ^ rx_bit_reg ^ inv_chicken[1];

    // register output
    logic err_reg;
    always @(posedge clk) begin
        if (rst) begin
            err_reg <= 0;
        end else if (cke) begin
            err_reg <= err_imm;
        end else begin
            err_reg <= err_reg;
        end
    end

    // assign output
    assign err = err_reg;
endmodule

`default_nettype wire