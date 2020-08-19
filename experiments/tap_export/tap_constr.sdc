################
# JTAG interface
################

# These numbers come from looking at datasheets for JTAG cables
# https://www.analog.com/media/en/technical-documentation/application-notes/ee-68.pdf
# https://www2.lauterbach.com/pdf/arm_app_jtag.pdf

# TCK clock signal: 20 MHz max
create_clock -name clk_jtag -period 50.0 [get_ports tck]

# timing constraints for TDI (changes 0 to 5 ns from falling edge of JTAG clock)
set_input_delay -clock clk_jtag -max 0.5 -clock_fall [get_ports tdi]
set_input_delay -clock clk_jtag -min 0.0 -clock_fall [get_ports tdi]

# timing constraints for TMS (changes 0 to 5 ns from falling edge of JTAG clock)
set_input_delay -clock clk_jtag -max 5.0 -clock_fall [get_ports tms]
set_input_delay -clock clk_jtag -min 0.0 -clock_fall [get_ports tms]

# timing constraints for TDO (setup time 12.5 ns, hold time 0.0)
# TDO changes on the falling edge of TCK but is sampled on the rising edge
set_output_delay -clock clk_jtag -max 12.5 [get_ports tdo]
set_output_delay -clock clk_jtag -min 0.0 [get_ports tdo]