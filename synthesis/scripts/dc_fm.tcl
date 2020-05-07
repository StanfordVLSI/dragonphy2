source $SYNTH_HOME/scripts/header.tcl

#################################################################################
# Formality Verification Script for
# Design Compiler Reference Methodology Script for Top-Down Flow
# Script: fm.tcl
# Version: F-2011.09 (September 26, 2011)
# Copyright (C) 2007-2011 Synopsys, Inc. All rights reserved.
#################################################################################

#################################################################################
# Synopsys Auto Setup Mode
#################################################################################

set_app_var synopsys_auto_setup true

# Note: The Synopsys Auto Setup mode is less conservative than the Formality default mode, 
# and is more likely to result in a successful verification out-of-the-box.
#
# Using the Setting this variable will change the default values of the variables listed here below
# You may change any of these variables back to their default settings to be more conservative.
# Uncomment the appropriate lines below to revert back to their default settings:

	# set_app_var hdlin_ignore_parallel_case true
	# set_app_var hdlin_ignore_full_case true
	# set_app_var verification_verify_directly_undriven_output true
	# set_app_var hdlin_ignore_embedded_configuration false
	# set_app_var svf_ignore_unqualified_fsm_information true
	# set_app_var signature_analysis_allow_subset_match true

# Other variables with changed default values are described in the next few sections.

#################################################################################
# Setup for handling undriven signals in the design
#################################################################################

# The Synopsys Auto Setup mode sets undriven signals in the reference design to
# "0" or "BINARY" (as done by DC), and the undriven signals in the impl design are
# forced to "BINARY".  This is done with the following setting:
	# set_app_var verification_set_undriven_signals synthesis
# Uncomment the next line to revert back to the more conservative default setting:

	# set_app_var verification_set_undriven_signals BINARY:X

#################################################################################
# Setup for simulation/synthesis mismatch messaging
#################################################################################

# The Synopsys Auto Setup mode will produce warning messages, not error messages,
# when Formality encounters potential differences between simulation and synthesis.
# Uncomment the next line to revert back to the more conservative default setting:

	# set_app_var hdlin_error_on_mismatch_message true

#################################################################################
# Setup for Clock-gating
#################################################################################

# The Synopsys Auto Setup mode, along with the SVF file, will appropriately set the clock-gating variable.
# Otherwise, the user will need to notify Formality of clock-gating by uncommenting the next line:

	# set_app_var verification_clock_gate_hold_mode any

#################################################################################
# Setup for instantiated DesignWare or function-inferred DesignWare components
#################################################################################

# Set this variable ONLY if your design contains instantiated DW or function-inferred DW

	#set_app_var hdlin_dwroot "" ;# Enter the pathname to the top-level of the DC tree

#################################################################################
# Setup for handling missing design modules
#################################################################################

# If the design has missing blocks or missing components in both the reference and implementation designs,
# uncomment the following variable so that Formality can complete linking each design:

	# set_app_var hdlin_unresolved_modules black_box

########################################################################
# Setup for instantiated or function-inferred DesignWare components
########################################################################
set hdlin_dwroot $env(SYNOPSYS)

#################################################################################
# Read in the SVF file(s)
#################################################################################

# Set this variable to point to individual SVF file(s) or to a directory containing SVF files.

set svf_retiming false
echo ${SYNTH_RESULTS}/${DCRM_SVF_OUTPUT_FILE}
set_svf ${SYNTH_RESULTS}/${DCRM_SVF_OUTPUT_FILE}


#################################################################################
# Read in the libraries
#################################################################################

set_app_var verification_verify_unread_tech_cell_pins false

foreach tech_lib $ALL_WC_LIBS {
  read_db -technology_library $tech_lib
}

#################################################################################
# Read in the Reference Design as verilog/vhdl source code
#################################################################################

#Warning: Pragma 'set_flatten' is not used by Formality.  (FMR_VLOG-075)
suppress_message { FMR_VLOG-075 }

read_sverilog -r [glob ${RUNDIR}/genesis_synth/*.v] -work_library WORK

set_top r:/WORK/${DESIGN_TARGET}

#################################################################################
# Read in the Implementation Design from DC-RM results
#
# Choose the format that is used in your flow.
#################################################################################

# For Verilog
read_verilog -i ${SYNTH_RESULTS}/${DCRM_FINAL_VERILOG_OUTPUT_FILE}

# OR

# For .ddc
#read_ddc -i ${RESULTS_DIR}/${DCRM_FINAL_DDC_OUTPUT_FILE}
#read_ddc -i ${RESULTS_DIR}/${DCRM_COMPILE_ULTRA_DDC_OUTPUT_FILE}

# OR

# For Milkyway

# The -no_pg option should be used for MW designs from DC to prevent automatic
# linking to power aware versions of the cells.

# read_milkyway -i -no_pg -libname WORK -cell_name ${DCRM_FINAL_MW_CEL_NAME} ${mw_design_library}

set_top i:/WORK/${DESIGN_TARGET}


#################################################################################
# Configure constant ports
#
# When using the Synopsys Auto Setup mode, the SVF file will convey information
# automatically to Formality about how to disable scan.
#
# Otherwise, manually define those ports whose inputs should be assumed constant
# during verification.
#
# Example command format:
#
#   set_constant -type port i:/WORK/${DESIGN_NAME}/<port_name> <constant_value> 
#
#################################################################################

# setup the clock generator, use external clock only

# disable the seletion of offchip_clk_fast
set_constant -type net {r:/WORK/imager_chip/imager_core/clock_gen/select_digital_clk} 1
set_constant -type net {i:/WORK/imager_chip/imager_core/clock_gen/select_digital_clk} 1


# dont verify current signal net
#set_dont_verify r:/WORK/FPChip/ifc.analog_clk 
#set_dont_verify r:/WORK/FPChip/pad_wrapper/pad_analog_in_analog_clk/anaIn_pad/ANAIOPAD 

# dont replace the following black boxes after linking cell libraries
#set_black_box i:/imager_custom/sine_to_pulse_unq1
#set_black_box i:/imager_custom/pad_for_analog_and_supply
#set_black_box i:/imager_custom/pad_for_analog_and_supply

#################################################################################
# Report design statistics, design read warning messages, and user specified setup
#################################################################################

# report_setup_status will create a report showing all design statistics,
# design read warning messages, and all user specified setup.  This will allow
# the user to check all setup before proceeding to run the more time consuming
# commands "match" and "verify".

# report_setup_status

#################################################################################
# Match compare points and report unmatched points 
#################################################################################

match

report_unmatched_points > ${SYNTH_REPORTS}/${FMRM_UNMATCHED_POINTS_REPORT}


#################################################################################
# Verify and Report
#
# If the verification is not successful, the session will be saved and reports
# will be generated to help debug the failed or inconclusive verification.
#################################################################################
#verify
if { ![verify] }  {  
  save_session -replace ${SYNTH_REPORTS}/${FMRM_FAILING_SESSION_NAME}
  report_failing_points > ${SYNTH_REPORTS}/${FMRM_FAILING_POINTS_REPORT}
  report_aborted > ${SYNTH_REPORTS}/${FMRM_ABORTED_POINTS_REPORT}
  # Use analyze_points to help determine the next step in resolving verification
  # issues. It runs heuristic analysis to determine if there are potential causes
  # other than logical differences for failing or hard verification points. 
  analyze_points -all > ${SYNTH_REPORTS}/${FMRM_ANALYZE_POINTS_REPORT}
}
#start_gui
exit
