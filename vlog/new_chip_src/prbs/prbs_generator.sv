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

    // TODO: update equation for newbit based on n_prbs
    // this could be done with a generate statement
    logic next_bit;
    assign next_bit = data[6] ^ data[5];

    // shift previous data and append the new bit
    logic [(n_prbs-1):0] next_data;
    assign next_data = {data[(n_prbs-1):0], next_data};

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
