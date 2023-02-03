module sym_encoder #(
    parameter integer sym_bitwidth = 1,
    parameter logic [sym_bitwidth-1:0] sym_table [2**sym_bitwidth-1:0] = '{1'b1, 1'b0} 
)(
    input logic tx_clk,
    input logic rstb,

    input logic  [sym_bitwidth-1:0] tx_data ,
    output logic [sym_bitwidth-1:0] tx_sym
);


    assign tx_sym = sym_table[tx_data];


endmodule