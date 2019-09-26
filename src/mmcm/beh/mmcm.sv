module mmcm (
    output var logic emu_clk_2x
);

    always begin
        emu_clk_2x = 0;
        #(0.5ns);
        emu_clk_2x = 1;
        #(0.5ns);
    end

endmodule

