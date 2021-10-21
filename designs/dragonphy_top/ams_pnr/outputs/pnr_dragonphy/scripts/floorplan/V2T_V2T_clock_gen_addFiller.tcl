
#################################################
set STAGE       "postroute_incr"
set vars(db_name) 07_addFiller
set start_time [clock seconds]
##################################################

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

addFiller -cell $filler4 -prefix DCAP
addFiller -cell $fillerCell -prefix FILLER
checkFiller


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
  

