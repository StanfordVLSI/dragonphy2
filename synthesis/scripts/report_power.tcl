# Load header
source $SYNTH_HOME/syn_scripts/header.tcl


set suppress_errors WL-40
saif_map -start
# single frame power measurement
read_file -format ddc ${SYNTH_RESULTS}/${DCRM_FINAL_DDC_OUTPUT_FILE}
link

read_saif -auto_map_names -input ${SYNTH_SAIF}/dc_simv.saif -instance top/dut/imager_chip -verbose
report_saif -hier

report_power -analysis high -nosplit > ${SYNTH_REPORTS}/${DCRM_FINAL_POWER_REPORT}
report_power -hier -analysis high -nosplit >> ${SYNTH_REPORTS}/${DCRM_FINAL_POWER_REPORT}

# internal power measurement
reset_switching_activity
read_saif -auto_map_names -input ${SYNTH_SAIF}/dc_simv_int_pwr.saif -instance top/dut/imager_chip -verbose
report_saif -hier

report_power -analysis high -nosplit > ${SYNTH_REPORTS}/${DCRM_INT_POWER_REPORT}
report_power -hier -analysis high -nosplit >> ${SYNTH_REPORTS}/${DCRM_INT_POWER_REPORT}

exit
