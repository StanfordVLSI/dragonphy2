module prbs_checker_core #(
    parameter integer n_prbs=7,
    parameter integer n_channels=16,
    parameter integer n_shift_bits=$clog2(n_channels)
) (
    input wire logic clk,
    input wire logic rst,
    input wire logic prbs_cke,
    input wire logic [(n_prbs-1):0] prbs_init_vals [n_channels],
    input wire logic [(n_channels-1):0] rx_bits,
    input wire logic [(n_shift_bits-1):0] rx_shift,
    output wire logic match
);
    // store previous sets of rx_bits

    logic [(n_channels-1):0] rx_bits_prev;

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            rx_bits_prev <= 0;
        end else begin
            rx_bits_prev <= rx_bits;
        end
    end

    // store output bits of the PRBS

    logic [(n_channels-1):0] prbs_bits;

    generate
        for (genvar k=0; k<n_channels; k=k+1) begin
            module prbs_generator #(
                .n_prbs(n_prbs)
            ) prbs_gen_i (
                .clk(clk),
                .rst(rst),
                .cke(prbs_cke),
                .init_val(prbs_init_vals[k]),
                .out(prbs_bits[k])
            );
        end
    endgenerate

    // concatenate input bits
    logic [((2*n_prbs)-1):0] rx_bits_concat;
    assign rx_bits_concat = {rx_bits, rx_bits_prev};

    // select input bits based on the user-provided shift
    logic [(n_prbs-1):0] rx_bits_select;
    assign rx_bits_select = rx_bits_concat[((2*n_prbs)-1-rx_shift) -: n_prbs];

    // compare the selected bits against the prbs output
    assign match = (rx_bits_shifted == prbs_bits);
endmodule
