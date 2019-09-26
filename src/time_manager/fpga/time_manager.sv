module time_manager (
    input wire logic signed [31:0] rx_dt,
    input wire logic signed [31:0] tx_dt,
    output wire logic signed [31:0] emu_dt
);

    assign emu_dt = rx_dt < tx_dt ? rx_dt : tx_dt;

endmodule
