module mmcm (
    input wire logic ext_clk,
    output var logic emu_clk_2x
);

    always begin
        emu_clk_2x = 0;
        #(25ns);
        emu_clk_2x = 1;
        #(25ns);
    end

endmodule

