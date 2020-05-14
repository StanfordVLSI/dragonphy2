`timescale 1s/1ps

module test_prbs_checker #(
    parameter integer n_prbs=7,
    parameter integer n_channels=16,
    parameter [(n_prbs-1):0] prbs_init=1
) (
    input wire logic rst,
    input wire logic [(n_prbs-1):0] eqn,
    input wire logic [1:0] checker_mode,
    input wire logic [4:0] delay,
    // outputs
    output reg clk_div,
    output wire logic [63:0] err_bits,
    output wire logic [63:0] total_bits,
    // bogus input needed for fault
    input wire logic clk_bogus
);
    // fast and slow clock
    // note that the period of the fast clock is actually "2us" due to a limit in fault
    logic clk;
    integer k;
    always begin
        for (k = 0; k <= (n_channels-1); k=k+1) begin
            clk = 1'b0;
            clk_div = 1'b0;
            #(1us);
            clk = 1'b1;
            if (k == 0) begin
                clk_div = 1'b1;
            end else begin
                clk_div = 1'b0;
            end
            #(1us);
        end
    end

    // instantiate the PRBS generator
    logic prbs_out;
    prbs_generator #(
        .n_prbs(n_prbs)
    ) prbs_gen_i (
        .clk(clk),
        .rst(rst),
        .cke(1'b1),
        .init_val(prbs_init),
        .out(prbs_out)
    );

    // store up a history of PRBS bits
    logic [(31+n_channels-1):0] prbs_mem;
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            prbs_mem <= 0;
        end else begin
            prbs_mem <= {prbs_mem[(31+n_channels-2):0], prbs_out};
        end
    end

    // select one of those bits from the memory
    logic [(n_channels-1):0] rx_bits_imm;
    assign rx_bits_imm = prbs_mem[(delay+n_channels-1) -: n_channels];

    // register that bit to the divided clock
    logic [(n_channels-1):0] rx_bits;
    always @(posedge clk_div) begin
        if (rst == 1'b1) begin
            rx_bits <= 0;
        end else begin
            rx_bits <= rx_bits_imm;
        end
    end

    // instantiate the checker core
    prbs_checker #(
        .n_prbs(n_prbs),
        .n_channels(n_channels)
    ) prbs_checker_i (
        .clk(clk_div),
        .rst(rst),
        .cke(1'b1),
        .eqn(eqn),
        .chan_sel({n_channels{1'b1}}),
        .inv_chicken(2'b00),
        .rx_bits(rx_bits),
        .checker_mode(checker_mode),
        .err_bits(err_bits),
        .total_bits(total_bits)
    );
endmodule
