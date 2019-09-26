module tx (
    input wire logic data_i,
    input wire logic clk_i,
    `ANALOG_OUTPUT data_ana_o
);

    always @(posedge clk_i) begin
        data_ana_o.value <= (data_i ? +1 : -1);
    end

endmodule
