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


set Dcell_width 7.92
set Dcell_height [expr 4*$cell_height]
set boundary_width $welltap_width
set boundary_height 0
set Dcell_space [expr 2*$welltap_width]

##############
# Floor Plan #
##############
set FP_width [expr 2*$boundary_width+4*$Dcell_width+$Dcell_space+2*$welltap_width]
set FP_height [expr 2*$boundary_height+15*$Dcell_height ]
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

 #M7 power
set M7_width 0.6
set Dcell_M7_offset [expr $Dcell_inv_inv_width/2-2*$M7_width]

addStripe -nets {VDD VSS} \
  -layer M7 -direction vertical -width $M7_width -spacing [expr 2*$M7_width] -start_offset [expr $boundary_width+$Dcell_M7_offset]  -set_to_set_distance [expr $Dcell_inv_inv_width+$welltap_width] -stop_offset [expr $FP_width/2] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1 

addStripe -nets {VDD VSS} \
  -layer M7 -direction vertical -width $M7_width -spacing [expr 2*$M7_width] -start_offset [expr $boundary_width+$Dcell_M7_offset]  -set_to_set_distance [expr $Dcell_inv_inv_width+$welltap_width] -stop_offset [expr $FP_width/2]  -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1 



#################
# pre placement #
#################
for { set k 0} {$k < 9} {incr k} {
	if {$k == 0} {	
        set x_cor [expr $boundary_width]
        set y_cor [expr $boundary_height+6*$Dcell_height+(${k}-1)*$Dcell_height]
            placeInstance Iosc_core/Inand_inv $x_cor $y_cor 
	} else {
        set x_cor [expr $boundary_width]
        set y_cor [expr $boundary_height+6*$Dcell_height+(${k}-1)*$Dcell_height]
            placeInstance Iosc_core/Iinv_inv_$k\_ $x_cor $y_cor 
	}
}

set k 9 
		set x_cor [expr $welltap_width+$boundary_width+$Dcell_width+(${k}-9)*($Dcell_width+$Dcell_space)]
        set y_cor [expr $boundary_height+14*$Dcell_height]
            placeInstance Iosc_core/Iinv_inv_$k\_ $x_cor $y_cor  
set k 10 
		set x_cor [expr $welltap_width+$boundary_width+$Dcell_width+(${k}-9)*($Dcell_width+$Dcell_space)]
        set y_cor [expr $boundary_height+14*$Dcell_height]
            placeInstance Iosc_core/Iinv_inv_$k\_ $x_cor $y_cor R180

for { set k 11} {$k < 24} {incr k} {
        set x_cor [expr 2*$welltap_width+$boundary_width+$Dcell_width+(10-9)*($Dcell_width+$Dcell_space)+$Dcell_width]
        set y_cor [expr $boundary_height+13*$Dcell_height-(${k}-11)*$Dcell_height]
            placeInstance Iosc_core/Iinv_inv_$k\_ $x_cor $y_cor R180 
}

set k 24
        set x_cor [expr $welltap_width+$boundary_width+$Dcell_width+(10-9)*($Dcell_width+$Dcell_space)-(${k}-24)*($Dcell_width+$Dcell_space)]
        set y_cor [expr $boundary_height]
            placeInstance Iosc_core/Iinv_inv_$k\_ $x_cor $y_cor R180 
set k 25
        set x_cor [expr $welltap_width+$boundary_width+$Dcell_width+(10-9)*($Dcell_width+$Dcell_space)-(${k}-24)*($Dcell_width+$Dcell_space)]
        set y_cor [expr $boundary_height]
            placeInstance Iosc_core/Iinv_nand $x_cor $y_cor 

for { set k 26} {$k < 30} {incr k} {
        set x_cor [expr $boundary_width]
        set y_cor [expr $boundary_height+$Dcell_height+(${k}-26)*$Dcell_height]
            placeInstance Iosc_core/Iinv_inv_$k\_ $x_cor $y_cor 
}


