module mmcm #(
    parameter real freq=20e6
) (
    `ifdef anasymod_diff_clk
        input wire logic clk_in1_p,
        input wire logic clk_in1_n,
    `else
        input wire logic clk_in1,
    `endif
    output var logic emu_clk_2x
);

    always begin
        emu_clk_2x = 0;
        #(0.5/freq*1s);
        emu_clk_2x = 1;
        #(0.5/freq*1s);
    end

endmodule

