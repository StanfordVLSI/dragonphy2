# Load header
set SYNTH_HOME /sim/sjkim85/apr_flow_adc/butterphy_top/synthesis_dc/synth
set DESIGN_TARGET butterphy_top
set REPO_TOP /aha/sjkim85/verilog/ButterPHY


source $SYNTH_HOME/header.tcl

# memory library
lappend link_library [list analog_core.db]
lappend link_library [list ts1n16ffcllsblvtc1024x144m4sw_130a_ssgnp0p72v125c.db]
lappend target_library [list analog_core.db]
lappend target_library [list ts1n16ffcllsblvtc1024x144m4sw_130a_ssgnp0p72v125c.db]

# DUMP SVF file for primetime
set_svf ${SYNTH_RESULTS}/${DCRM_SVF_OUTPUT_FILE}

suppress_message [list VER-936]
set suppress_errors WL-40

#############################
# Read designs
#############################
# Analyze SystemVerilog files
set file_list [concat \
	[list const_pack.sv iotype.sv jtag_intf.sv jtag.sv adc_unfolding.sv  calib_hist_measure.sv  calib_sample_avg.sv oneshot_memory.sv sram_debug_intf.sv freq_divider.sv dcore_debug_intf.sv ti_adc_retimer.sv cdr_debug_intf.sv pi_filter.sv mm_avg_IIR.sv mm_cdr.sv mm_pd.sv pd_aux.sv acore_debug_intf.sv analog_core_stub.sv digital_core.sv butterphy_top.sv ] \
	[glob $REPO_TOP/src/digital_core/beh/output_buffer.sv] \
	[glob $REPO_TOP/src/digital_core/beh/input_buffer_inv.sv] \
	[glob $REPO_TOP/src/sram/net/sram.sv] \
	[glob $REPO_TOP/src/jtag/generate/*.*v] \
	[glob /cad/synopsys/syn/L-2016.03-SP5-5/dw/sim_ver/DW_tap.v] \
]
analyze -format sverilog $file_list



define_name_rules verilog -type net -allowed "a-z0-9_[]" -add_dummy_nets; # change to lower insentive names to pass LVS
report_name_rules verilog  

# Elaborate the design target: check verilog syntax here
elaborate $DESIGN_TARGET

change_names -rules verilog -hierarchy -verbose 

current_design $DESIGN_TARGET
# Uniquify forces to rename modules that have multiple instances. 
# As a results, every instance has a unique design (module) name
#uniquify -force
# Link the design: check references
link

# check design
check_design

#############################
# Setup constraints
#############################

source -echo -verbose $SYNTH_HOME/constraints_synth.tcl

##set_wire_load_selection_group NONE

#####################################
# Compile the design
####################################
set COMPILE_COMMAND "compile_ultra -no_autoungroup " ;#-gate_clock"
set ungroup_keep_original_design true
#set check_design_allow_multiply_driven_nets_by_inputs_and_outputs true

eval $COMPILE_COMMAND

define_name_rules verilog -type net -allowed "a-z0-9_[]" -add_dummy_nets; # change to lower insentive names to pass LVS
report_name_rules verilog  > ${SYNTH_REPORTS}/${DESIGN_TARGET}.name_rule
change_names -rules verilog -hierarchy -verbose > ${SYNTH_REPORTS}/${DESIGN_TARGET}.name_change
link


#################################################################################
# Generate Final Reports
#################################################################################
report_qor > ${SYNTH_REPORTS}/${DCRM_FINAL_QOR_REPORT}
report_timing -transition_time -nets -attributes -nosplit \
    > ${SYNTH_REPORTS}/${DCRM_FINAL_TIMING_REPORT}
report_timing -loops -transition_time -significant_digits 4 -attributes -nosplit \
    > ${SYNTH_REPORTS}/${DCRM_FINAL_TIMING_LOOP_REPORT}

report_timing -nworst 20 -significant_digits 4 -transition_time -nets -attributes -nosplit \
    > ${SYNTH_REPORTS}/${DCRM_FINAL_LONG_TIMING_REPORT}

report_area -nosplit > ${SYNTH_REPORTS}/${DCRM_FINAL_AREA_REPORT}
report_area -nosplit -hierarchy > ${SYNTH_REPORTS}/${DCRM_FINAL_AREA_HIER_REPORT}

report_constraints -all_violators -max_capacitance -max_fanout -max_transition \
    >  ${SYNTH_REPORTS}/$DESIGN_TARGET.mapped.con

# Use SAIF file for power analysis
saif_map -start
# read_saif -auto_map_names -input ${DESIGN_NAME}.saif -instance < DESIGN_INSTANCE > -verbose
#read_saif -auto_map_names -input ../rtl.saif -instance top/dut -verbose

#report_power -nosplit > ${SYNTH_REPORTS}/${DCRM_FINAL_POWER_REPORT}
report_clock_gating -nosplit > ${SYNTH_REPORTS}/${DCRM_FINAL_CLOCK_GATING_REPORT}
report_clock -nosplit > ${SYNTH_REPORTS}/$DESIGN_TARGET.mapped.clock


#################################################################################
# Write out Design
#################################################################################

# Write and close SVF file and make it available for immediate use
set_svf -off

write -format ddc -hierarchy -output ${SYNTH_RESULTS}/${DCRM_FINAL_DDC_OUTPUT_FILE}
write -format verilog -hierarchy -output ${SYNTH_RESULTS}/${DCRM_FINAL_VERILOG_OUTPUT_FILE}
write -format svsim -output ${SYNTH_RESULTS}/$DESIGN_TARGET.sv


#################################################################################
# Write out Design Data
#################################################################################

write_sdc -nosplit ${SYNTH_RESULTS}/${DCRM_FINAL_SDC_OUTPUT_FILE}

# If SAIF is used, write out SAIF name mapping file for PrimeTime-PX
# saif_map -type ptpx -write_map ${SYNTH_RESULTS}/${DESIGN_NAME}.mapped.SAIF.namemap

# comment this line if you want to stay in the shell at the end
exit