placeInstance Iosc_core/Inand_skew [expr $FP_width/2+$Dcell_inv_inv_width/2] [expr $boundary_height+$Dcell_inv_inv_height+$cell_height] MX 
placeInstance Iosc_core/Imux_samp [expr $FP_width/2+$welltap_width] [expr $boundary_height+4*$Dcell_inv_inv_height] MY 



addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $boundary_width+$Dcell_width] -cellInterval [expr 2*$FP_width] -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $welltap_width+$boundary_width+2*$Dcell_width] -cellInterval [expr 2*$FP_width] -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $welltap_width+$boundary_width+2*$Dcell_width+$welltap_width] -cellInterval $FP_width -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($boundary_width+$Dcell_width+$welltap_width)] -cellInterval $FP_width -prefix WELLTAP

createPlaceBlockage -box 0 0 [expr $boundary_width+$Dcell_width] $FP_height
createPlaceBlockage -box $FP_width 0 [expr $FP_width-($boundary_width+$Dcell_width)] $FP_height
createPlaceBlockage -box 0 0 $FP_width [expr $boundary_height+$Dcell_height]
createPlaceBlockage -box 0 $FP_height $FP_width [expr $FP_height-($boundary_height+$Dcell_height)]






#createInstGroup grp0 -region [expr $FP_width/2-5] [expr $FP_height/2-2] [expr $FP_width/2]  [expr $FP_height/2+2] 
#addInstToInstGroup grp0 {Iinput_network/I159 Iinput_network/I200 Iinput_network/Inor_in Iinput_network/Inand_in Iinput_network/I198 Iinput_network/I201  Iinput_network/Inand_lat1 Iinput_network/Inand_lat2 Iinput_network/I212 Iinput_network/I31 Iinput_network/I218 Iinput_network/I224 }


set ff_area [get_property [get_cells Iinput_network/Iff_in1] area]
set ff_width [expr round($ff_area/$cell_height/$cell_grid)*$cell_grid]
set lat_area [get_property [get_cells Iinput_network/Inand_lat1] area]
set lat_width [expr round($lat_area/$cell_height/$cell_grid)*$cell_grid]
set inv_in_area [get_property [get_cells Iinput_network/Iinv_in1] area]
set inv_in_width [expr round($inv_in_area/$cell_height/$cell_grid)*$cell_grid]



set group_origin_x [expr $boundary_width+$Dcell_width + 3.5*$welltap_width]

placeInstance Iinput_network/Iff_in1 [expr $group_origin_x] [expr $FP_height/2-$cell_height]
placeInstance Iinput_network/Iff_in2 [expr $group_origin_x] [expr $FP_height/2]

placeInstance Iinput_network/Inand_lat1 [expr $group_origin_x+$ff_width] [expr $FP_height/2-$cell_height]
placeInstance Iinput_network/Inand_lat2 [expr $group_origin_x+$ff_width] [expr $FP_height/2]
placeInstance Iinput_network/Iinv_lat1 [expr $group_origin_x+$ff_width+$lat_width] [expr $FP_height/2-$cell_height]
placeInstance Iinput_network/Iinv_lat2 [expr $group_origin_x+$ff_width+$lat_width] [expr $FP_height/2]


placeInstance Iinput_network/Inor_in [expr $group_origin_x+$ff_width] [expr $FP_height/2-2*$cell_height]
placeInstance Iinput_network/Inand_in [expr $group_origin_x+$ff_width] [expr $FP_height/2+$cell_height]

placeInstance Iinput_network/Iinv_in1 [expr $FP_width/2-$welltap_width-$inv_in_width] [expr $FP_height/2-2*$cell_height]
placeInstance Iinput_network/Iinv_in2 [expr $FP_width/2-$welltap_width-$inv_in_width] [expr $FP_height/2+$cell_height]



placeInstance Iinput_network/Iff_sign  [expr $FP_width/2-$welltap_width-$ff_width] [expr $FP_height/2-$cell_height]


##--------------------------------------------
# Load IO file #
##--------------------------------------------
loadIoFile ${ioDir}/${DesignName}.io

