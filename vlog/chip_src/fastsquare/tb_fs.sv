module tb_fs; 

    logic clk;
    logic signed [8:0] value;
    logic [17:0] sqr_value;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    fast_square fs_i (
        .a(value),
        .sqr_a(sqr_value)
    );

    initial begin
        for(value = 0; value < 256; value = value + 1) begin
            @(posedge clk);
            $display("value = %d, sqr_value = %d", value, sqr_value);
        end
    end

endmodule