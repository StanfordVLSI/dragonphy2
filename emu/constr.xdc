# External clock

# ZC702: Differential 200 MHz clock
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVDS_25 } [get_ports ext_clk_p]
set_property -dict { PACKAGE_PIN C19 IOSTANDARD LVDS_25 } [get_ports ext_clk_n]
create_clock -period 5.000 -name ext_clk_p -waveform {0.000 2.500} -add [get_ports ext_clk_p]

# PYNQ: Singled-ended 125 MHz clock
# set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports { ext_clk }];
# create_clock -add -name ext_clk -period 8.000 -waveform {0.000 4.000} [get_ports { ext_clk }];

# Debug Hub Clock
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
set_property C_CLK_INPUT_FREQ_HZ 100000000 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_pins mmcm_i/wiz_i/clk_out2]

# Internally generated clocks
create_generated_clock -name emu_clk -source [get_pins mmcm_i/wiz_i/clk_out1] -divide_by 2 [get_pins gc_i/buf_emu_clk/I]
create_generated_clock -name clk_other_0 -source [get_pins mmcm_i/wiz_i/clk_out1] -divide_by 4 [get_pins gc_i/gen_other[0].buf_i/I]
create_generated_clock -name clk_other_1 -source [get_pins mmcm_i/wiz_i/clk_out1] -divide_by 4 [get_pins gc_i/gen_other[1].buf_i/I]
