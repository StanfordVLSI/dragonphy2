// dragon uses rx_adc

`include "signals.sv"

module rx #(
    parameter integer n_del=3
) (
    `ANALOG_INPUT data_ana_i,
    output wire logic clk_o,
    output wire logic data_o
);

    // instantiate the clock
    osc_model rx_clk_i (
        .clk_o(clk_o)
    );
    
    // instantiate the ADC
    logic signed [7:0] adc_o;
    rx_adc rx_adc_i (
        .in(data_ana_i),
        .out(adc_o),
        .clk(clk_o)
    );

    // create digital comparator
    logic cmp_o;
    assign cmp_o = (adc_o > 0) ? 1'b1 : 1'b0;

    // sample comparator output
    logic [n_del-1:0] delay;
    always @(posedge clk_o) begin
        delay <= {delay[n_del-2:0], cmp_o};
    end
    assign data_o = delay[n_del-1];

endmodule
