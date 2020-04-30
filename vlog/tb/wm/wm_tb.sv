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

    clock #(.period(2ns)) clk_gen (.clk(clk));

    weight_manager #(.width(width), .depth(depth), .bitwidth(bitwidth)) wm_i (
        .data(data_reg),
        .inst(inst_reg),
        .exec(exec),
        .clk(clk),
        .rstb(rstb),

        .read_reg(read_reg),
        .weights(weights)
    );


    initial begin
        rstb      = 0;
        #1ns rstb = 1;
        @(posedge clk) inst_reg[7] = 1;
        inst_reg[6:3]   = 0;
        inst_reg[2:0]   = 4;
        data_reg[31:30] = 1;
        data_reg[29:28] = -1;
        data_reg[27:26] = 1;
        data_reg[25:0]  = 0;
        @(posedge clk) exec = 1;
        @(posedge clk) exec = 0;
        repeat (10) @(posedge clk);
        @(posedge clk) inst_reg[7] = 0;
        inst_reg[6:3] = 0;
        inst_reg[2:0] = 4;
        data_reg[7:0] = -128;
        @(posedge clk) exec = 1; @(clk);
        @(posedge clk) exec = 0;
        repeat (2) @(posedge clk);
        @(posedge clk) inst_reg[7] = 1;
        inst_reg[6:3] = 0;
        inst_reg[2:0] = 4;
        data_reg[1:0] = 1;
        data_reg[31:2] = 0; 
        @(posedge clk) exec = 1; @(clk);
        @(posedge clk) exec = 0;
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
