puts "RM-Info: Running script [info script]\n"

#################################################################################
# Design Compiler Reference Methodology Filenames Setup
# Script: dc_setup_filenames.tcl
# Version: F-2011.09-SP4 (April 2, 2012)
# Copyright (C) 2010-2012 Synopsys, Inc. All rights reserved.
#################################################################################

#################################################################################
# Use this file to customize the filenames used in the Design Compiler
# Reference Methodology scripts.  This file is designed to be sourced at the
# beginning of the dc_setup.tcl file after sourcing the common_setup.tcl file.
#
# Note that the variables presented in this file depend on the type of flow
# selected when generating the reference methodology files.
#
# Example.
#    If you set DFT flow as FALSE, you will not see DFT related filename
#    variables in this file.
#
# When reusing this file for different flows or newer release, ensure that
# all the required filename variables are defined.  One way to do this is
# to source the default dc_setup_filenames.tcl file and then override the
# default settings as needed for your design.
#
# The default values are backwards compatible with older
# Design Compiler Reference Methodology releases.
#
# Note: Care should be taken when modifying the names of output files
#       that are used in other scripts or tools.
#################################################################################

#################################################################################
# General Flow Files
#################################################################################

set DESIGN_NAME                                         ${DESIGN_TARGET}

##########################
# Milkyway Library Names #
##########################

set DCRM_MW_LIBRARY_NAME				${DESIGN_TARGET}_LIB
set DCRM_FINAL_MW_CEL_NAME				${DESIGN_TARGET}_DCT

###############
# Input Files #
###############

set DCRM_SDC_INPUT_FILE					${DESIGN_TARGET}.sdc
set DCRM_CONSTRAINTS_INPUT_FILE				${DESIGN_TARGET}.constraints.tcl

###########
# Reports #
###########

set DCRM_CHECK_LIBRARY_REPORT				${DESIGN_TARGET}.check_library.rpt

set DCRM_CONSISTENCY_CHECK_ENV_FILE			${DESIGN_TARGET}.compile_ultra.env
set DCRM_CHECK_DESIGN_REPORT				${DESIGN_TARGET}.check_design.rpt
set DCRM_COMPILE_ULTRA_QOR_REPORT			${DESIGN_TARGET}.compile_ultra.qor.rpt

set DCRM_FINAL_QOR_REPORT				${DESIGN_TARGET}.mapped.qor.rpt
set DCRM_FINAL_TIMING_REPORT				${DESIGN_TARGET}.mapped.timing.rpt
set DCRM_FINAL_LONG_TIMING_REPORT			${DESIGN_TARGET}.mapped.long_timing.rpt
set DCRM_FINAL_TIMING_LOOP_REPORT		      	${DESIGN_TARGET}.mapped.timing.loop.rpt
set DCRM_FINAL_AREA_REPORT				${DESIGN_TARGET}.mapped.area.rpt
set DCRM_FINAL_AREA_HIER_REPORT				${DESIGN_TARGET}.mapped.area.heir.rpt
set DCRM_FINAL_POWER_REPORT				${DESIGN_TARGET}.mapped.power.rpt
set DCRM_INT_POWER_REPORT				${DESIGN_TARGET}.mapped.int_power.rpt
set DCRM_FINAL_CLOCK_GATING_REPORT			${DESIGN_TARGET}.mapped.clock_gating.rpt

################
# Output Files #
################

set DCRM_AUTOREAD_RTL_SCRIPT				${DESIGN_TARGET}.autoread_rtl.tcl
set DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE 		${DESIGN_TARGET}.elab.ddc
set DCRM_COMPILE_ULTRA_DDC_OUTPUT_FILE			${DESIGN_TARGET}.compile_ultra.ddc
set DCRM_FINAL_DDC_OUTPUT_FILE				${DESIGN_TARGET}.mapped.ddc
set DCRM_FINAL_VERILOG_OUTPUT_FILE			${DESIGN_TARGET}.mapped.v
set DCRM_FINAL_SDC_OUTPUT_FILE				${DESIGN_TARGET}.mapped.sdc


#################################################################################
# DCT Flow Files
#################################################################################

###################
# DCT Input Files #
###################

set DCRM_DCT_DEF_INPUT_FILE				${DESIGN_TARGET}.def
set DCRM_DCT_FLOORPLAN_INPUT_FILE			${DESIGN_TARGET}.fp
set DCRM_DCT_PHYSICAL_CONSTRAINTS_INPUT_FILE		${DESIGN_TARGET}.physical_constraints.tcl


###############
# DCT Reports #
###############

set DCRM_DCT_PHYSICAL_CONSTRAINTS_REPORT		${DESIGN_TARGET}.physical_constraints.rpt

