module testbench;

    localparam integer width = 16;
    localparam integer depth = 8;
    localparam integer bitwidth=8;

    logic clk, rstb;

    logic [width*2-1:0] data_reg;
    logic [width*2-1:0] d_reg_arr;
    logic signed [1:0] arr [width-1:0];
    logic  [1+$clog2(width)+$clog2(depth)-1:0] inst_reg;
    logic exec = 0;

    logic signed [bitwidth-1:0] value;
    logic signed [bitwidth-1:0] read_reg;
    logic signed [bitwidth-1:0] weights [width-1:0][depth-1:0];

    logic en_wr;
    logic en_wr_in;

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

    arr2dregconv #(.width(width)) adregc_i (.arr(arr), .d_reg(d_reg_arr));

    weight_recorder #(.width(width), .depth(depth), .filename("out_weights.txt")) wr_i (
        .read_reg(read_reg),
        .d_idx(inst_reg[$clog2(depth)-1:0]),
        .w_idx(inst_reg[$clog2(depth)+$clog2(width)-1:$clog2(depth)]),
        .clk     (clk),
        .en      (en_wr)
    );

    weight_recorder #(.width(width), .depth(depth), .filename("in_weights.txt")) wr_in_i (
        .read_reg(value),
        .d_idx(inst_reg[$clog2(depth)-1:0]),
        .w_idx(inst_reg[$clog2(depth)+$clog2(width)-1:$clog2(depth)]),
        .clk     (clk),
        .en      (en_wr_in)
    );

    genvar gj;
    generate
    for(gj=0; gj<width; gj=gj+1) begin
        initial begin
            arr[gj] = 0;
        end
    end
    endgenerate

    initial begin
        integer ii, jj;
        rstb      = 0;
        data_reg  = 0;
        inst_reg  = 0; 
        @(posedge clk) rstb = 1;

        en_wr_in = 1;
        for(ii = 0; ii < width; ii = ii + 1) begin
            for(jj = 0; jj < depth; jj=jj+1) begin
                value = $signed($random%(2**bitwidth));
                load(jj, ii, value);
            end
        end
        en_wr_in = 0;

        en_wr = 1;
        for(ii = 0; ii < width; ii = ii + 1) begin
            for(jj = 0; jj < depth; jj=jj+1) begin
                read(jj, ii);
            end
        end
        en_wr = 0;
    end

    task increment(input logic [$clog2(depth)-1:0] d_idx, input logic [1:0] inc_arr [width-1:0]);
        int gi;
        @(posedge clk) inst_reg[$clog2(depth)+$clog2(width)] = 1;
        inst_reg[$clog2(depth)+$clog2(width)-1:$clog2(depth)] = 0;
        inst_reg[$clog2(depth)-1:0] = d_idx;
        for(gi=0; gi<width;gi=gi+1) begin
            arr[gi]      = inc_arr[gi];
        end
        @(posedge clk) data_reg = d_reg_arr;
        toggle_exec();
    endtask

    task read(input logic [$clog2(depth)-1:0] d_idx, logic [$clog2(width)-1:0] w_idx);
        @(posedge clk);
        inst_reg[$clog2(depth)+$clog2(width)-1:$clog2(depth)] = w_idx;
        inst_reg[$clog2(depth)-1:0] = d_idx;
    endtask

    task load(input logic [$clog2(depth)-1:0] d_idx, logic [$clog2(width)-1:0] w_idx, logic [bitwidth-1:0] value);
        inst_reg[$clog2(depth)+$clog2(width)] = 0;
        inst_reg[$clog2(depth)+$clog2(width)-1:$clog2(depth)] = w_idx;
        inst_reg[$clog2(depth)-1:0] = d_idx;
        data_reg[bitwidth-1:0] = value;
        toggle_exec();
    endtask

    task toggle_exec;
        @(posedge clk) exec=1;
        #0.5ns exec=0;
    endtask


endmodule : testbench

module arr2dregconv #(
    parameter integer width=16
)(
    input logic signed [1:0] arr [width-1:0],
    output logic [2*width-1:0] d_reg
);
    genvar gi;
    generate
        for(gi=0; gi<width; gi=gi+1) begin
            assign d_reg[2*gi+1:2*gi] = arr[gi];
        end
    endgenerate
endmodule 

module weight_recorder #(
    parameter filename = "values.txt",
    parameter integer width    = 16,
    parameter integer depth    = 6,
    parameter integer bitwidth  = 8
) ( 
    input logic [bitwidth-1:0] read_reg,
    input logic [$clog2(depth)-1:0] d_idx,
    input logic [$clog2(width)-1:0] w_idx,
    input wire logic clk,
    input wire logic en
);
    integer fid, ii;
    initial begin
        fid = $fopen(filename, "w");
        $display(filename);
    end

    always @(posedge clk) begin
        if (en == 'b1) begin
            $fwrite(fid, "%0d, %0d, %0d\n", d_idx, w_idx, read_reg);
        end
    end
endmodule



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
