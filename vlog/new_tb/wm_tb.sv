module testbench;

    localparam integer width = 16;
    localparam integer depth = 8;
    localparam integer bitwidth=8;

    logic clk, rstb;

    logic [width*2-1:0] data_reg;
    logic  [1+$clog2(width)+$clog2(depth)-1:0] inst_reg;
    logic exec = 0;

    logic signed [bitwidth-1:0] read_reg;
    logic signed [bitwidth-1:0] weights [width-1:0][depth-1:0];

    clock #(.period(1ns)) clk_gen (.clk(clk));

    weight_manager #(.width(width), .depth(depth), .bitwidth(bitwidth)) wm_i (
        .data_reg(data_reg),
        .inst_reg(inst_reg),
        .exec_reg(exec),
        .clk(clk),
        .rstb(rstb),

        .read_reg(read_reg),
        .weights(weights)
    );


    initial begin
        rstb      = 0;
        #1ns rstb = 1;
        @(clk) inst_reg[7] = 1;
        inst_reg[6:3]   = 0;
        inst_reg[2:0]   = 4;
        data_reg[31:30] = 1;
        data_reg[29:28] = -1;
        data_reg[27:26] = 1;
        data_reg[25:0]  = 0;
        repeat (10) @(clk); 
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
