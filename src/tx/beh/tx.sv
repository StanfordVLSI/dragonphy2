module tx (
    input wire logic data_i,
    input wire logic clk_i,
    `ANALOG_OUTPUT data_ana_o
);

    real value;
    assign data_ana_o.value = value;
    
    always @(posedge clk_i) begin
        value <= (data_i ? +1.0 : -1.0);
    end

endmodule
