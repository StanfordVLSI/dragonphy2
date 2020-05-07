#---------------------------------------------------------
# set FloorPlan
#---------------------------------------------------------
floorPlan -site core -r 1 $utill 0 0 0 0
set raw_area [dbGet top.fPlan.area]
set FP_height [expr 2*$cell_height]
set FP_width [expr ($raw_area/$FP_height/$cell_grid)*$cell_grid]

floorPlan -site core -s $FP_width $FP_height 0 0 0 0 


set ff_area [get_property [get_cells arb_out_reg] area]
set ff_width [expr round($ff_area/$cell_height/$cell_grid)*$cell_grid]

set delay_area [get_property [get_cells idel_PI/iinv_PI2_dont_touch/U1] area]
set delay_width [expr round($delay_area/$cell_height/$cell_grid)*$cell_grid]

set mux_area [get_property [get_cells iblender_1b/IMUX0_dont_touch/IMUX2] area]
set mux_width [expr round($mux_area/$cell_height/$cell_grid)*$cell_grid]

set buft_area [get_property [get_cells iinc_delay/itri_buff1_dont_touch] area]
set buft_width [expr round($buft_area/$cell_height/$cell_grid)*$cell_grid]

#set FP_height [expr 2*$cell_height]
#set FP_width [expr $DB_width+$welltap_width+$ff_width+$delay_width+$mux_width+$buft_width]
#floorPlan -site core -s $FP_width $FP_height 0 0 0 0 



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
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width/2]  -cellInterval [expr $FP_width] -prefix WELLTAP


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
#set_db add_stripes_stacked_via_bottom_layer M2
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
  -nets [list $gnd_name $pwr_name]

deleteInst WELL*

addWellTap -cell TAPCELLBWP16P90 -cellInterval $FP_width -prefix WELLTAP

placeInstance arb_out_reg $welltap_width 0 R180
placeInstance idel_PI/iinv_PI1_dont_touch/U1 [expr $welltap_width+$ff_width] 0 
placeInstance idel_PI/iinv_PI2_dont_touch/U1 [expr $welltap_width+$ff_width] $cell_height 

placeInstance iblender_1b/IMUX0_dont_touch/IMUX2 [expr $FP_width-$welltap_width-$buft_width-$mux_width] 0
placeInstance iblender_1b/IMUX1_dont_touch/IMUX2 [expr $FP_width-$welltap_width-$buft_width-$mux_width] $cell_height

placeInstance iinc_delay/itri_buff1_dont_touch/u__tmp100 [expr $FP_width-$welltap_width-$buft_width] 0
placeInstance iinc_delay/itri_buff2_dont_touch/u__tmp100 [expr $FP_width-$welltap_width-$buft_width] $cell_height



createRouteBlk -box 0 $FP_height $FP_width [expr $FP_height-$cell_height/2] -layer 6
#########################
## vertical power strip #
#########################
addStripe -nets {VDD} \
  -layer M7 -direction vertical -width [expr $AVDD_M7_width/2] -spacing [expr $AVDD_M7_width/2] -start_offset [expr $welltap_width/2] -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape }  -extend_to all_domains -create_pins 1 

addStripe -nets {VSS} \
  -layer M7 -direction vertical -width [expr $AVDD_M7_width/2] -spacing [expr $AVDD_M7_width/2] -start_offset [expr $welltap_width/2] -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to all_domains -create_pins 1 

deleteRouteBlk -all


##--------------------------------------------
# Load IO file #
##--------------------------------------------
#loadIoFile ${ioDir}/${DesignName}.io


##--------------------------------------------
# Pin position setting
##--------------------------------------------
set arb_in_width [expr $AVDD_M7_width/2]
setPinAssignMode -pinEditInBatch true

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 3 -layer 3 -spreadType start -spacing $metal_space -offsetStart [expr $welltap_width+$ff_width] -pin chain_in
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 1 -layer 3 -spreadType start -spacing $metal_space -offsetStart [expr $welltap_width+$ff_width] -pin chain_out

editPin -pinWidth $PI_MS_net_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 2 -spreadType center -spacing $metal_space -pin buf_out

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 0 -layer 2 -spreadType center -spacing [expr 2*$metal_space] -pin {arb_out en_mixer inc_del en_arb}

editPin -pinWidth [expr $arb_in_width] -pinDepth [expr $FP_height] -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 3 -layer 5 -spreadType start -spacing [expr 2*$metal_space] -offsetStart [expr $FP_width/2] -pin arb_in


#------------------------------------------------------
set RUN_LAYOUT_ONLY 1
#------------------------------------------------------


##------------------------------------------------------
## pnr variable file-out ##
##------------------------------------------------------
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "${DesignName}_width:$FP_width\n"
puts -nonewline $fid "${DesignName}_height:$FP_height\n"
puts -nonewline $fid "${DesignName}_M7_power_offset:[expr $welltap_width/2]\n"
close $fid

#saveDesign ${saveDir}/${vars(db_name)}.enc




