# program device
set bit_file {build/project/project.runs/impl_1/top.bit}
set probe_file {build/project/project.runs/impl_1/top.ltx}

open_hw
connect_hw_server
open_hw_target

set hw_device [get_hw_devices *xc7*]
current_hw_device $hw_device
refresh_hw_device $hw_device

set_property PROGRAM.FILE $bit_file $hw_device
set_property PROBES.FILE $probe_file $hw_device
set_property FULL_PROBES.FILE $probe_file $hw_device

program_hw_devices $hw_device
refresh_hw_device $hw_device

# configure VIO for low latency
# since there is no refresh, writing the VIO requires commit_hw_vio 
# and reading the VIO requires refresh_hw_vio
set vio_0_i [get_hw_vios -of_objects $hw_device -filter {CELL_NAME=~"sim_ctrl_gen_i/vio_0_i"}]
set_property CORE_REFRESH_RATE_MS 0 $vio_0_i

# set aliases to VIO probes
set emu_rst [get_hw_probes "sim_ctrl_gen_i/emu_rst" -of_objects $vio_0_i]
set prbs_rst [get_hw_probes "sim_ctrl_gen_i/prbs_rst" -of_objects $vio_0_i]
set tm_stall [get_hw_probes "sim_ctrl_gen_i/tm_stall" -of_objects $vio_0_i]
set lb_mode [get_hw_probes "sim_ctrl_gen_i/lb_mode" -of_objects $vio_0_i]
set lb_latency [get_hw_probes "sim_ctrl_gen_i/lb_latency" -of_objects $vio_0_i]
set lb_correct_bits [get_hw_probes "sim_ctrl_gen_i/lb_correct_bits" -of_objects $vio_0_i]
set lb_total_bits [get_hw_probes "sim_ctrl_gen_i/lb_total_bits" -of_objects $vio_0_i]

# configure VIO radix
set_property OUTPUT_VALUE_RADIX UNSIGNED $emu_rst
set_property OUTPUT_VALUE_RADIX UNSIGNED $prbs_rst
set_property OUTPUT_VALUE_RADIX UNSIGNED $tm_stall
set_property OUTPUT_VALUE_RADIX UNSIGNED $lb_mode
set_property INPUT_VALUE_RADIX UNSIGNED $lb_latency
set_property INPUT_VALUE_RADIX UNSIGNED $lb_correct_bits
set_property INPUT_VALUE_RADIX UNSIGNED $lb_total_bits

# configure the ILA for low latency
# TODO: figure out why using the path to the ILA instance doesn't work...
set ila_0_i [get_hw_ilas -of_objects $hw_device]
set_property CORE_REFRESH_RATE_MS 0 $ila_0_i

# set aliases to ILA probes
set data_tx_i [get_hw_probes "trace_port_gen_i/data_tx_i" -of_objects $ila_0_i]
set data_rx_o [get_hw_probes "trace_port_gen_i/data_rx_o" -of_objects $ila_0_i]
set clk_tx_i [get_hw_probes "trace_port_gen_i/clk_tx_i" -of_objects $ila_0_i]
set clk_rx_o [get_hw_probes "trace_port_gen_i/clk_rx_o" -of_objects $ila_0_i]
set stall_set [get_hw_probes "trace_port_gen_i/stall_set" -of_objects $ila_0_i]
set emu_time_probe [get_hw_probes "trace_port_gen_i/emu_time_probe" -of_objects $ila_0_i]

# configure ILA radix
set_property DISPLAY_RADIX UNSIGNED $data_tx_i
set_property DISPLAY_RADIX UNSIGNED $data_rx_o
set_property DISPLAY_RADIX UNSIGNED $clk_tx_i
set_property DISPLAY_RADIX UNSIGNED $clk_rx_o
set_property DISPLAY_RADIX UNSIGNED $stall_set
set_property DISPLAY_RADIX UNSIGNED $emu_time_probe

# configure the ILA trigger condition
set_property CONTROL.TRIGGER_POSITION 0 $ila_0_i
set_property TRIGGER_COMPARE_VALUE eq1'bR $stall_set
