#################################################
set STAGE       "addSVIA1"
set vars(db_name) 08_addSVIA1
set start_time [clock seconds]
##################################################

setDistributeHost -local
setMultiCpuUsage -localCpu 16

setDesignMode -process 5 -flowEffort standard
editSelect -type Special
editSelectVia -type Special
editChangeStatus -to FIXED

#setViaGenMode -respect_signal_routes 2 -respect_stdcell_cut 1 -viarule_preference VIAGEN12
setViaGenMode -respect_signal_routes 2 -respect_stdcell_geometry true -viarule_preference VIAGEN12 ; # BCLIM
editPowerVia -top_layer M2 -bottom_layer M1 -orthogonal_only 0 -add_vias 1 -split_long_via {2 0.11 -1}

#if { ${RUN_LAYOUT_ONLY} == 0 } {
  saveDesign ${saveDir}/${vars(db_name)}.enc
#}
set_verify_drc_mode -ignore_implant_same_cell_violation true
verify_drc -check_only regular -limit 100000

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



