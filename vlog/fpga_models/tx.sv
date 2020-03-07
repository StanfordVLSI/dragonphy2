`include "svreal.sv"
`include "signals.sv"

module tx #(
    parameter real v_lo=-1.0,
    parameter real v_hi=+1.0
) (
    input wire logic data_i,
    input wire logic clk_i,
    `ANALOG_OUTPUT data_ana_o
);
    generate
        // import impulse response
        import impulse_pack::*;
    
        // determine max(abs(v_lo), abs(v_hi))
        localparam real v_range = `MAX_MATH(`ABS_MATH(v_lo), `ABS_MATH(v_hi));

        // remember past inputs
        logic [(impulse_length-1):0] mem;
        always @(posedge clk_i) begin
            mem <= (mem << 1) | data_i;
        end
            
        // mux values depending on data sign
        localparam integer sig_w = `ANALOG_WIDTH;
        localparam integer sig_e = `ANALOG_EXPONENT;
        logic signed [(sig_w-1):0] mux_o [impulse_length];
        for (genvar i=0; i<impulse_length; i=i+1) begin
            assign mux_o[i] = mem[i] ? `FLOAT_TO_FIXED(impulse_values[i]*v_hi, sig_e) : `FLOAT_TO_FIXED(impulse_values[i]*v_lo, sig_e);
        end

        // sum values together
        logic signed [(sig_w-1):0] sum_o[impulse_length+1];
        assign sum_o[0] = 'd0;
        for (genvar i=0; i<impulse_length; i=i+1) begin
            assign sum_o[i+1] = sum_o[i] + mux_o[i];
        end

        // assign to output
        assign data_ana_o.value = sum_o[impulse_length];
    endgenerate
endmodule
