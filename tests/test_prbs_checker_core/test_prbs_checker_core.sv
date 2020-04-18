module test_prbs_checker_core #(
    parameter integer n_prbs=7,
    parameter integer n_channels=16,
    parameter integer n_shift_bits=$clog2(n_channels)
) (
    input wire logic clk,
    input wire logic rst,
    input wire logic prbs_cke,
    input wire logic [(n_channels-1):0] rx_bits,
    input wire logic [(n_shift_bits-1):0] rx_shift,
    output wire logic match
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

    // instantiate the checker core
    prbs_checker_core #(
        .n_prbs(n_prbs),
        .n_channels(n_channels),
        .n_shift_bits(n_shift_bits)
    ) prbs_checker_core_i (
        .clk(clk),
        .rst(rst),
        .prbs_cke(prbs_cke),
        .prbs_init_vals(prbs_init_vals),
        .rx_bits(rx_bits),
        .rx_shift(rx_shift),
        .match(match)
    );
endmodule