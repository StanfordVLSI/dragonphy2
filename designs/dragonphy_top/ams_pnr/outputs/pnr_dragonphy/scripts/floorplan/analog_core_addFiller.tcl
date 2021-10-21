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


createPlaceBlockage -box 0 0 [expr $origin2_x-$block_blockage_width-2*$DB_width-$welltap_width] $FP_height -name DCAP_blk_left 
createPlaceBlockage -box $FP_width 0 [expr $FP_width-($origin2_x-$block_blockage_width-2*$DB_width-$welltap_width)] $FP_height -name DCAP_blk_right
createPlaceBlockage -box [expr $origin2_x-$block_blockage_width-2*$DB_width-$welltap_width] $FP_height [expr $FP_width-($origin2_x-$block_blockage_width-2*$DB_width-$welltap_width)] [expr $FP_height-$boundary_height-$biasgen_height-$domain_blockage_height] -name DCAP_blk_top
createPlaceBlockage -box 0 0 $FP_width [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height+$domain_blockage_height] -name DCAP_blk_bottom

addFiller -cell $filler4 -prefix DCAP_AVDD
addFiller -cell $fillerCell -prefix FILLER

deletePlaceBlockage DCAP_blk_top

addFiller -cell $filler4 -prefix DCAP_Vcal
addFiller -cell $fillerCell -prefix FILLER

deletePlaceBlockage {DCAP_blk_left DCAP_blk_right DCAP_blk_bottom} 

addFiller -cell $filler4 -prefix DCAP_CVDD
addFiller -cell $fillerCell -prefix FILLER

##---------------------------------------------------------
# Re-connect power domains 
##---------------------------------------------------------

globalNetConnect CVDD -type pgpin -pin VDD -inst * -override
globalNetConnect CVDD -type pgpin -pin VPP -inst * -override
globalNetConnect CVSS -type pgpin -pin VSS -inst * -override
globalNetConnect CVSS -type pgpin -pin VBB -inst * -override

globalNetConnect AVDD -type pgpin -pin VDD -inst {DCAP_AVDD*} -override
globalNetConnect AVSS -type pgpin -pin VSS -inst {DCAP_AVDD*} -override
globalNetConnect AVDD -type pgpin -pin VPP -inst {DCAP_AVDD*} -override
globalNetConnect AVSS -type pgpin -pin VBB -inst {DCAP_AVDD*} -override

globalNetConnect Vcal -type pgpin -pin VDD -inst {DCAP_Vcal*} -override
globalNetConnect AVSS -type pgpin -pin VSS -inst {DCAP_Vcal*} -override
globalNetConnect Vcal -type pgpin -pin VPP -inst {DCAP_Vcal*} -override
globalNetConnect AVSS -type pgpin -pin VBB -inst {DCAP_Vcal*} -override

globalNetConnect AVDD -type pgpin -pin AVDD -inst {iADC*} -override
globalNetConnect AVSS -type pgpin -pin AVSS -inst {iADC*} -override
globalNetConnect AVDD -type pgpin -pin VDD -inst {iBG*} -override
globalNetConnect AVSS -type pgpin -pin VSS -inst {iBG*} -override

globalNetConnect DVDD -type pgpin -pin VDD -inst {DCAP_DVDD*} -override
globalNetConnect DVSS -type pgpin -pin VSS -inst {DCAP_DVDD*} -override
globalNetConnect DVDD -type pgpin -pin VPP -inst {DCAP_DVDD*} -override
globalNetConnect DVSS -type pgpin -pin VBB -inst {DCAP_DVDD*} -override

globalNetConnect DVDD -type pgpin -pin DVDD -inst {iADC*} -override
globalNetConnect DVSS -type pgpin -pin DVSS -inst {iADC*} -override

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
