module rx #(
    parameter real t_per=1e-9,
    parameter real t_del=0
) (
    input wire logic data_i,
    output var logic clk_o,
    output var logic data_o
);

    // run the clock
    initial begin
        #(t_del*1s);
        forever begin
	    clk_o = 1'b0;
            #(0.5*t_per*1s);
	    clk_o = 1'b1;
	    #(0.5*t_per*1s);
        end
    end
    
    // run the sampler
    always @(posedge clk_o) begin
        data_o <= data_i;
    end

endmodule
