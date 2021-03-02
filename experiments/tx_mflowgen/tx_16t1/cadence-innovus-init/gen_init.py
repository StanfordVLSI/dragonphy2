with open('innovus-foundation-flow/init.tcl', 'w') as f:
    f.write(f'''set init_layout_view ""
set init_abstract_name ""
set init_verilog "./inputs/design.v"
set init_mmmc_file "innovus-foundation-flow/view_definition.tcl"
set init_lef_file "inputs/adk/rtk-tech.lef inputs/adk/stdcells.lef inputs/adk/stdcells-pm.lef inputs/adk/stdcells-pm.lef inputs/adk/stdcells.lef inputs/adk/iocells.lef inputs/adk/sealring.lef inputs/adk/bumpcells.lef inputs/adk/rtk-tech.lef inputs/adk/icovl-cells.lef inputs/adk/dtcd-cells.lef inputs/adk/stdcells-lvt.lef inputs/adk/stdcells-ulvt.lef inputs/sram.lef inputs/sram_small.lef inputs/output_buffer.lef inputs/input_buffer.lef inputs/mdll_r1_top.lef inputs/analog_core.lef inputs/phase_interpolator.lef inputs/input_divider.lef inputs/termination.lef"
set init_top_cell "tx_top"
set init_gnd_net "AVSS CVSS DVSS"
set init_pwr_net "AVDD CVDD DVDD"''')
f.close()
