if { ${RUN_LAYOUT_ONLY} == 0 } {
  #################################################
  set STAGE       "prects"
  set start_time [clock seconds]
  ##################################################
  set vars(db_name) 02_prects_incr
  
  ## update sdc ##
  update_constraint_mode -name func -sdc_files $sdc(prects)
  
  ################
  set_interactive_constraint_modes [all_constraint_modes -active]
  
  ## data is 1/3 of clock period 1
  ## clcok is 1/6 of clock priod 1
  set_max_transition ${max_tran} [get_design [dbget top.name]]
  
  ### load always tcl
  source ${scrDir}/edi_setting.tcl
  ### update RC Factor
  source ${scrDir}/updateRCFactor.tcl
  
  ####################################################
  ## Delay Cal  mode                                ##
  ####################################################
  #BCLIM: complain -useECSMInPreRoute is invalid opt
  #setDelayCalMode -engine Aae -SIAware false -signOff true -useECSMInPreRoute true
  setDelayCalMode -engine Aae -SIAware false -signOff true 
  
  ##specify clock spec for prects
  #cleanupSpecifyClockTree
  #specifyClockTree -file 
  
  
  source ${scrDir}/path_groups.tcl
  optDesign -preCTS -expandedViews 
  
  saveDesign ${saveDir}/${vars(db_name)}.enc
  
  timeDesign -preCTS -expandedViews -numPaths 500 -outDir RPT/${vars(db_name)}
  
  
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
