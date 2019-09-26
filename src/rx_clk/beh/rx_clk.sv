module rx_clk #(
    parameter real t_per=1e-9,
    parameter real t_del=0
) (
    output var logic clk_o
);

    initial begin
        #(t_del*1s);
        forever begin
	    clk_o = 1'b0;
            #(0.5*t_per*1s);
	    clk_o = 1'b1;
	    #(0.5*t_per*1s);
        end
    end
    
endmodule