set DCRM_DCT_FINAL_CONGESTION_REPORT			${DESIGN_TARGET}.mapped.congestion.rpt
set DCRM_DCT_FINAL_CONGESTION_MAP_OUTPUT_FILE		${DESIGN_TARGET}.mapped.congestion_map.png
set DCRM_DCT_FINAL_CONGESTION_MAP_WINDOW_OUTPUT_FILE	${DESIGN_TARGET}.mapped.congestion_map_window.png

####################
# DCT Output Files #
####################

set DCRM_DCT_FLOORPLAN_OUTPUT_FILE			${DESIGN_TARGET}.initial.fp

set DCRM_DCT_FINAL_FLOORPLAN_OUTPUT_FILE		${DESIGN_TARGET}.mapped.fp
set DCRM_DCT_FINAL_SPEF_OUTPUT_FILE			${DESIGN_TARGET}.mapped.spef
set DCRM_DCT_FINAL_SDF_OUTPUT_FILE			${DESIGN_TARGET}.mapped.sdf


#################################################################################
# DFT Flow Files
#################################################################################

###################
# DFT Input Files #
###################

set DCRM_DFT_SIGNAL_SETUP_INPUT_FILE			${DESIGN_TARGET}.dft_signal_defs.tcl
set DCRM_DFT_AUTOFIX_CONFIG_INPUT_FILE			${DESIGN_TARGET}.dft_autofix_config.tcl

###############
# DFT Reports #
###############

set DCRM_DFT_DRC_CONFIGURED_SUMMARY_REPORT		${DESIGN_TARGET}.dft_drc_configured_summary.rpt
set DCRM_DFT_DRC_CONFIGURED_VERBOSE_REPORT		${DESIGN_TARGET}.dft_drc_configured.rpt
set DCRM_DFT_SCAN_CONFIGURATION_REPORT			${DESIGN_TARGET}.scan_config.rpt
set DCRM_DFT_PREVIEW_CONFIGURATION_REPORT		${DESIGN_TARGET}.report_dft_insertion_config.preview_dft.rpt
set DCRM_DFT_PREVIEW_DFT_SUMMARY_REPORT			${DESIGN_TARGET}.preview_dft_summary.rpt
set DCRM_DFT_PREVIEW_DFT_ALL_REPORT			${DESIGN_TARGET}.preview_dft.rpt

set DCRM_DFT_FINAL_SCAN_PATH_REPORT			${DESIGN_TARGET}.mapped.scanpath.rpt
set DCRM_DFT_DRC_FINAL_REPORT				${DESIGN_TARGET}.mapped.dft_drc_inserted.rpt
set DCRM_DFT_FINAL_SCAN_COMPR_SCAN_PATH_REPORT		${DESIGN_TARGET}.mapped.scanpath.scan_compression.rpt
set DCRM_DFT_DRC_FINAL_SCAN_COMPR_REPORT		${DESIGN_TARGET}.mapped.dft_drc_inserted.scan_compression.rpt
set DCRM_DFT_FINAL_CHECK_SCAN_DEF_REPORT		${DESIGN_TARGET}.mapped.check_scan_def.rpt
set DCRM_DFT_FINAL_DFT_SIGNALS_REPORT			${DESIGN_TARGET}.mapped.dft_signals.rpt

####################
# DFT Output Files #
####################

set DCRM_DFT_FINAL_SCANDEF_OUTPUT_FILE			${DESIGN_TARGET}.mapped.scandef
set DCRM_DFT_FINAL_EXPANDED_SCANDEF_OUTPUT_FILE		${DESIGN_TARGET}.mapped.expanded.scandef
set DCRM_DFT_FINAL_CTL_OUTPUT_FILE			${DESIGN_TARGET}.mapped.ctl
set DCRM_DFT_FINAL_PROTOCOL_OUTPUT_FILE			${DESIGN_TARGET}.mapped.scan.spf
set DCRM_DFT_FINAL_SCAN_COMPR_PROTOCOL_OUTPUT_FILE	${DESIGN_TARGET}.mapped.scancompress.spf


#################################################################################
# Formality Flow Files
#################################################################################

set DCRM_SVF_OUTPUT_FILE 				${DESIGN_TARGET}.mapped.svf

set FMRM_UNMATCHED_POINTS_REPORT			${DESIGN_TARGET}.fmv_unmatched_points.rpt

set FMRM_FAILING_SESSION_NAME				${DESIGN_TARGET}
set FMRM_FAILING_POINTS_REPORT				${DESIGN_TARGET}.fmv_failing_points.rpt
set FMRM_ABORTED_POINTS_REPORT				${DESIGN_TARGET}.fmv_aborted_points.rpt
set FMRM_ANALYZE_POINTS_REPORT				${DESIGN_TARGET}.fmv_analyze_points.rpt

puts "RM-Info: Completed script [info script]\n"
