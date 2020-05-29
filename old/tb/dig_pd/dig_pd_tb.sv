module testbench;

    logic signed [7:0] pd_out;
    logic clk_p;
    logic clk_n;
    logic clk;
    logic rstb = 0; 

    digital_pd #(.width(8)) dig_pd (
        .clk_p (clk_p),
        .clk_n (clk_n),

        .clk   (clk),
        .rstb  (rstb),

        .pd_out(pd_out)

        );

    clock #(.period(1ns)) sys_clk_gen (.clk(clk));
    clock #(.delay(164ns), .period(128ns)) clk_p_gen (.clk(clk_p));
    clock #(.delay(100ns), .period(128ns))   clk_n_gen(.clk(clk_n));

    initial begin
        #200ns rstb = 1;
    end



endmodule : testbench

module clock #(
    parameter real delay=0ps,
    parameter real period=10ns
) (
    output reg clk
);

    initial begin
        clk = 0;
        #delay
        forever begin #(period/2.0) clk = ~clk; end
    end

    

endmodule : clock
