# load pnr variables
#---------------------------------------------------------
set fid [open "${pnrDir}/pnr_vars.txt" r]
set read_data [read -nonewline $fid]
close $fid

set pnr_data [split $read_data "\n"]
foreach block_data $pnr_data {
  set fields [split $block_data ":"]
    lassign $fields var_name var_value
      set $var_name $var_value
}


set boundary_width [expr $welltap_width+$DB_width]
set blockage_width [expr 5*$cell_grid]
set blockage_height [expr $cell_height]

##---------------------------------------------------------
## set FloorPlan
##---------------------------------------------------------
set FP_width $stochastic_adc_PR_width
set FP_height  [expr 34*$cell_height]
floorPlan -site core -s $FP_width  $FP_height 0 0 0 0 



######################
## Add boundary cell # 
######################
set FP_WTAP_S $FP_width  ;  # well tap spacing
setEndCapMode -reset
setEndCapMode \
  -rightEdge BOUNDARY_LEFTBWP16P90  \
  -leftEdge  BOUNDARY_RIGHTBWP16P90 \
  -leftBottomCorner BOUNDARY_NCORNERBWP16P90 \
  -leftTopCorner    BOUNDARY_PCORNERBWP16P90 \
  -rightTopEdge    FILL3BWP16P90 \
  -rightBottomEdge FILL3BWP16P90 \
  -bottomEdge "BOUNDARY_NROW2BWP16P90 BOUNDARY_NROW3BWP16P90" \
  -topEdge    "BOUNDARY_PROW2BWP16P90 BOUNDARY_PROW3BWP16P90" \
  -fitGap true \
  -prefix BNDRY \
  -boundary_tap true
set_well_tap_mode \
  -rule 10 \
  -bottom_tap_cell BOUNDARY_NTAPBWP16P90 \
  -top_tap_cell    BOUNDARY_PTAPBWP16P90 \
  -block_boundary_only true \
  -cell TAPCELLBWP16P90


###############
# P/G connect #
###############

globalNetConnect VDD -type pgpin -pin VDD -inst * -override 
globalNetConnect VDD -type pgpin -pin VPP -inst * -override
globalNetConnect VSS -type pgpin -pin VBB -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *

set Vbias_region [expr floor($Vcal_M7_offset/$cell_grid)*$cell_grid-3*$boundary_width]
set VDD_region [expr $Vbias_region-2*$blockage_width]

set origin_x [expr $VDD_region-$SW_width-$welltap_width-2*$DB_width-2*$blockage_width]
set origin_y [expr $FP_height/2-$cell_height]

placeInstance I5 $origin_x $origin_y 
createPlaceBlockage -box [expr $origin_x-$blockage_width] [expr $origin_y-$blockage_height] [expr $origin_x+$SW_width+$blockage_width] [expr $origin_y+$SW_height+$blockage_height] -type hard
addWellTap -cell TAPCELLBWP16P90 -inRowOffset 1  -cellInterval $FP_width -prefix WELLTAP


addStripe -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -master "TAP*"   \
  -merge_stripes_value 0.045   \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -nets {VSS} 

createRouteBlk -box [expr $VDD_region] 0 $FP_width $FP_height -layer 1

addStripe -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -master "TAP*"   \
  -merge_stripes_value 0.045   \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -nets {VDD} 

deleteInst WELL* 
deleteRouteBlk -all

createPlaceBlockage -box [expr $VDD_region] 0 $FP_width  [expr $FP_height] -type hard -name Vbias_region_blk
addEndCap 


addWellTap -cell TAPCELLBWP16P90  -inRowOffset 0 -cellInterval $FP_width -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90  -inRowOffset [expr $VDD_region-$welltap_width-$DB_width] -cellInterval $FP_width -prefix WELLTAP

deletePlaceBlockage Vbias_region_blk


globalNetConnect Vbias -type pgpin -pin VDD -inst * -override
globalNetConnect Vbias -type pgpin -pin VPP -inst * -override

createPlaceBlockage -box [expr $VDD_region] 0 [expr $Vbias_region]  [expr $FP_height] -type hard

addEndCap 

addWellTap -cell TAPCELLBWP16P90  -inRowOffset [expr $Vbias_region]  -cellInterval [expr ($FP_width-$Vbias_region)/2-$welltap_width/2] -prefix WELLTAP
createRouteBlk -box 0 0 $Vbias_region $FP_height -layer 1

addStripe -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -master "TAPCELL*"   \
  -merge_stripes_value 0.045   \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -nets {Vbias} 

deleteRouteBlk -all







## Vbias net
setEdit -layer_minimum M1
setEdit -layer_maximum AP
setEdit -force_regular 1
getEdit -snap_to_track_regular
getEdit -snap_to_pin
viewLast
setEdit -force_special 1
getEdit -snap_to_track
getEdit -snap_special_wire
getEdit -align_wire_at_pin
getEdit -snap_to_row
getEdit -snap_to_pin
setViaGenMode -ignore_DRC false
setViaGenMode -use_fgc 1
setViaGenMode -use_cce false

