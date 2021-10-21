
##################################################
set STAGE       "place"
set vars(db_name) 01_place
set start_time [clock seconds]
##################################################

if { ${RUN_LAYOUT_ONLY} == 0 } {
  
  ## update sdc ##
  if { ${ILM_MODE} == 1 }  {
    update_constraint_mode -name func -ilm_sdc_files $sdc(prects)
  } else {
    update_constraint_mode -name func -sdc_files $sdc(prects)
  }
  
  #flattenIlm
  ################
  set_interactive_constraint_modes [all_constraint_modes -active]
  
  
  ### load always tcl
  source ${scrDir}/edi_setting.tcl
  ### update RC Factor
  source ${scrDir}/updateRCFactor.tcl
  
  ####################################################
  ## Delay Cal  mode                                ##
  ####################################################
  setDelayCalMode -engine Aae -SIAware false -signOff true 
  
  
  source ${scrDir}/path_groups.tcl
  placeDesign
  saveDesign ${saveDir}/${vars(db_name)}.enc
  
} else {
  placeDesign
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
