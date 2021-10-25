set Ntri_inv 8

set tri_inv_width 0.45

set ff_area [get_property [get_cells Iff_ctl] area]
set ff_width [expr round($ff_area/$cell_height/$cell_grid)*$cell_grid]

set xc3_area [get_property [get_cells Ixc3] area]
set xc3_width [expr round($xc3_area/$cell_height/$cell_grid)*$cell_grid]
set xc5_area [get_property [get_cells Ixc5] area]
set xc5_width [expr round($xc5_area/$cell_height/$cell_grid)*$cell_grid]
set xc7_area [get_property [get_cells Ixc7] area]
set xc7_width [expr round($xc7_area/$cell_height/$cell_grid)*$cell_grid]

set boundary_width $DB_width
set boundary_height $cell_height


##############
# Floor Plan #
##############
set FP_width [expr 2*$boundary_width+$ff_width+2*$tri_inv_width]
set FP_height [expr 2*$boundary_height+($Ntri_inv)*$cell_height ]

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


#################
# pre placement #
#################

for { set k 0} {$k < $Ntri_inv} {incr k} {
	set x_cor [expr $boundary_width]
	set y_cor [expr $boundary_height+($k+1)*$cell_height] 
	placeInstance Itri_inv1_$k\_ $x_cor $y_cor
}
for { set k 0} {$k < $Ntri_inv} {incr k} {
	set x_cor [expr $FP_width-$boundary_width-$tri_inv_width]
	set y_cor [expr $boundary_height+($k+1)*$cell_height] 
	placeInstance Itri_inv2_$k\_ $x_cor $y_cor
}

placeInstance Iff_out  [expr $FP_width-$boundary_width-$ff_width] $boundary_height MY
placeInstance Iff_ctl  [expr $boundary_width+$tri_inv_width] [expr $boundary_height+$cell_height]
placeInstance Inor3  $boundary_width [expr $cell_height] 

placeInstance Ixc2  [expr $boundary_width+$tri_inv_width] [expr ($Ntri_inv/2+3)*$cell_height] MY 
placeInstance Ixc3  [expr $boundary_width+$tri_inv_width] [expr ($Ntri_inv/2)*$cell_height] R180
placeInstance Ixc4  [expr $boundary_width+$tri_inv_width] [expr ($Ntri_inv/2+2)*$cell_height] 
placeInstance Ixc5  [expr $boundary_width+$tri_inv_width] [expr ($Ntri_inv/2+1)*$cell_height] 
placeInstance Ixc6  [expr $boundary_width+$tri_inv_width+$xc3_width] [expr ($Ntri_inv/2+2)*$cell_height] 
placeInstance Ixc7  [expr $boundary_width+$tri_inv_width+$xc3_width] [expr ($Ntri_inv/2+1)*$cell_height] 


##--------------------------------------------
# Load IO file #
##--------------------------------------------

createRouteBlk -box 0 0 [expr $boundary_width]  [expr $FP_height]  -layer {1 2 3 4 5 6 7 8 9} -name blk_right
createRouteBlk -box $FP_width 0 [expr $FP_width-$boundary_width]  [expr $FP_height]  -layer {1 2 3 4 5 6 7 8 9} -name blk_right

setPinAssignMode -pinEditInBatch true
assignIoPins -align -pin {Z init_pulse rstb_ff samp slow }

deleteRouteBlk -all

assignIoPins -pin {init rst IN OUT}

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -edge 1 -layer 3 -spreadType start -spacing $metal_space -offsetStart [expr $FP_width/2] -pin init

#editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr 4*$cell_height] -pin rst

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -edge 0 -layer 2 -spreadType start -spacing $cell_height -offsetStart [expr 4*$cell_height] -pin {IN}

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -unit MICRON -spreadDirection clockwise -edge 2 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr 4*$cell_height] -pin OUT


createPlaceBlockage -box 0 0 $boundary_width $FP_height
createPlaceBlockage -box $FP_width 0 [expr $FP_width-$boundary_width] $FP_height
createPlaceBlockage -box 0 0 $FP_width $boundary_height
createPlaceBlockage -box 0 $FP_height $FP_width [expr $FP_height-$boundary_height]


#createInstGroup grp0 -region $boundary_width [expr $Ntri_inv/2*$cell_height] $FP_width [expr ($Ntri_inv/2+2)*$cell_height] 
#addInstToInstGroup grp0 {Ixc*}



##------------------------------------------------------
set RUN_LAYOUT_ONLY 1
##------------------------------------------------------

###########################
## pnr variable file-out ##
###########################
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "${DesignName}_width:$FP_width\n"
puts -nonewline $fid "${DesignName}_height:$FP_height\n"
close $fid

saveDesign ${saveDir}/${vars(db_name)}.enc