setEdit -layer_horizontal M6
setEdit -width_horizontal $SW_pin_length

setEdit -nets Vbias
editAddRoute [expr $VDD_region-$welltap_width-2*$DB_width-2*$blockage_width-$SW_pin_depth] [expr $FP_height/2-$cell_height+$SW_height/2]
editCommitRoute [expr $Vcal_M7_offset+$AVDD_M7_width]  [expr $FP_height/2-$cell_height+$SW_height/2]


#M7 Vbias grid
addStripe -nets {Vbias} \
  -layer M7 -direction vertical -width $AVDD_M7_width -spacing $AVDD_M7_space  -start_offset [expr $Vcal_M7_offset-$AVDD_M7_width/2] -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit M7 -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M1 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

createRouteBlk -box 0 0 $FP_width $cell_height -name M7_blk_bot -layer 7
createRouteBlk -box 0 $FP_height $FP_width [expr $FP_height-$cell_height] -name M7_blk_bot -layer 7



#addStripe -nets {VSS Vbias} \
#  -layer M7 -direction vertical -width $AVDD_M7_width -spacing [expr 2*$AVDD_M7_space]  -start_offset $Vbias_region -stop_offset [expr $FP_width-$Vcal_M7_offset-$AVDD_M7_width/2] -set_to_set_distance [expr ($AVDD_M7_width+2*$AVDD_M7_space)*2] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit M7 -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M1 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape }  

addStripe -nets {VSS Vbias} \
  -layer M7 -direction vertical -width $AVDD_M7_width -spacing [expr 2*$AVDD_M7_space]  -start_offset [expr $Vcal_M7_offset-$AVDD_M7_width/2] -set_to_set_distance [expr ($AVDD_M7_width+2*$AVDD_M7_space)*2] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit M7 -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M1 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape }  


#M7 VDD gird
addStripe -nets {VDD VSS} \
  -layer M7 -direction vertical -width $AVDD_M7_width -spacing $AVDD_M7_space -start_offset $DB_width -stop_offset [expr $FP_width-($origin_x-$blockage_width)] -set_to_set_distance [expr 2*($AVDD_M7_width+$AVDD_M7_space)] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit M7 -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M1 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

#M3
addStripe -nets {VDD} \
  -layer M3 -direction vertical -width $DB_width -spacing $AVDD_M7_space -start_offset [expr $VDD_region-$DB_width]  -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M3 -block_ring_top_layer_limit M3 -block_ring_bottom_layer_limit M3 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {VSS} \
  -layer M3 -direction vertical -width $DB_width -spacing $AVDD_M7_space -start_offset $Vbias_region -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M3 -block_ring_top_layer_limit M3 -block_ring_bottom_layer_limit M3 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


#M8
addStripe -nets {VSS Vbias VDD} \
  -layer M8 -direction horizontal -width $AVDD_M8_width -spacing $AVDD_M8_space -start_offset $cell_height -set_to_set_distance [expr ($AVDD_M8_width+$AVDD_M8_space)*3]  -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit M8 -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M1 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape }

createRouteBlk -box 0 0 $FP_width $FP_height -layer 7

# M9 Vbias/VDD grid
addStripe -nets {VSS} \
  -layer M9 -direction vertical -width $M9_width -spacing $M9_space -start_offset $AVSS_M9_offset -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {VDD VSS VDD} \
  -layer M9 -direction vertical -width $M9_width -spacing $M9_space -start_offset $AVDD_M9_offset -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


deleteRouteBlk -all

#######
# NDR #
#######
add_ndr -name NDR_5W2S -spacing {M1:M2 0.05 M3 0.05 M4:M7 0.05} -width {M1:M2 0.18 M3 0.18 M4:M7 0.2}
setAttribute -net net_tied -non_default_rule NDR_5W2S


globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VDD -type pgpin -pin VPP -inst * -override


###########
# IO file #
###########
#loadIoFile ${ioDir}/${DesignName}.io

setPinAssignMode -pinEditInBatch true
editPin -pinWidth $pin_width -pinDepth $pin_depth -spacing [expr 8*$metal_space] -fixOverlap 1 -spreadDirection counterclockwise -edge 0 -layer 2 -spreadType center -pin {ctl* en}

#------------------------------------------------------
set RUN_LAYOUT_ONLY 1
#------------------------------------------------------

##------------------------------------------------------
# pnr variable file-out ##
##------------------------------------------------------
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "${DesignName}_width:$FP_width\n"
puts -nonewline $fid "${DesignName}_height:$FP_height\n"
close $fid

saveDesign ${saveDir}/${vars(db_name)}.enc




