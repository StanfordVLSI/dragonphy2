module test; 

    logic clk;
    logic signed [8:0] value;
    logic [17:0] sqr_value;
    logic [17:0] act_sqr_value;


    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    fast_square fs_i (
        .a(value),
        .sqr_a(sqr_value)
    );

    initial begin
        for(value = -256; value < 255; value = value + 1) begin
            @(posedge clk);
            act_sqr_value = value*value;
            $display("value = %d, sqr_value = %d , act_sqr_value = %d ", value, sqr_value, act_sqr_value);
            $display("difference = %d", sqr_value-act_sqr_value);
        end
        $finish;
    end

endmodule
