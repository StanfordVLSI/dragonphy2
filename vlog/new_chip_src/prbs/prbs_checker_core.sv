module prbs_checker_core #(
    parameter integer n_prbs=7,
    parameter integer n_channels=16,
    parameter integer n_shift_bits=$clog2(n_channels),
    parameter integer n_match_bits=$clog2(n_channels)+1
) (
    input wire logic clk,
    input wire logic rst,
    input wire logic prbs_cke,
    input wire logic [(n_prbs-1):0] prbs_init_vals [n_channels],
    input wire logic [(n_channels-1):0] rx_bits,
    input wire logic [(n_shift_bits-1):0] rx_shift,
    output reg [(n_match_bits-1):0] match_bits,
    output reg match
);
    // store previous sets of rx_bits
    logic [(n_channels-1):0] rx_bits_prev_1;
    logic [(n_channels-1):0] rx_bits_prev_2;

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            rx_bits_prev_1 <= 0;
            rx_bits_prev_2 <= 0;
        end else begin
            rx_bits_prev_1 <= rx_bits;
            rx_bits_prev_2 <= rx_bits_prev_1;
        end
    end

    // store output bits of the PRBS
    logic [(n_channels-1):0] prbs_bits;

    genvar k;
    generate
        for (k=0; k<n_channels; k=k+1) begin
            prbs_generator #(
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
    logic [((2*n_channels)-1):0] rx_bits_concat;
    assign rx_bits_concat = {rx_bits_prev_1, rx_bits_prev_2};

    // select input bits based on the user-provided shift
    logic [(n_channels-1):0] rx_bits_select_imm;
    logic [(n_channels-1):0] rx_bits_select;

    assign rx_bits_select_imm = rx_bits_concat[((2*n_channels)-1-rx_shift) -: n_channels];

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            rx_bits_select <= 0;
        end else begin
            rx_bits_select <= rx_bits_select_imm;
        end
    end

    // count the number of correct bits
    logic [(n_channels-1):0] xnor_bits;
    logic [(n_match_bits-1):0] match_bits_imm;

    assign xnor_bits = rx_bits_select ~^ prbs_bits;

    // count ones (ref: https://stackoverflow.com/questions/27197177/ones-count-system-verilog)
    // $countones is not compatible with Icarus Verilog so a more verbose implementation has to be used
    integer idx;
    always @* begin
        match_bits_imm = 0;
        for(idx=0; idx<n_channels; idx=idx+1) begin
            match_bits_imm = match_bits_imm + xnor_bits[idx];
        end
    end

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            match_bits <= 0;
        end else begin
            match_bits <= match_bits_imm;
        end
    end

    // compare the selected bits against the prbs output
    logic match_imm;
    assign match_imm = (rx_bits_select == prbs_bits);

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            match <= 0;
        end else begin
            match <= match_imm;
        end
    end
endmodule
