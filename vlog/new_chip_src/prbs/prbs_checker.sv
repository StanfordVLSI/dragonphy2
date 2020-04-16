module prbs_checker #(
    parameter integer n_prbs=7,
    parameter integer n_channels=16,
    parameter integer n_shift_bits=$clog2(n_channels)
) (
    // clock and reset
    input wire logic clk,
    input wire logic rst,

    // initial values for LFSRs used in PRBS
    // these have to be picked in a certain way
    // to ensure the right phase relationship
    input wire logic [(n_prbs-1):0] prbs_init_vals [n_channels],

    // recovered data from ADC, FFE, MLSD, etc.
    input wire logic [(n_channels-1):0] rx_bits,

    // checker mode:
    // 2'b00: RESET
    // 2'b01: ALIGN
    // 2'b11: TEST
    input wire logic [1:0] checker_mode,

    // outputs
    output reg [63:0] correct_bits,
    output reg [63:0] total_bits
);

    // TODO: consider using enum here
    localparam logic [1:0] RESET = 2'b00;
    localparam logic [1:0] ALIGN = 2'b01;
    localparam logic [1:0]  TEST = 2'b10;

    // control signals for the checker core
    logic prbs_rst, prbs_cke, prbs_match;
    logic [(n_shift_bits-1):0] rx_shift;

    // instantiate the core prbs checker
    prbs_checker_core #(
        parameter integer n_prbs=7,
        parameter integer n_channels=16,
        parameter integer n_shift_bits=$clog2(n_channels)
    ) prbs_checker_core_i (
        .clk(clk),
        .rst(prbs_rst),
        .prbs_cke(prbs_cke),
        .prbs_init_vals(prbs_init_vals),
        .rx_bits(rx_bits),
        .rx_shift(rx_shift),
        .match(prbs_match)
    );

    // check the RX data
    always @(posedge clk) begin
        if (checker_mode == RESET) begin
            prbs_rst <= 1;
            prbs_cke <= 0;
            rx_shift <= '1;
            correct_bits <= 0;
            total_bits <= 0;
        end else if (checker_mode == ALIGN) begin
            prbs_rst <= 0;
            if (prbs_match) begin
                prbs_cke <= 1;
                rx_shift <= rx_shift;
            end else begin
                if (rx_shift == 0) begin
                    prbs_cke <= 0;
                    rx_shift <= '1;
                end else begin
                    prbs_cke <= 1;
                    rx_shift <= rx_shift - 1;
                end
            end
            correct_bits <= 0;
            total_bits <= 0;
        end else begin
            prbs_rst <= 0;
            prbs_cke <= 1;
            rx_shift <= rx_shift;
            if (prbs_match) begin
                correct_bits <= correct_bits + 1;
            end else begin
                correct_bits <= correct_bits;
            end
            total_bits <= total_bits + 1;
        end
    end

endmodule
