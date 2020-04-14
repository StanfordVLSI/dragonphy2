module testbench;

    logic signed [7:0] pd_out;
    logic clk_p;
    logic clk_n;
    logic clk;
    logic rstb = 1; 

    digital_pd #(.width(8)) dig_pd (
        .clk_p (clk_p),
        .clk_n (clk_n),

        .clk   (clk),
        .rstb  (rstb),

        .pd_out(pd_out)

        );

    clock #(.period(1000ps)) sys_clk_gen (.clk(clk));
    clock #(.delay(100ps), .period(100ns)) clk_p_gen (.clk(clk_p));
    clock #(.delay(5ns), .period(100ns))   clk_n_gen(.clk(clk_n));

    initial begin
        #500ps rstb = 0;
    end



endmodule : testbench

module clock #(
    parameter real delay=0ps,
    parameter real period=1000ps
) (
    output reg clk
);
    initial begin
        #delay clk = 0;
    end

    always
        #(period/2) clk = !clk;

endmodule : clock