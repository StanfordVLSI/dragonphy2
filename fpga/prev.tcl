# 200 MHz System Clock

set_property IOSTANDARD LVDS [get_ports SYSCLK_P]
set_property PACKAGE_PIN H9 [get_ports SYSCLK_P]
set_property PACKAGE_PIN G9 [get_ports SYSCLK_N]
set_property IOSTANDARD LVDS [get_ports SYSCLK_N]
create_clock -period 5.000 -name SYSCLK_P -waveform {0.000 2.500} -add [get_ports SYSCLK_P]

# Debug Hub Clock

set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
set_property C_CLK_INPUT_FREQ_HZ 100000000 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clkgen_i/clk_wiz_0_i/clk_out5]

# Status Outputs

# LED_0 (unused)
# set_property PACKAGE_PIN A17 [get_ports ???]
# set_property IOSTANDARD LVCMOS15 [get_ports ???]

# LED_LEFT
set_property PACKAGE_PIN Y21 [get_ports {run_state[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {run_state[2]}]

# LED_CENTER
set_property PACKAGE_PIN G2 [get_ports {run_state[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {run_state[1]}]

# LED_RIGHT
set_property PACKAGE_PIN W21 [get_ports {run_state[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {run_state[0]}]
