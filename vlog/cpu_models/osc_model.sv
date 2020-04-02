`timescale 1s/1fs

module osc_model #(
    parameter real t_lo=0.5e-9,
    parameter real t_hi=0.5e-9,
    parameter real t_del=0.5e-9
) (
    output var logic clk_o=1'b0,
    // TODO: figure out a cleaner way to pass clk_o_val
    // (ideally it should not appear in this model at
    // all because it is only needed for FPGA emulation)
    output wire logic clk_o_val
);
    initial begin
	    // initial delay (can use to set phase shift)
        #(t_del*1s);
        // periodic oscillation
        forever begin
            clk_o = 1'b1;
            #(t_hi*1s);
	        clk_o = 1'b0;
            #(t_lo*1s);
        end
    end
endmodule
