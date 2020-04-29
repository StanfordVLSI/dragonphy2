
#################################################
set STAGE       "route"
set vars(db_name) 04_route
set start_time [clock seconds]
##################################################

if { ${RUN_LAYOUT_ONLY} == 0 } {
  
  ## update sdc ##
  update_constraint_mode -name func -sdc_files $sdc(postcts)
  
  ################
  set_interactive_constraint_modes [all_constraint_modes -active]
  
  ## data is 1/3 of clock period 0.6
  ## clcok is 1/6 of clock priod 0.6
  #set_max_transition ${max_tran} [get_design [dbget top.name]]
  set_propagated_clock [all_clocks]
  
  
  ### load always tcl
  source ${scrDir}/edi_setting.tcl
  ### update RC Factor
  source ${scrDir}/updateRCFactor.tcl
  
  ####################################################
  ## Delay Cal  mode                                ##
  ####################################################
  setDelayCalMode -reset
  #BCLIM: complain -useECSMInPreRoute is invalid opt
  #setDelayCalMode -engine Aae -SIAware false -signOff true -useECSMInPreRoute true
  setDelayCalMode -engine Aae -SIAware false -signOff true 
  setDelayCalMode -equivalent_waveform_model propagation
  setDelayCalMode -siMode signoff
  
  setAnalysisMode -reset
  setAnalysisMode -analysisType onChipVariation -cppr both
  
  
  routeDesign
  
  saveDesign ${saveDir}/${vars(db_name)}.enc
  
  
} else {
  routeDesign
  verify_drc -check_only regular -limit 100000
  saveDesign ${saveDir}/${vars(db_name)}.enc
}

####################################################
## Run time                                       ##
####################################################
set stop_time [clock seconds]
set elapsedTime [clock format [expr $stop_time - $start_time] -format %H:%M:%S -gmt true]
puts "=============================================="
puts "         Completed step : $STAGE"
puts "        Elapsed runtime : $STAGE: $elapsedTime"
puts "=============================================="
exec /bin/date > ${STAGE}.time
exec echo "Elapsed runtime : $STAGE: $elapsedTime" >> ${STAGE}.time
###################################################


