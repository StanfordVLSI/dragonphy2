module prbs21 (
    input wire logic clk_i,
    output var logic out_o
);

    always @(posedge clk_i) begin
        out_o <= $urandom % 2;
    end

endmodule
