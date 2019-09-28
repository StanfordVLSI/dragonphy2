# Create the Vivado project
create_project -force project . -part "xc7z020clg400-1"

# Add source files
add_files [list \
	"../src/signals/fpga/signals.sv" \
	"../stim/fpga_stim.sv" \
	"../verif/loopback/all/loopback.sv" \
	"../verif/tx/all/tx.sv" \
	"../verif/clk_gen/fpga/clk_gen.sv" \
	"../verif/prbs21/all/prbs21.sv" \
	"../verif/chan/all/chan.sv" \
	"../verif/gen_emu_clks/all/gen_emu_clks.sv" \
	"../verif/mmcm/fpga/mmcm.sv" \
	"../verif/time_manager/all/time_manager.sv" \
	"../verif/vio/all/vio.sv" \
	"../src/rx_cmp/all/rx_cmp.sv" \
	"../src/rx/all/rx.sv" \
	"../verif/tb/all/tb.sv" \
	"../verif/fpga_top/all/fpga_top.sv" \
]
set_property file_type "Verilog Header" [get_files "../src/signals/fpga/signals.sv"]

# Add clock constraints
add_files -fileset constrs_1 [glob "../fpga/constr.xdc"]

# Set the top-level module
set_property -name top -value fpga_top -objects [current_fileset]

# Instantiate the clock wizard
create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_0
set_property -dict [list \
    CONFIG.PRIM_IN_FREQ 125.0 \
    CONFIG.NUM_OUT_CLKS 2 \
    CONFIG.CLKOUT1_USED true \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 20.0 \
    CONFIG.CLKOUT2_USED true \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ 100.0 \
] [get_ips clk_wiz_0]

# Create the VIO
create_ip -name vio -vendor xilinx.com -library ip -module_name vio_0
set_property -dict [list \
    CONFIG.C_NUM_PROBE_IN       1 \
    CONFIG.C_NUM_PROBE_OUT      2 \
    CONFIG.C_PROBE_IN0_WIDTH    64 \
    CONFIG.C_PROBE_OUT0_WIDTH 1 \
    CONFIG.C_PROBE_OUT0_INIT_VAL 0x1 \
    CONFIG.C_PROBE_OUT1_WIDTH 1 \
    CONFIG.C_PROBE_OUT1_INIT_VAL 0x1 \
] [get_ips vio_0]

# Generate IP targets
# generate_target all [get_ips]

# Run synthesis, PnR, and generate the bitstream
# launch_runs impl_1 -to_step write_bitstream -jobs 2
# wait_on_run impl_1
