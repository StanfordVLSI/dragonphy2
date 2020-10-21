`timescale 100ps/1ps   //  unit_time / time precision

module fppi (
    input reg clkin,
    output reg clk_Q,
    output reg clk_I,
    output reg clk_QB,
    output reg clk_IB
); 
// four phases phase interpolator
// always @(posedge clkin) begin
//     clk_Q <= clkin;
//     #0.625 clk_I = clk_Q;
//     #0.625 clk_QB = clk_I;
//     #0.625 clk_IB = clk_QB;
// end
initial begin
    
    clk_Q = 1'b0;
    clk_I = 1'b0;
    clk_QB = 1'b0;
    clk_IB = 1'b0;
    
end

    always@(posedge clkin) begin
        clk_Q = ~clk_Q;
        clk_QB = ~clk_Q;
    end
    always@(negedge clkin) begin
        clk_I = ~clk_I;
        clk_IB = ~clk_I;
    end

    // always clk_QB = ~clk_Q;
    // always clk_IB = ~clk_I;

endmodule