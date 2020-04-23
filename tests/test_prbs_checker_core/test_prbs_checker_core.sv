`timescale 1s/1ps

module test_prbs_checker_core #(
    parameter integer n_prbs=7,
    parameter integer n_channels=16,
    parameter integer n_shift_bits=$clog2(n_channels),
    parameter integer n_match_bits=$clog2(n_channels)+1
) (
    // checker core inputs
    input wire logic rst,
    input wire logic prbs_cke,
    // stimulus inputs
    input wire logic [(n_prbs-1):0] prbs_init,
    input wire logic [7:0] prbs_del,
    input wire logic [(n_shift_bits-1):0] rx_shift,
    // outputs
    output wire logic match,
    output wire logic [(n_match_bits-1):0] match_bits,
    output reg clk_div,
    // bogus input needed for fault
    input wire logic clk_bogus
);
    // assign the initial values for the PRBS generators
    // only valid for n_prbs=7 and n_channels=16
    logic [(n_prbs-1):0] prbs_init_vals [n_channels];
    assign prbs_init_vals[0] = 3;
    assign prbs_init_vals[1] = 10;
    assign prbs_init_vals[2] = 60;
    assign prbs_init_vals[3] = 11;
    assign prbs_init_vals[4] = 58;
    assign prbs_init_vals[5] = 31;
    assign prbs_init_vals[6] = 67;
    assign prbs_init_vals[7] = 9;
    assign prbs_init_vals[8] = 54;
    assign prbs_init_vals[9] = 55;
    assign prbs_init_vals[10] = 49;
    assign prbs_init_vals[11] = 37;
    assign prbs_init_vals[12] = 92;
    assign prbs_init_vals[13] = 74;
    assign prbs_init_vals[14] = 63;
    assign prbs_init_vals[15] = 1;

    initial begin
        if (!((n_prbs == 7) && (n_channels == 16))) begin
            $error("Invalid combination of n_prbs and n_channels.");
        end
    end

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
    logic [269:0] prbs_mem;
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            prbs_mem <= 0;
        end else begin
            prbs_mem <= {prbs_out, prbs_mem[269:1]};
        end
    end

    // add current PRBS bit to the history
    logic [270:0] prbs_concat;
    assign prbs_concat = {prbs_out, prbs_mem};

    // select a delayed slice of those PRBS bits
    logic [(n_channels-1):0] rx_bits_imm;
    logic [(n_channels-1):0] rx_bits;

    assign rx_bits_imm = prbs_concat[(270-prbs_del) -: n_channels];

    always @(posedge clk_div) begin
        if (rst == 1'b1) begin
            rx_bits <= 0;
        end else begin
            rx_bits <= rx_bits_imm;
        end
    end

    // instantiate the checker core
    prbs_checker_core #(
        .n_prbs(n_prbs),
        .n_channels(n_channels),
        .n_shift_bits(n_shift_bits)
    ) prbs_checker_core_i (
        .clk(clk_div),
        .rst(rst),
        .prbs_cke(prbs_cke),
        .prbs_init_vals(prbs_init_vals),
        .rx_bits(rx_bits),
        .rx_shift(rx_shift),
        .match(match),
        .match_bits(match_bits)
    );
endmodule