module chan #(
    parameter real t_del=12e-9
) (
    input wire logic data_i,
    output var logic data_o
);

    always @(data_i) begin
        data_o <= #(t_del*1s) data_i;
    end

endmodule
