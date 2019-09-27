# Create the Vivado project

create_project -force project ../build/project -part xc7z045ffg900-2

# Add source files

add_files [glob ../build/*.sv]
add_files [glob ../fpga/*.sv]
add_files [glob ../shared/*.sv]
set_property file_type {Verilog Header} [get_files /home/sgherbst/Code/dragonphy/src/signals/fpga/signals.sv]

# Add clock constraints

add_files -fileset constrs_1 "../fpga/constr.xdc"

# Set the top-level module

set_property -name top -value dut -objects [current_fileset]

# Instantiate the clock wizard

create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_0

set_property -dict [list \
    CONFIG.PRIM_SOURCE Differential_clock_capable_pin \
    CONFIG.PRIM_IN_FREQ 200.0 \
    CONFIG.NUM_OUT_CLKS 5 \
    CONFIG.CLKOUT1_USED true \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 30.0 \
    CONFIG.CLKOUT2_USED true \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ 30.0 \
    CONFIG.CLKOUT2_DRIVES BUFGCE \
    CONFIG.CLKOUT3_USED true \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ 30.0 \
    CONFIG.CLKOUT3_DRIVES BUFGCE \
    CONFIG.CLKOUT4_USED true \
    CONFIG.CLKOUT4_REQUESTED_OUT_FREQ 30.0 \
    CONFIG.CLKOUT4_DRIVES BUFGCE \
    CONFIG.CLKOUT5_USED true \
    CONFIG.CLKOUT5_REQUESTED_OUT_FREQ 100.0 \
] [get_ips clk_wiz_0]

# Create the VIO

create_ip -name vio -vendor xilinx.com -library ip -module_name vio_0

set_property -dict [list            \
    CONFIG.C_NUM_PROBE_IN       3   \
    CONFIG.C_NUM_PROBE_OUT      11  \
    \
    CONFIG.C_PROBE_IN0_WIDTH    32  \
    CONFIG.C_PROBE_IN1_WIDTH    32  \
    CONFIG.C_PROBE_IN2_WIDTH    32  \
    \
    CONFIG.C_PROBE_OUT0_WIDTH 1 \
    CONFIG.C_PROBE_OUT0_INIT_VAL 0x1 \
    \
    CONFIG.C_PROBE_OUT1_WIDTH 4 \
    CONFIG.C_PROBE_OUT1_INIT_VAL 0x4 \
    \
    CONFIG.C_PROBE_OUT2_WIDTH 4 \
    CONFIG.C_PROBE_OUT2_INIT_VAL 0x4 \
    \
    CONFIG.C_PROBE_OUT3_WIDTH 14 \
    CONFIG.C_PROBE_OUT3_INIT_VAL 0x2000 \
    \
    CONFIG.C_PROBE_OUT4_WIDTH 14 \
    CONFIG.C_PROBE_OUT4_INIT_VAL 0x100 \
    \
    CONFIG.C_PROBE_OUT5_WIDTH 14 \
    CONFIG.C_PROBE_OUT5_INIT_VAL 0x1 \
    \
    CONFIG.C_PROBE_OUT6_WIDTH 41 \
    CONFIG.C_PROBE_OUT6_INIT_VAL 0x38D7320 \
    \
    CONFIG.C_PROBE_OUT7_WIDTH 41 \
    CONFIG.C_PROBE_OUT7_INIT_VAL 0x89705F4 \
    \
    CONFIG.C_PROBE_OUT8_WIDTH 8 \
    CONFIG.C_PROBE_OUT8_INIT_VAL 0x23 \
    \
    CONFIG.C_PROBE_OUT9_WIDTH 10 \
    CONFIG.C_PROBE_OUT9_INIT_VAL 0x2BC \
    \
    CONFIG.C_PROBE_OUT10_WIDTH 10 \
    CONFIG.C_PROBE_OUT10_INIT_VAL 0x2BC \
] [get_ips vio_0]

# Create ILA 0

create_ip -name ila -vendor xilinx.com -library ip -module_name ila_0

set_property -dict [list \
    CONFIG.C_NUM_OF_PROBES 5 \
    CONFIG.C_DATA_DEPTH 1024 \
    CONFIG.C_PROBE0_WIDTH 1 \
    CONFIG.C_PROBE1_WIDTH 41 \
    CONFIG.C_PROBE2_WIDTH 1 \
    CONFIG.C_PROBE3_WIDTH 16 \
    CONFIG.C_PROBE4_WIDTH 3 \
] [get_ips ila_0]

# Create ILA 1

create_ip -name ila -vendor xilinx.com -library ip -module_name ila_1

set_property -dict [list \
    CONFIG.C_NUM_OF_PROBES 8 \
    CONFIG.C_DATA_DEPTH 16384 \
    CONFIG.C_PROBE0_WIDTH 1 \
    CONFIG.C_PROBE1_WIDTH 41 \
    CONFIG.C_PROBE2_WIDTH 1 \
    CONFIG.C_PROBE3_WIDTH 23 \
    CONFIG.C_PROBE4_WIDTH 16 \
    CONFIG.C_PROBE5_WIDTH 23 \
    CONFIG.C_PROBE6_WIDTH 14 \
    CONFIG.C_PROBE7_WIDTH 3 \
] [get_ips ila_1]

# Create ILA 2

create_ip -name ila -vendor xilinx.com -library ip -module_name ila_2

set_property -dict [list \
    CONFIG.C_NUM_OF_PROBES 4 \
    CONFIG.C_DATA_DEPTH 1024 \
    CONFIG.C_PROBE0_WIDTH 1 \
    CONFIG.C_PROBE1_WIDTH 41 \
    CONFIG.C_PROBE2_WIDTH 23 \
    CONFIG.C_PROBE3_WIDTH 3 \
] [get_ips ila_2]

# Generate IP targets

generate_target all [get_ips]

# Run synthesis, PnR, and generate the bitstream

launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1
