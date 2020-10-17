//This is a half-rate 16 to 4 mux top
`timescale 100ps/1ps   //  Unit_time / Time precision
module hr_16t4_mux_top (  // The output data rate should be input clock frequency times two.
    input wire clk_hr,     // Half rate clock input
    input wire [15:0] din,  // Sixteen-bit input data
    input wire rst,
    output wire [3:0] dout, // Four-bit output data
    output wire clk_b2 // Divided clk output to drive prbs_gen
);

genvar i;
generate  // Instantiate 4 hr_4t1_mux_top to form 16:4 mux
    for (i=1; i<5; i=i+1) begin
        hr_4t1_mux_top mux_4t1 (
            .clk_b(clk_hr),
            .din(din[3*(i+1):3*i]),  // Map 16 bits input to 4 half-rate 4 to 1 mux
            .dout(dout[i-1]),
            .clk_half(clk_b2)  // Divide-by-two clock for prbs generator
        );
    end
endgenerate

// Clock divider, divide-by-two
div_b2 clk_div (.clkin(clk_hr), .rst(rst), .clkout(clk_b2));

endmodule