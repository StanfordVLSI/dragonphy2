# Load header
source $SYNTH_HOME/scripts/header.tcl

# DUMP SVF file for primetime
set_svf ${SYNTH_RESULTS}/${DCRM_SVF_OUTPUT_FILE}

suppress_message [list VER-936]
set suppress_errors WL-40



#############################
# Read designs
#############################

if { ${DESIGN_TARGET} == "gate_size_test" } {
#------------------------------------------------------------
# gate_size_test
#-----------------------------------------------------------
analyze -format sverilog [list ${STUBDIR}/inv_0_fixed.sv]
analyze -format sverilog [list ${STUBDIR}/inv_1_fixed.sv]
analyze -format sverilog [list ${STUBDIR}/inv_2_fixed.sv]
analyze -format sverilog [list ${STUBDIR}/inv_3_fixed.sv]
analyze -format sverilog [list ${STUBDIR}/inv_4_fixed.sv]
analyze -format sverilog [list ${STUBDIR}/inv_5_fixed.sv]
analyze -format sverilog [list ${STUBDIR}/n_or_fixed.sv]
analyze -format sverilog [list ${STUBDIR}/mux_fixed.sv]
analyze -format sverilog [list ${STUBDIR}/ff_cn_sn_rn_fixed.sv]
} else { 
#------------------------------------------------------------
# gates for V2T_buffer
#------------------------------------------------------------
analyze -format sverilog [list ${PNR_RESULTS}/gate_size_test/results/gate_size_test.pnr.v]
#------------------------------------------------------------
# Stochastic ADC
#------------------------------------------------------------
analyze -format sverilog [list ${RTLDIR}/inv.sv]
analyze -format sverilog [list ${RTLDIR}/n_and.sv]
analyze -format sverilog [list ${RTLDIR}/n_or.sv]
analyze -format sverilog [list ${RTLDIR}/x_or.sv]
analyze -format sverilog [list ${RTLDIR}/x_nor.sv]
analyze -format sverilog [list ${RTLDIR}/mux.sv]
analyze -format sverilog [list ${RTLDIR}/ff_c.sv]
analyze -format sverilog [list ${RTLDIR}/ff_c_rn.sv]
analyze -format sverilog [list ${RTLDIR}/ff_c_sn.sv]
analyze -format sverilog [list ${RTLDIR}/dcdl_fine.sv]
analyze -format sverilog [list ${RTLDIR}/dcdl_coarse.sv]
analyze -format sverilog [list ${RTLDIR}/arbiter.sv]
analyze -format sverilog [list ${RTLDIR}/TDC_delay_unit_PR.sv]
analyze -format sverilog [list ${RTLDIR}/phase_monitor_sub.sv]
#------------------------------------------------------------
analyze -format sverilog [list ${RTLDIR}/inv_chain.sv]
analyze -format sverilog [list ${STUBDIR}/SW.sv]
analyze -format sverilog [list ${STUBDIR}/MOMcap.sv]
analyze -format sverilog [list ${STUBDIR}/CS_cell.sv]
analyze -format sverilog [list ${STUBDIR}/CS_cell_dmm.sv]
analyze -format sverilog [list ${PNR_RESULTS}/V2T/results/V2T.pnr.v]
analyze -format sverilog [list ${RTLDIR}/V2T_clock_gen.sv]
analyze -format sverilog [list ${RTLDIR}/V2T_clock_gen_S2D.sv]
analyze -format sverilog [list ${RTLDIR}/V2T_buffer.sv]
analyze -format sverilog [list ${RTLDIR}/PFD.sv]
analyze -format sverilog [list ${RTLDIR}/bin2thm_5b.sv]
analyze -format sverilog [list ${RTLDIR}/TDC_delay_chain_PR.sv]
analyze -format sverilog [list ${RTLDIR}/wallace_adder.sv]
analyze -format sverilog [list ${RTLDIR}/phase_monitor.sv]
#------------------------------------------------------------
# Phase Interpolator
#------------------------------------------------------------
analyze -format sverilog [list ${RTLDIR}/del_PI.sv]
analyze -format sverilog [list ${RTLDIR}/phase_blender_1b.sv]
analyze -format sverilog [list ${RTLDIR}/inc_delay.sv]
analyze -format sverilog [list ${RTLDIR}/PI_delay_unit.sv]
analyze -format sverilog [list ${RTLDIR}/mux4.sv]
analyze -format sverilog [list ${RTLDIR}/phase_blender.sv]
###----------------------------------------------------------------------
analyze -format sverilog [list ${RTLDIR}/PI_delay_chain.sv]
analyze -format sverilog [list ${RTLDIR}/mux4_gf.sv]
analyze -format sverilog [list ${RTLDIR}/mux_network.sv]
analyze -format sverilog [list ${RTLDIR}/PI_local_encoder.sv]
analyze -format sverilog [list ${RTLDIR}/phase_monitor.sv]

#------------------------------------------------------------
# Analog Core
#------------------------------------------------------------
#analyze -format sverilog [list ${RTLDIR}/const_pack.sv]
#analyze -format sverilog [list ${RTLDIR}/iotype.sv]
#analyze -format sverilog [list ${RTLDIR}/acore_debug_intf.sv]
#analyze -format sverilog [list ${RTLDIR}/SW.sv]
##analyze -format sverilog [list /sim/sjkim85/apr_flow_adc/stochastic_adc_test/pnr/results/stochastic_adc_test.pnr.v]
#analyze -format sverilog [list /sim/sjkim85/apr_flow_adc/biasgen/pnr/results/biasgen.pnr.v]
#analyze -format sverilog [list /sim/sjkim85/apr_flow_adc/termination/netlist/termination.v]
#analyze -format sverilog [list /sim/sjkim85/apr_flow_adc/input_buffer/pnr/results/input_buffer.pnr.v]
#analyze -format sverilog [list ${RTLDIR}/snh.sv]
#analyze -format sverilog [list /aha/sjkim85/apr_flow/pnr/stochastic_adc_PR/results/stochastic_adc_PR.pnr.v]
#analyze -format sverilog [list /aha/sjkim85/apr_flow/pnr/phase_interpolator/results/phase_interpolator.pnr.v]
}


#------------------------------------------------------------
# Design Target
#------------------------------------------------------------
analyze -format sverilog [list ${RTLDIR}/${DESIGN_TARGET}.sv]

# Elaborate the design target: check verilog syntax here
elaborate $DESIGN_TARGET

current_design $DESIGN_TARGET
# Uniquify forces to rename modules that have multiple instances. 
# As a results, every instance has a unique design (module) name
#uniquify -force
# Link the design: check references
link

check_design

#DONT TOUCH
set_dont_touch [get_cells -hierarchical *dont_touch*]


foreach lib $mvt_target_libs {
  set_dont_use [file rootname [file tail $lib]]/*D0*
  set_dont_use [file rootname [file tail $lib]]/*SK*
}


#############################
# Setup constraints
#############################
if { ${NEED_CONSTRAINTS} == 1 } {
source -echo -verbose $SYNTH_HOME/scripts/constraints/${DESIGN_TARGET}_constraints.tcl
} else {
}

#set_dont_touch [get_cells *dont_touch*]
#set_wire_load_selection_group NONE

#####################################
# Compile the design
####################################
set COMPILE_COMMAND "compile_ultra -no_autoungroup" ;#-gate_clock"
set ungroup_keep_original_design true
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

