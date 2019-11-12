module osc_model #(
    parameter real t_lo=1,
    parameter real t_hi=1
) (
    output var logic clk_o
);

    initial begin
        forever begin
	        clk_o = 1'b0;
            #(t_lo*1ns);
	        clk_o = 1'b1;
	        #(t_hi*1ns);
        end
    end
    
endmodule
