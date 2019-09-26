module clk_gen #(
    parameter real t_per=2e-9
) (
    output var logic clk_o
);

    initial begin
        forever begin
	        clk_o = 1'b0;
            #(0.5*t_per*1s);
	        clk_o = 1'b1;
	        #(0.5*t_per*1s);
        end
    end
    
endmodule
