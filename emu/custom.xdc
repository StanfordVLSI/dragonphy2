# Internally generated clocks
create_generated_clock -name emu_clk -source [get_pins clk_gen_i/clk_wiz_0_i/clk_out1] -divide_by 2 [get_pins fpga_top_i/gc_i/buf_emu_clk/I]
create_generated_clock -name clk_other_0 -source [get_pins clk_gen_i/clk_wiz_0_i/clk_out1] -divide_by 4 [get_pins fpga_top_i/gc_i/gen_other[0].buf_i/I]
create_generated_clock -name clk_other_1 -source [get_pins clk_gen_i/clk_wiz_0_i/clk_out1] -divide_by 4 [get_pins fpga_top_i/gc_i/gen_other[1].buf_i/I]
