module chan #(
    parameter real t_del=12e-9
) (
    interface data_ana_i,
    interface data_ana_o
);

    real value;
    assign data_ana_o.value = value;

    always @(data_ana_i.value) begin
        value <= #(t_del*1s) data_ana_i.value;
    end

endmodule
