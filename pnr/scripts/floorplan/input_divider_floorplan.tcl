
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

#---------------------------------------------------------
# set FloorPlan
#---------------------------------------------------------
floorPlan -site core -r 1 0.5 0 0 0 0
set raw_area [dbGet top.fPlan.area]
set FP_height [expr 10*$cell_height]
set FP_width [expr ($raw_area/$FP_height/$cell_grid)*$cell_grid+4*($DB_width+$welltap_width)]
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



###############
# P/G connect #
###############
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VDD -type tiehi
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VSS -type tielo
globalNetConnect VDD -type pgpin -pin VPP -inst *
globalNetConnect VSS -type pgpin -pin VBB -inst *


addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width/2]  -cellInterval $FP_width -prefix WELLTAP


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

addEndCap -coreBoundaryOnly
addWellTap -cell TAPCELLBWP16P90 -cellInterval $FP_width -prefix WELLTAP
       


#######
# NDR #
#######
#add_ndr -name NDR_5W2S -spacing {M1:M2 0.05 M3 0.05 M4:M7 0.05} -width {M1:M2 0.18 M3 0.18 M4:M7 0.18} 
#setAttribute -net in -non_default_rule NDR_5W2S
#setAttribute -net in_mdll -non_default_rule NDR_5W2S
#setAttribute -net out -non_default_rule NDR_5W2S
#setAttribute -net out_meas -non_default_rule NDR_5W2S



###########
# IO file #
###########
#loadIoFile ./data/input_buffer.io



#--------------------------------------------
# Pin position setting
##--------------------------------------------
setPinAssignMode -pinEditInBatch true

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 3 -layer 5 -spreadType center -spacing $metal_space -pin in

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 3 -layer 5 -spreadType start -offsetStart [expr $welltap_width] -spacing $metal_space -pin in_mdll

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 1 -layer 3 -spreadType center -spacing $metal_space -pin out

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 6 -spreadType center -spacing $metal_space -pin out_meas

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 3 -layer 3 -spreadType range -spacing $metal_space -offsetStart [expr $welltap_width+$DB_width] -offsetEnd [expr $FP_width-($FP_width/2-$welltap_width)] -pin {bypass_div bypass_div2 en sel_clk_source} 

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 3 -layer 3 -spreadType range -spacing $metal_space -offsetStart [expr $welltap_width+$DB_width] -offsetEnd [expr $FP_width-($FP_width/2-$welltap_width)] -pin {en_meas ndiv*} 





##------------------------------------------------------
set RUN_LAYOUT_ONLY 0
##------------------------------------------------------


#########################
## vertical power strip #
#########################
createRouteBlk -box 0 0 $FP_width [expr $cell_height/4] -name M7_blk_bot -layer 7
#createRouteBlk -box 0 $FP_height $FP_width [expr $FP_height-$cell_height/2] -name M7_blk_bot -layer 7


addStripe -nets {VSS VDD} \
  -layer M7 -direction vertical -width [expr $DVDD_M7_width] -spacing [expr $AVDD_M7_space] -start_offset $DB_width -set_to_set_distance [expr $FP_width] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {VDD VSS} \
  -layer M7 -direction vertical -width [expr $DVDD_M7_width] -spacing [expr $AVDD_M7_space] -start_offset $DB_width -set_to_set_distance [expr $FP_width] -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


addStripe -nets {VSS VDD} \
  -layer M7 -direction vertical -width [expr $DVDD_M7_width] -spacing [expr $AVDD_M7_space] -start_offset [expr $FP_width/2-$DVDD_M7_width-$AVDD_M7_space/2] -set_to_set_distance [expr $FP_width] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


deleteRouteBlk -all

addStripe -nets {VDD} \
  -layer M8 -direction horizontal -width $AVDD_M8_width -spacing $FP_height -start_offset [expr $cell_height] -set_to_set_distance $FP_width  -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -extend_to design_boundary -create_pins 1  


addStripe -nets {VSS} \
  -layer M8 -direction horizontal -width $AVDD_M8_width -spacing $FP_height -start_offset [expr $cell_height] -set_to_set_distance $FP_width  -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -extend_to design_boundary -create_pins 1  





