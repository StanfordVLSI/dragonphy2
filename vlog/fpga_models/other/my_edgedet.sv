module my_edgedet #(
    parameter prev_init = 0
) (
    input wire logic val,
    input wire logic clk,
    input wire logic rst,
    output wire logic edge_p,
    output wire logic edge_n
);

    logic val_prev;
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            val_prev <= prev_init;
        end else begin
            val_prev <= val;
        end
    end

    assign edge_p = val & (~val_prev);
    assign edge_n = (~val) & val_prev;

endmodule