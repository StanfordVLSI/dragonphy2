
#---------------------------------------------------------
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
       
                                    
set boundary_width  [expr 4*$welltap_width+2*$DB_width]
set origin_x $boundary_width
set origin_y [expr 4*$cell_height]

##############
# Floor Plan #
##############
set FP_width [expr 2*$boundary_width+$diff_amp_width]
set FP_height [expr 26*$cell_height]
floorPlan -site core -s $FP_width $FP_height 0 0 0 0


######################
## Add boundary cell # 
######################
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

#addEndCap -coreBoundaryOnly

placeInstance I0 [expr $origin_x] [expr $origin_y] MX
addEndCap
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width/2]  -cellInterval $FP_width -prefix WELLTAP

###############
# P/G connect #
###############
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VDD -type tiehi
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VSS -type tielo
globalNetConnect VDD -type pgpin -pin VPP -inst *
globalNetConnect VSS -type pgpin -pin VBB -inst *


#########################
## Stdcell power stripe #
#########################
#set_db add_stripes_stacked_via_bottom_layer M1
#set_db add_stripes_stacked_via_top_layer M2
addStripe -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -master "*"   \
  -merge_stripes_value 0.045   \
  -extend_to design_boundary \
  -create_pins 1 \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -nets [list VDD VSS]

deleteInst WELL*

addWellTap -cell TAPCELLBWP16P90 -cellInterval $FP_width -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -cellInterval $FP_width -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -cellInterval $FP_width -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -cellInterval $FP_width -prefix WELLTAP
       


#######
# NDR #
#######
add_ndr -name NDR_5W2S -spacing {M1:M2 0.05 M3 0.05 M4:M7 0.05} -width {M1:M2 0.18 M3 0.18 M4:M7 0.18} 

setAttribute -net in_aux -non_default_rule NDR_5W2S
setAttribute -net out -non_default_rule NDR_5W2S
setAttribute -net out_meas -non_default_rule NDR_5W2S



###########
# IO file #
###########
loadIoFile ./data/input_buffer.io

createRouteBlk -box 0 0 $FP_width $cell_height -name M7_blk_bot -layer 7
createRouteBlk -box 0 $FP_height $FP_width [expr $FP_height-$cell_height] -name M7_blk_bot -layer 7

#########################
## vertical power strip #
#########################
addStripe -nets {VSS} \
  -layer M3 -direction vertical -width 0.36 -spacing 0.5 -start_offset 3 -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M3 -block_ring_top_layer_limit M3 -block_ring_bottom_layer_limit M3 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {VDD} \
  -layer M3 -direction vertical -width 0.36 -spacing 0.5 -start_offset 3 -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M3 -block_ring_top_layer_limit M3 -block_ring_bottom_layer_limit M3 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {VSS VDD} \
  -layer M7 -direction vertical -width 1 -spacing 0.5 -start_offset 0.3 -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {VDD VSS} \
  -layer M7 -direction vertical -width 1 -spacing 0.5 -start_offset 0.3 -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {VSS VDD} \
  -layer M7 -direction vertical -width 1 -spacing 0.5 -start_offset 7.75 -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -area {0 9 18 14.976}

addStripe -nets {VSS VDD} \
  -layer M8 -direction horizontal -width $AVDD_M8_width -spacing $AVDD_M8_space -start_offset 0.8 -set_to_set_distance $FP_width -stop_offset 9 -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -extend_to design_boundary -create_pins 1  

addStripe -nets {VDD VSS} \
  -layer M8 -direction horizontal -width $AVDD_M8_width -spacing $AVDD_M8_space -start_offset 3.525 -set_to_set_distance $FP_width -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -extend_to design_boundary -create_pins 1  

createPlaceBlockage -box 0 0 $FP_width  [expr $origin_y+$diff_amp_height] -type hard




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

setEdit -layer_vertical M5
setEdit -width_vertical 0.2

setEdit -nets amp_out
editAddRoute 13.06 [expr $origin_y+$diff_amp_height-$cell_height]
editCommitRoute 13.06 [expr $origin_y+$diff_amp_height]




