module mux_dff(
    input wire logic sel,
    input wire logic in,
    input wire logic clk,
    input wire logic rstb,
    output var logic out
);
    // internal mux
    logic mux_o;
    assign mux_o = (sel == 1'b0) ? out : in;

    // DFF
    always @(posedge clk or negedge rstb) begin
        if (rstb == 1'b0) begin
            out <= 1'b0;
        end else begin
            out <= mux_o;
        end
    end
endmodule