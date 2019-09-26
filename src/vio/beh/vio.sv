module vio (
    output var logic emu_rst,
    input wire logic [63:0] number,
    input wire logic clk
);

    // generate emu reset
    initial begin
        emu_rst = 1;
        #(100ns);
        emu_rst = 0;
    end
    
    // check number of bits
    initial begin
        #(2500ns);
        assert (number >= 500) else
            $error("Not enough successful bits.");
        $finish;
    end

endmodule
