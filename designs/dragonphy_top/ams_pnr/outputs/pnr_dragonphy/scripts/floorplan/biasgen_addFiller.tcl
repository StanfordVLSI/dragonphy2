#################################################
set STAGE       "postroute_incr"
set start_time [clock seconds]
##################################################
set vars(db_name) 07_addFiller

if { ${RUN_LAYOUT_ONLY} == 0 } {
  ### load always tcl
  source ${scrDir}/edi_setting.tcl
}

### Attach Pin diode 
#attachDiode -diodeCell ANTENNABWP16P90 -pin [all_inputs]


deleteAllCellPad
setFillerMode -doDRC false

set filler1 "FILL1BWP16P90 FILL1BWP16P90LVT FILL1BWP16P90ULVT"
set filler2 "FILL2BWP16P90 FILL2_P2N2BWP16P90 FILL2_P2N3BWP16P90 FILL2_P3N2BWP16P90 FILL2BWP16P90LVT FILL2_P2N2BWP16P90LVT FILL2_P2N3BWP16P90LVT FILL2_P3N2BWP16P90LVT FILL2BWP16P90ULVT FILL2_P2N2BWP16P90ULVT FILL2_P2N3BWP16P90ULVT FILL2_P3N2BWP16P90ULVT"
set filler3 "FILL3BWP16P90 FILL3_P2N2BWP16P90 FILL3_P2N3BWP16P90 FILL3_P3N2BWP16P90 FILL3BWP16P90LVT FILL3_P2N2BWP16P90LVT FILL3_P2N3BWP16P90LVT FILL3_P3N2BWP16P90LVT FILL3BWP16P90ULVT FILL3_P2N2BWP16P90ULVT FILL3_P2N3BWP16P90ULVT FILL3_P3N2BWP16P90ULVT"

set filler4 "DCAP64BWP16P90 DCAP32BWP16P90 DCAP16BWP16P90 DCAP8BWP16P90 DCAP4BWP16P90 DCAP64BWP16P90LVT DCAP32BWP16P90LVT DCAP16BWP16P90LVT DCAP8BWP16P90LVT DCAP4BWP16P90LVT DCAP64BWP16P90ULVT DCAP32BWP16P90ULVT DCAP16BWP16P90ULVT DCAP8BWP16P90ULVT DCAP4BWP16P90ULVT"

set fillerCell "$filler3 $filler2 $filler1"

##---------------------------------------------------------
# add DCAP for different domains (VDD/Vbias)
##---------------------------------------------------------
globalNetConnect Vbias -type pgpin -pin VDD -inst * -override
globalNetConnect Vbias -type pgpin -pin VPP -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override
globalNetConnect VSS -type pgpin -pin VBB -inst * -override

createPlaceBlockage -box 0 0 [expr $VDD_region] $FP_height -type hard -name DCAP_Vbias_blk

addFiller -cell $filler4 -prefix DCAP_Vbias
addFiller -cell $fillerCell -prefix FILLER

deletePlaceBlockage DCAP_Vbias_blk

globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VDD -type pgpin -pin VPP -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override
globalNetConnect VSS -type pgpin -pin VBB -inst * -override

addFiller -cell $filler4 -prefix DCAP
addFiller -cell $fillerCell -prefix FILLER

globalNetConnect Vbias -type pgpin -pin VDD -inst DCAP_Vbias* -override
globalNetConnect Vbias -type pgpin -pin VPP -inst DCAP_Vbias* -override

checkFiller

  saveDesign ${saveDir}/${vars(db_name)}.enc

if { ${RUN_LAYOUT_ONLY} == 0 } {
  
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
