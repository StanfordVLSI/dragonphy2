module tx (
    input wire logic data_i,
    input wire logic clk_i,
    output var logic data_o
);

    always @(posedge clk_i) begin
        data_o <= data_i;
    end

endmodule
