
#################################################
set STAGE       "postroute"
set vars(db_name) 05_postroute
set start_time [clock seconds]
##################################################

if { ${RUN_LAYOUT_ONLY} == 0 } {
  
  ## update sdc ##
  update_constraint_mode -name func -sdc_files $sdc(postcts)
  
  ################
  set_interactive_constraint_modes [all_constraint_modes -active]
  
  ## data is 1/3 of clock period 0.6
  ## clcok is 1/6 of clock priod 0.6
  #set_max_transition 0.300 [get_design [dbget top.name]]
  set_propagated_clock [all_clocks]
  
  
  ### load always tcl
  source ${scrDir}/edi_setting.tcl
  
  ####################################################
  ## Delay Cal  mode                                ##
  ####################################################
  setDelayCalMode -reset
  setDelayCalMode -engine Aae -SIAware true -signOff true 
  setDelayCalMode -equivalent_waveform_model propagation 
  
  setAnalysisMode -reset
  setAnalysisMode -analysisType onChipVariation -cppr both
  
  source ${scrDir}/path_groups.tcl
  optDesign -postRoute -expandedViews -hold
  
  saveDesign ${saveDir}/${vars(db_name)}.enc
  timeDesign -postRoute -expandedViews -numPaths 500 -outDir RPT/${vars(db_name)}
  
  optDesign -postRoute -incr -expandedViews -hold 
  verify_drc -check_only regular -limit 100000
  saveDesign ${saveDir}/${vars(db_name)}_incr.enc
  timeDesign -postRoute -expandedViews -numPaths 500 -outDir RPT/${vars(db_name)}_incr
  
  globalDetailRoute
  verify_drc -check_only regular -limit 100000
  saveDesign ${saveDir}/${vars(db_name)}_Route.enc
  timeDesign -postRoute -expandedViews -numPaths 500 -outDir RPT/${vars(db_name)}_Route
  
  optDesign -postRoute -incr -expandedViews -hold
  verify_drc -check_only regular -limit 100000
  saveDesign ${saveDir}/${vars(db_name)}_incr_2.enc
  timeDesign -postRoute -expandedViews -numPaths 500 -outDir RPT/${vars(db_name)}_incr_2
  
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
}
 



