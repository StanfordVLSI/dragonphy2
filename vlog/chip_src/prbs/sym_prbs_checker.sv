`default_nettype none

module sym_prbs_checker #(
    parameter integer n_prbs=32,
    parameter integer n_channels=16,
    parameter integer sym_bitwidth=2
) (
    // basic clock and reset for this block
    input wire logic clk,
    input wire logic rst,

    // clock gating
    input wire logic cke,

    // define the PRBS equation
    input wire logic [(n_prbs-1):0] eqn,

    // bits for selecting / de-selecting certain channels from the PRBS test
    input wire logic [(n_channels-1):0] chan_sel,

    // "chicken" bits for flipping the sign of various bits
    input wire logic [1:0] inv_chicken,

    // recovered data from ADC, FFE, MLSD, etc.
    input wire logic [sym_bitwidth-1:0] rx_syms [(n_channels-1):0],
    input wire logic [7:0] rx_bits_delay,

    // checker mode:
    // 2'b00: RESET
    // 2'b01: ALIGN
    // 2'b10: TEST
    // 2'b11: FREEZE
    input wire logic [1:0] checker_mode,

    // outputs
    output wire logic [63:0] err_bits,
    output wire logic [63:0] total_bits,
    output wire logic [sym_bitwidth*n_channels-1:0] prbs_flags,
    output wire logic [7:0] prbs_flags_delay
);

    assign prbs_flags_delay = rx_bits_delay + 32;
    // TODO: consider using enum here
    localparam logic [1:0]  RESET = 2'b00;
    localparam logic [1:0]  ALIGN = 2'b01;
    localparam logic [1:0]   TEST = 2'b10;
    localparam logic [1:0] FREEZE = 2'b11;

    // instantiate the core prbs checker
    logic [(sym_bitwidth*n_channels-1):0] rx_bits;
    genvar gi, gj, k;

    generate 
        for(gi = 0; gi < sym_bitwidth; gi += 1) begin
            for(gj = 0; gj < n_channels; gj += 1) begin
                assign rx_bits[gi*n_channels + gj] = rx_syms[gj][gi];
            end
        end 
    endgenerate

    logic [(sym_bitwidth*n_channels-1):0] err_signals;
    assign prbs_flags = err_signals;

    generate
        for (k=0; k<sym_bitwidth*n_channels; k=k+1) begin
            prbs_checker_core #(
                .n_prbs(n_prbs)
            ) prbs_checker_core_i (
                .clk(clk),
                .rst(rst),
                .cke(cke),
                .eqn(eqn),
                .inv_chicken(inv_chicken),
                .rx_bit(rx_bits[k]),
                .err(err_signals[k])
            );
        end
    endgenerate

    // sum up number of errors for selected channels
    logic [$clog2(n_channels*sym_bitwidth):0] err_count;
    logic [$clog2(n_channels*sym_bitwidth):0] tot_count;

    integer i, j;
    always @* begin
        err_count = 0;
        tot_count = 0;
        for (i=0; i< n_channels; i=i+1) begin
            tot_count = tot_count + (chan_sel[i] << 1);
            for (j = 0; j < sym_bitwidth; j = j + 1) begin
                err_count = err_count + (err_signals[i + j*n_channels] & chan_sel[i]);
            end
        end
    end

    // check the RX data

    logic [63:0] err_bits_reg;
    logic [63:0] total_bits_reg;

    always @(posedge clk) begin
        if (checker_mode == RESET) begin
            err_bits_reg <= 0;
            total_bits_reg <= 0;
        end else if (checker_mode == ALIGN) begin
            err_bits_reg <= err_bits_reg;
            total_bits_reg <= total_bits_reg;
        end else if (checker_mode == TEST) begin
            err_bits_reg <= err_bits_reg + err_count;
            total_bits_reg <= total_bits_reg + tot_count;
        end else begin
            err_bits_reg <= err_bits_reg;
            total_bits_reg <= total_bits_reg;
        end
    end

    // assign outputs
    assign err_bits = err_bits_reg;
    assign total_bits = total_bits_reg;

endmodule

`default_nettype wire