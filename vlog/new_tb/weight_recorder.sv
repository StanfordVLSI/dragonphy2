module weight_recorder #(
    parameter filename = "values.txt",
    parameter integer width    = 16,
    parameter integer depth    = 6,
    parameter integer bitwidth  = 8
) ( 
    input logic signed [bitwidth-1:0] read_reg,
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