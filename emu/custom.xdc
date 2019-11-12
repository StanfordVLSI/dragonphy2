# Debug Hub Clock
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
set_property C_CLK_INPUT_FREQ_HZ 100000000 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_pins clk_gen_i/dbg_hub_clk]

# Internally generated clocks
create_generated_clock -name emu_clk -source [get_pins clk_gen_i/emu_clk] -divide_by 2 [get_pins fpga_top_i/gc_i/buf_emu_clk/I]
create_generated_clock -name clk_other_0 -source [get_pins clk_gen_i/emu_clk] -divide_by 4 [get_pins fpga_top_i/gc_i/gen_other[0].buf_i/I]
create_generated_clock -name clk_other_1 -source [get_pins clk_gen_i/emu_clk] -divide_by 4 [get_pins fpga_top_i/gc_i/gen_other[1].buf_i/I]
