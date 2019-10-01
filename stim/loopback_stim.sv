// dragon uses tb

module stim;

    tb tb_i();
    
    initial begin
        force tb_i.rst_user = 1'b1;
        #(20ns);
        force tb_i.rst_user = 1'b0; 
        #(2500ns);
        assert (tb_i.number >= 1000) else
            $error("Not enough successful bits.");
        $finish;
    end

endmodule