#setPinAssignMode -pinEditInBatch true
#assignIoPins -pin {rstb clk TinP TinN ctl* ph* tdcout* signout*}

#editPin -pinWidth 0.12 -pinDepth [expr 4*$boundary_width+$Dcell_width] -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 6 -spreadType start -spacing [expr 3*$metal_space] -offsetStart [expr $FP_height/2] -pin {clk}
#editPin -pinWidth 0.12 -pinDepth [expr 4*$boundary_width+$Dcell_width] -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 6 -spreadType start -spacing [expr 3*$metal_space] -offsetStart [expr $FP_height/2+$Dcell_height] -pin {TinP}
#editPin -pinWidth 0.12 -pinDepth [expr 4*$boundary_width+$Dcell_width] -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 6 -spreadType start -spacing [expr 3*$metal_space] -offsetStart [expr $FP_height/2-$Dcell_height] -pin {TinN}
#editPin -pinWidth $pin_width -pinDepth [expr 4*$boundary_width+$Dcell_width] -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 6 -spreadType start -spacing [expr $Dcell_height/2] -offsetStart [expr $boundary_height+2.5*$Dcell_height] -pin {signout tdcout* ctl* ph* rstb}


#sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M7 M1 } -nets { VDD VSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M1 } -deleteExistingRoutes -inst {Iosc_core/Iinv_inv_* Iosc_core/Inand_inv Iosc_core/Iinv_nand} 

set M4_blk_space 0.2
for { set k 0} {$k < 13} {incr k} {
	createRouteBlk -box  $boundary_width [expr $boundary_height+$Dcell_height+${k}*$Dcell_height+$M4_blk_space] [expr $boundary_width+$Dcell_width-0.2]  [expr $boundary_height+$Dcell_height+(${k}+1)*$Dcell_height-$M4_blk_space] -layer {4 5 6 7}
	createRouteBlk -box  [expr $FP_width-$boundary_width] [expr $boundary_height+$Dcell_height+${k}*$Dcell_height+$M4_blk_space] [expr $FP_width-($boundary_width+$Dcell_width-0.2)]  [expr $boundary_height+$Dcell_height+(${k}+1)*$Dcell_height-$M4_blk_space] -layer {4 5 6 7}

}

set M4_blk_space 0.3
for { set k 0} {$k < 2} {incr k} {
	createRouteBlk -box  [expr $boundary_width+$Dcell_width+$welltap_width+${k}*($Dcell_width+$Dcell_space)+0.2] [expr $boundary_height+$M4_blk_space] [expr $boundary_width+2*$Dcell_width+$welltap_width+${k}*($Dcell_width+$Dcell_space)-0.2]  [expr $boundary_height+$Dcell_height-$M4_blk_space] -layer {4 6 7}
	createRouteBlk -box  [expr $boundary_width+$Dcell_width+$welltap_width+${k}*($Dcell_width+$Dcell_space)+0.2] [expr $FP_height-($boundary_height+$M4_blk_space)] [expr $boundary_width+2*$Dcell_width+$welltap_width+${k}*($Dcell_width+$Dcell_space)-0.2]  [expr $FP_height-($boundary_height+$Dcell_height-$M4_blk_space)] -layer {4 6 7}
}

#createRouteBlk -box [expr $FP_width/2-$Dcell_width/2] $FP_height [expr $FP_width/2+$Dcell_width/2] [expr $FP_height-$M4_blk_space] -layer 4 
#createRouteBlk -box [expr $FP_width/2-$Dcell_width/2] 0 [expr $FP_width/2+$Dcell_width/2] [expr $M4_blk_space] -layer 4 


createRouteBlk -box 0 0 $FP_width $FP_height -layer 8 -name M8_blk


##------------------------------------------------------
set RUN_LAYOUT_ONLY 0
##------------------------------------------------------

###########################
## pnr variable file-out ##
###########################
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "${DesignName}_width:$FP_width\n"
puts -nonewline $fid "${DesignName}_height:$FP_height\n"
close $fid

saveDesign ${saveDir}/${vars(db_name)}.enc










