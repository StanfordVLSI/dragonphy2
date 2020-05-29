module prbs_generator #(
    parameter integer n_prbs=7
) (
    input wire logic clk,
    input wire logic rst,
    input wire logic cke,
    input wire logic [(n_prbs-1):0] init_val,
    output wire logic out
);

    // internal variables
    logic [(n_prbs-1):0] data;

    // Set PRBS polynomial
    // ref: https://www.xilinx.com/support/documentation/application_notes/xapp884_PRBS_GeneratorChecker.pdf
    logic next_bit;
    generate
        if (n_prbs == 7) begin
            assign next_bit = data[6] ^ data[5];
        end else if (n_prbs == 9) begin
            assign next_bit = data[8] ^ data[4];
        end else if (n_prbs == 11) begin
            assign next_bit = data[10] ^ data[8];
        end else if (n_prbs == 15) begin
            assign next_bit = data[14] ^ data[13];
        end else if (n_prbs == 17) begin
            assign next_bit = data[16] ^ data[13];
        end else if (n_prbs == 20) begin
            assign next_bit = data[19] ^ data[2];
        end else if (n_prbs == 23) begin
            assign next_bit = data[22] ^ data[17];
        end else if (n_prbs == 29) begin
            assign next_bit = data[28] ^ data[26];
        end else if (n_prbs == 31) begin
            assign next_bit = data[30] ^ data[27];
        end else begin
            // synopsys translate_off
            initial begin
                $error("Invalid value for n_prbs: %0d", n_prbs);
            end
            // synopsys translate_on
        end
    endgenerate

    // shift previous data and append the new bit
    logic [(n_prbs-1):0] next_data;
    assign next_data = {data[(n_prbs-2):0], next_bit};

    // state update
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            data <= init_val;
        end else if (cke == 1'b1) begin
            data <= next_data;
        end else begin
            data <= data;
        end
    end

    // output assignment
    assign out = data[n_prbs-1];

endmodule
