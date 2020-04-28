# Load header
source $SYNTH_HOME/scripts/header.tcl

# DUMP SVF file for primetime
set_svf ${SYNTH_RESULTS}/${DCRM_SVF_OUTPUT_FILE}

suppress_message [list VER-936]
set suppress_errors WL-40

#############################
# Read designs
#############################

## TODO ---------------------------------------------------------------
analyze -format sverilog [list ${mappedDIR}/mux_fixed.mapped.v]
analyze -format sverilog [list ${mappedDIR}/mux4_fixed.mapped.v]
analyze -format sverilog [list ${mappedDIR}/inv_bld_1_fixed.mapped.v]
analyze -format sverilog [list ${mappedDIR}/inv_bld_2_fixed.mapped.v]
analyze -format sverilog [list ${mappedDIR}/inv_bld_3_fixed.mapped.v]
analyze -format sverilog [list ${mappedDIR}/mux_bld_fixed.mapped.v]
#analyze -format sverilog [list ${mappedDIR}/n_and4.sv]

## --------------------------------------------------------------------

if { ${DESIGN_TARGET} == "gate_size_test" } {
analyze -format sverilog [list ${RTLDIR}/inv.sv]
analyze -format sverilog [list ${RTLDIR}/inv_0_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/inv_1_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/inv_2_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/inv_3_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/inv_4_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/inv_5_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/inv_arb_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/inv_PI_1_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/inv_PI_2_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/del_PI.sv]
analyze -format sverilog [list ${RTLDIR}/tri_buff_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/n_or_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/n_and_arb_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/ff_cn_sn_rn_fixed.sv]
#analyze -format sverilog [list ${RTLDIR}/mux_fixed.sv]
#analyze -format sverilog [list ${RTLDIR}/mux4_fixed.sv]
} else {
#------------------------------------------------------------
analyze -format sverilog [list ${RTLDIR}/tiel.sv]
analyze -format sverilog [list ${RTLDIR}/inv.sv]
analyze -format sverilog [list ${RTLDIR}/a_nd.sv]
analyze -format sverilog [list ${RTLDIR}/n_and.sv]
analyze -format sverilog [list ${RTLDIR}/n_and4.sv]
analyze -format sverilog [list ${RTLDIR}/n_or.sv]
analyze -format sverilog [list ${RTLDIR}/x_or.sv]
analyze -format sverilog [list ${RTLDIR}/x_nor.sv]
analyze -format sverilog [list ${RTLDIR}/mux.sv]
analyze -format sverilog [list ${RTLDIR}/ff_c.sv]
analyze -format sverilog [list ${RTLDIR}/ff_c_rn.sv]
analyze -format sverilog [list ${RTLDIR}/ff_c_sn.sv]
analyze -format sverilog [list ${RTLDIR}/inv_chain.sv]
analyze -format sverilog [list ${RTLDIR}/arbiter.sv]
analyze -format sverilog [list ${RTLDIR}/dcdl_fine.sv]
analyze -format sverilog [list ${RTLDIR}/phase_monitor_sub.sv]
analyze -format sverilog [list ${RTLDIR}/phase_monitor.sv]
analyze -format sverilog [list ${RTLDIR}/bin2thm.sv]
analyze -format sverilog [list ${PNR_RESULTS}/gate_size_test/results/gate_size_test.pnr.v]
#------------------------------------------------------------
switch ${DESIGN_TARGET} {
"stochastic_adc_PR" {
#analyze -format sverilog [list ${RTLDIR}/iotype.sv]
analyze -format sverilog [list ${PNR_RESULTS}/V2T/results/V2T.pnr.v]
analyze -format sverilog [list ${RTLDIR}/V2T_clock_gen_S2D.sv]
analyze -format sverilog [list ${RTLDIR}/V2T_buffer.sv]
analyze -format sverilog [list ${RTLDIR}/V2T_clock_gen.sv]
analyze -format sverilog [list ${RTLDIR}/PFD.sv]
analyze -format sverilog [list ${RTLDIR}/dcdl_coarse.sv]
analyze -format sverilog [list ${RTLDIR}/TDC_delay_unit_PR.sv]
analyze -format sverilog [list ${RTLDIR}/TDC_delay_chain_PR.sv]
analyze -format sverilog [list ${RTLDIR}/wallace_adder.sv]
}
"phase_interpolator" {
analyze -format sverilog [list ${PNR_RESULTS}/PI_delay_unit/results/PI_delay_unit.pnr.v]
analyze -format sverilog [list ${RTLDIR}/PI_delay_chain.sv]
analyze -format sverilog [list ${RTLDIR}/mux4_gf.sv]
analyze -format sverilog [list ${RTLDIR}/mux_network.sv]
analyze -format sverilog [list ${PNR_RESULTS}/phase_blender/results/phase_blender.pnr.v]
analyze -format sverilog [list ${RTLDIR}/PI_local_encoder.sv]
}
"analog_core" {
analyze -format sverilog [list ${GITDIR}/vlog/new_pack/const_pack.sv]
#analyze -format sverilog [list ${RTLDIR}/iotype.sv]
analyze -format sverilog [list ${RTLDIR}/acore_debug_intf.sv]
analyze -format sverilog [list ${RTLDIR}/snh.sv]
analyze -format sverilog [list ${STUBDIR}/SW.sv]
analyze -format sverilog [list ${STUBDIR}/termination.sv]
analyze -format sverilog [list ${PNR_RESULTS}/stochastic_adc_PR/results/stochastic_adc_PR.pnr.v]
analyze -format sverilog [list ${PNR_RESULTS}/phase_interpolator/results/phase_interpolator.pnr.v]
analyze -format sverilog [list ${PNR_RESULTS}/biasgen/results/biasgen.pnr.v]
analyze -format sverilog [list ${PNR_RESULTS}/input_divider/results/input_divider.pnr.v]
}
default {
analyze -format sverilog [list ${STUBDIR}/SW.sv]
analyze -format sverilog [list ${STUBDIR}/MOMcap.sv]
analyze -format sverilog [list ${STUBDIR}/CS_cell.sv]
analyze -format sverilog [list ${STUBDIR}/CS_cell_dmm.sv]
analyze -format sverilog [list ${RTLDIR}/del_PI.sv]
analyze -format sverilog [list ${RTLDIR}/phase_blender_1b.sv]
analyze -format sverilog [list ${RTLDIR}/inc_delay.sv]
#analyze -format sverilog [list ${RTLDIR}/inv_bld_1_fixed.sv]
#analyze -format sverilog [list ${RTLDIR}/inv_bld_2_fixed.sv]
#analyze -format sverilog [list ${RTLDIR}/inv_bld_3_fixed.sv]
#analyze -format sverilog [list ${RTLDIR}/mux_bld_fixed.sv]
analyze -format sverilog [list ${RTLDIR}/sync_divider.sv]
}
}
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

#DONT TOUCH INSTANCE
set_dont_touch [get_cells -hierarchical *dont_touch*]

#DONT USE LIBCELL
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

#####################################
# Compile the design
####################################
set COMPILE_COMMAND "compile_ultra -no_autoungroup" ;#-gate_clock"
set ungroup_keep_original_design true
eval $COMPILE_COMMAND

# change to lower insentive names to pass LVS
define_name_rules verilog -type net -allowed "a-z0-9_[]" -add_dummy_nets; 

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
#read_saif -auto_map_names -input ${DESIGN_NAME}.saif -instance < DESIGN_INSTANCE > -verbose
#read_saif -auto_map_names -input ../rtl.saif -instance top/dut -verbose

#report_power -nosplit > ${SYNTH_REPORTS}/${DCRM_FINAL_POWER_REPORT}
report_clock_gating -nosplit > ${SYNTH_REPORTS}/${DCRM_FINAL_CLOCK_GATING_REPORT}
report_clock -nosplit > ${SYNTH_REPORTS}/$DESIGN_TARGET.mapped.clock


#################################################################################
# Write out Design
#################################################################################
set_svf -off
write -format ddc -hierarchy -output ${SYNTH_RESULTS}/${DCRM_FINAL_DDC_OUTPUT_FILE}
write -format verilog -hierarchy -output ${SYNTH_RESULTS}/${DCRM_FINAL_VERILOG_OUTPUT_FILE}
#write -format svsim -output ${SYNTH_RESULTS}/$DESIGN_TARGET.sv


#################################################################################
# Write out Design Data
#################################################################################
write_sdc -nosplit ${SYNTH_RESULTS}/${DCRM_FINAL_SDC_OUTPUT_FILE}

exit

