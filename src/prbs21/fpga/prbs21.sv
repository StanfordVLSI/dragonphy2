// modified from: https://github.com/StanfordVLSI/DaVE/blob/master/mLingua/samples/misc/prbs21.v

`include "signals.sv"

module prbs21 (
    output wire logic out_o,
    input wire logic clk_i,
    input wire logic rst_i
);

    logic [20:0] data;    
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            data <= '1; // i.e., assign to all ones
        end else begin
            data <= {data[19:0], data[20] ^ data[1]};
        end
    end    
    assign out_o = data[6];

endmodule
