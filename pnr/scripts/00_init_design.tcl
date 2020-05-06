
#################################################
set STAGE       "init_design"
set vars(db_name) 00_init_design
set start_time [clock seconds]
##################################################

## init design
setUserDataValue init_top_cell $topCell
setUserDataValue init_verilog $netlist
setUserDataValue init_design_netlisttype {Verilog}
setUserDataValue init_lef_file "$tlef $lef"
setUserDataValue init_mmmc_file "${scrDir}/viewDefinition.tcl"
setUserDataValue init_pwr_net $pwr_name
setUserDataValue init_gnd_net $gnd_name
setUserDataValue init_design_uniquify {1}

############
init_design
############


set ILM_MODE 1        ;# set 1 if it uses ILM; 0 otherwise

if { ${ILM_MODE} == 1 }  {
  create_constraint_mode -name func -sdc_files $sdc(prects) -ilm_sdc_files $sdc(prects)
} else {
  create_constraint_mode -name func -sdc_files $sdc(prects) 
}


#### add by ptrw #####
set_interactive_constraint_modes [all_constraint_modes -active]

saveDesign ${saveDir}/${vars(db_name)}.enc

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
