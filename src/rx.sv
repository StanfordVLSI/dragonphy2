// dragon uses rx_cmp

`include "signals.sv"

module rx #(
    parameter integer n_del=3
) (
    `ANALOG_INPUT data_ana_i,
    output wire logic clk_o,
    output wire logic data_o
);

    // instantiate the clock
    clk_gen rx_clk_i (
        .clk_o(clk_o)
    );
    
    // instantiate the comparator
    logic cmp_o;
    rx_cmp rx_cmp_i (
        .in(data_ana_i),
        .out(cmp_o)
    );

    // sample comparator output
    logic [n_del-1:0] delay;
    always @(posedge clk_o) begin
        delay <= {delay[n_del-2:0], cmp_o};
    end
    assign data_o = ~delay[n_del-1];

endmodule
