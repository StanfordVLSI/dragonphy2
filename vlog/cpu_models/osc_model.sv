`timescale 1s/1fs
`include "signals.sv"

module osc_model #(
    parameter real t_lo=0.5e-9,
    parameter real t_hi=0.5e-9,
    parameter real t_del=0.5e-9
) (
    `CLOCK_OUTPUT clk_o
);
    logic clk_state = 0;
    assign clk_o.clock = clk_state;

    initial begin
	    // initial delay (can use to set phase shift)
        #(t_del*1s);
        // periodic oscillation
        forever begin
            clk_state = 1'b1;
            #(t_hi*1s);
	        clk_state = 1'b0;
            #(t_lo*1s);
        end
    end
endmodule
