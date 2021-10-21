
set tri_inv_merged_width 5.22
#set tri_inv_merged_area [get_property [get_cells Itri_inv_merged1] area]
#set tri_inv_merged_width [expr round($tri_inv_merged_area/$cell_height/$cell_grid)*$cell_grid]

set ff_area [get_property [get_cells Iff_ctl] area]
set ff_width [expr round($ff_area/$cell_height/$cell_grid)*$cell_grid]

set and3_area [get_property [get_cells Iand3] area]
set and3_width [expr round($and3_area/$cell_height/$cell_grid)*$cell_grid]

set xc3_area [get_property [get_cells Ixc3] area]
set xc3_width [expr round($xc3_area/$cell_height/$cell_grid)*$cell_grid]
set xc5_area [get_property [get_cells Ixc5] area]
set xc5_width [expr round($xc5_area/$cell_height/$cell_grid)*$cell_grid]
set xc7_area [get_property [get_cells Ixc7] area]
set xc7_width [expr round($xc7_area/$cell_height/$cell_grid)*$cell_grid]

set boundary_width $welltap_width
set boundary_height $cell_height


##############
# Floor Plan #
##############
set FP_width [expr 2*$boundary_width+max($tri_inv_merged_width,2*($xc7_width+$ff_width))]
set FP_height [expr 2*$boundary_height+4*$cell_height ]

floorPlan -site core -s $FP_width $FP_height 0 0 0 0 

####################
## welltap settings# 
####################
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
  -rule ${FP_WTAP_S} \
  -bottom_tap_cell BOUNDARY_NTAPBWP16P90 \
  -top_tap_cell    BOUNDARY_PTAPBWP16P90 \
  -block_boundary_only true \
  -cell TAPCELLBWP16P90

############## M1 power for 
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VDD -type pgpin -pin VPP -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * 
globalNetConnect VSS -type pgpin -pin VBB -inst *



addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width/2] -cellInterval $FP_width -prefix WELLTAP

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
  -nets {VDD VSS} 

deleteInst WELL*


addWellTap -cell TAPCELLBWP16P90 -inRowOffset 0 -cellInterval $FP_width -prefix WELLTAP


#################
# pre placement #
#################
placeInstance Itri_inv_merged1 [expr ($FP_width-$tri_inv_merged_width)/2] 0 
placeInstance Itri_inv_merged2 [expr ($FP_width-$tri_inv_merged_width)/2] [expr $cell_height] MY

placeInstance Ixc2  [expr $FP_width/2+$xc5_width] [expr 4*$cell_height] R180
placeInstance Ixc3  [expr $FP_width/2-$xc5_width-$xc3_width] [expr 4*$cell_height]
placeInstance Ixc4  [expr $FP_width/2] [expr 4*$cell_height] R180
placeInstance Ixc5  [expr $FP_width/2-$xc5_width] [expr 4*$cell_height]
placeInstance Ixc6  [expr $FP_width/2] [expr 3*$cell_height] MY 
placeInstance Ixc7  [expr $FP_width/2-$xc7_width] [expr 3*$cell_height]

placeInstance Iff_out  [expr $FP_width-$boundary_width-$ff_width] [expr 3*$cell_height]
placeInstance Iff_ctl  [expr $FP_width-$boundary_width-$ff_width] [expr 5*$cell_height] MY
placeInstance Iff_init [expr $boundary_width] [expr 5*$cell_height]
placeInstance Iand3 [expr $FP_width-$boundary_width-$and3_width] [expr 4*$cell_height] R180  

##--------------------------------------------
# Load IO file #
##--------------------------------------------
#loadIoFile ${ioDir}/${DesignName}.io



#createRouteBlk -box 0 0 [expr $FP_width] $cell_grid  -layer {1 2 3 4 5 6 7 8 9} -name blk_bot
#createRouteBlk -box 0 0 $cell_grid $FP_height -layer {1 2 3 4 5 6 7 8 9} -name blk_left
#createRouteBlk -box $FP_width 0 [expr $FP_width-$cell_grid] $FP_height -layer {1 2 3 4 5 6 7 8 9} -name blk_right
#createRouteBlk -box 0 [expr $FP_height-$cell_grid] [expr $FP_width]  [expr $FP_height]  -layer {1 2 3 4 5 6 7 8 9} -name blk_top
#deleteRouteBlk -name blk_right

setPinAssignMode -pinEditInBatch true
assignIoPins -pin {slow rstb init_pulse rstb_ff samp Z init} 

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -unit MICRON -spreadDirection clockwise -edge 2 -layer 2 -spreadType start -spacing [expr 3*$metal_space] -offsetStart [expr $cell_height] -pin {slow rstb init_pulse rstb_ff samp Z init} 

assignIoPins -pin {IN OUT} 

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 3 -layer 3 -spreadType start -spacing 0 -offsetStart [expr $FP_width/2] -pin {IN}
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 1 -layer 3 -spreadType start -spacing 0 -offsetStart [expr $FP_width/2] -pin {OUT}

set M7_width 0.6
set M7_space 1.8
set Dcell_M7_offset [expr $FP_width/2-$M7_space/2-$M7_width]

addStripe -nets {VDD VSS} \
  -layer M7 -direction vertical -width $M7_width -spacing $M7_space -start_offset $Dcell_M7_offset   -set_to_set_distance [expr $FP_width] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


uiSetTool addWire
setEdit -layer_minimum M1
setEdit -layer_maximum AP
setEdit -force_regular 1
getEdit -snap_to_track_regular
getEdit -snap_to_pin
setEdit -force_special 1
getEdit -snap_to_track
getEdit -snap_special_wire
getEdit -align_wire_at_pin
getEdit -snap_to_row
getEdit -snap_to_pin
setViaGenMode -ignore_DRC false
setViaGenMode -use_fgc 1
setViaGenMode -use_cce false
setEdit -layer_vertical M7
setEdit -width_vertical [expr $M7_width]


setEdit -nets VDD
editAddRoute 1.8 0
editCommitRoute [expr $welltap_width/2+$AVDD_M7_width/4] $FP_height

setEdit -nets VSS
editAddRoute [expr $FP_width-(1.8)] 0
editCommitRoute [expr $FP_width-(1.8)] $FP_height




##------------------------------------------------------
set RUN_LAYOUT_ONLY 1
##------------------------------------------------------

###########################
## pnr variable file-out ##
###########################
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "${DesignName}_width:$FP_width\n"
puts -nonewline $fid "${DesignName}_height:$FP_height\n"
puts -nonewline $fid "Dcell_M7_offset:$Dcell_M7_offset\n"
close $fid

saveDesign ${saveDir}/${vars(db_name)}.enc










