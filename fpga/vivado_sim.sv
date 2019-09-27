module vivado_sim;
    logic ext_clk;
    top top_i(.ext_clk(ext_clk));
    always begin
        ext_clk = 1'b0;
        #(0.5/125e6*1s);
        ext_clk = 1'b1;
        #(0.5/125e6*1s);
    end
    initial begin
        force top_i.emu.rst = 1'b1;
        force top_i.tb_i.rst_user = 1'b1;
        #(3us);
        force top_i.emu.rst = 1'b0;
        #(3us);
        force top_i.tb_i.rst_user = 1'b0; 
    end
endmodule
