`timescale 1s/1fs

module osc_model #(
    parameter real t_lo=0.5e-9,
    parameter real t_hi=0.5e-9
) (
    output var logic clk_o
);
    initial begin
        forever begin
	        clk_o = 1'b0;
            #(t_lo*1s);
	        clk_o = 1'b1;
	        #(t_hi*1s);
        end
    end
endmodule
