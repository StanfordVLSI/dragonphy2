`include "signals.sv"

module rx_adc #(
    parameter real vp=+1.0,
    parameter real vn=-1.0,
    parameter integer n=8
) (
    `ANALOG_INPUT in,
    output var logic signed [(n-1):0] out,
    input wire logic clk,
    input wire logic rst
);
    integer code;
    always @(posedge clk) begin
        // calculate output code
        if (rst == 1'b1) begin
            code = 0;
        end else begin
            // request update on the input signal
            in.update();

            // convert input to code mapping [vn, vp] to [0, ((1<<n)-1)]
            code = integer'(((2.0**n)-1)*(in.value-vn)/(vp-vn));

            // clamp code to [0, ((1<<n)-1)]
            if (code < 0) begin
                code = 0;
            end
            if (code > ((1<<n)-1)) begin
                code = (1<<n)-1;
            end

            // shift output to range -(1<<(n-1)), +(1<<(n-1)) - 1
            code = code - (1<<(n-1));
        end

        // assign code to output
        out <= code;
    end
endmodule
