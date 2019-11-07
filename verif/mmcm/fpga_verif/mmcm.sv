module mmcm #(
    parameter real freq=20e6
) (
    input wire logic ext_clk_p,
    input wire logic ext_clk_n,
    output var logic emu_clk_2x
);

    always begin
        emu_clk_2x = 0;
        #(0.5/freq*1s);
        emu_clk_2x = 1;
        #(0.5/freq*1s);
    end

endmodule

