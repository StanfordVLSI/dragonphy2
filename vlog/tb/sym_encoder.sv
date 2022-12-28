module sym_encoder #(
    parameter sym_bitwidth = 1
) (
    input logic tx_clk,
    input logic rstb,

    input logic tx_data,
    output logic [sym_bitwidth-1:0] tx_sym
);

    generate
        if(sym_bitwidth == 1) begin
            assign tx_sym = tx_data;
        end else begin
            logic [sym_bitwidth-2:0] ptr;
            logic [sym_bitwidth-1:0] stored_tx_sym;

            always_ff @(posedge tx_clk or negedge rstb) begin
                if(!rstb) begin
                    ptr <= 0;
                    stored_tx_sym <= 0;
                end else begin
                    stored_tx_sym[ptr] <= tx_data;
                    if (ptr == sym_bitwidth-1) begin
                        ptr <= 0;
                        tx_sym <= stored_tx_sym;
                    end else begin
                        ptr <= ptr + 1;
                    end
                end
            end
        end
    endgenerate

endmodule