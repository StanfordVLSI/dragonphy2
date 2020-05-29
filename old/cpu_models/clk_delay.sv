`timescale 1s/1fs

module clk_delay #(
    parameter n_bits=8,
    parameter t_per=1e-9
) (
    input wire logic [(n_bits-1):0] code,
    input wire logic clk_i,
    input wire logic clk_i_val,
    output var logic clk_o=1'b0,
    output wire logic clk_o_val
);
    always @(clk_i) begin
        clk_o <= #((code/(2.0**n_bits))*t_per*1s) clk_i;
    end
endmodule
