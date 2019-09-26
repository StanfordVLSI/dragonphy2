module rx #(
    parameter real t_per=1e-9,
    parameter real t_del=0
) (
    interface data_ana_i,
    output var logic clk_o,
    output var logic data_o
);

    // instantiate the clock
    rx_clk rx_clk_i (
        .clk_o(clk_o)
    );
    
    // instantiate the comparator
    logic cmp_o;
    rx_cmp rx_cmp_i (
        .in(data_ana_i),
        .out(cmp_o)
    );

    // run the sampler
    always @(posedge clk_o) begin
        data_o <= cmp_o;
    end

endmodule
