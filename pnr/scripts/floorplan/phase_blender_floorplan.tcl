
set blender_Nunit 16

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
# calculate cell widths
#---------------------------------------------------------
set mux_blender_area [get_property [get_cells imux_0] area]
set mux_blender_width [expr round($mux_blender_area/$cell_height/$cell_grid)*$cell_grid]

set inbuf1_area [get_property [get_cells iin_buf_odd1] area]
set inbuf1_width [expr round($inbuf1_area/$cell_height/$cell_grid)*$cell_grid]
set inbuf2_area [get_property [get_cells iin_buf_odd2] area]
set inbuf2_width [expr round($inbuf2_area/$cell_height/$cell_grid)*$cell_grid]
set outbuf1_area [get_property [get_cells iout_buf1] area]
set outbuf1_width [expr round($outbuf1_area/$cell_height/$cell_grid)*$cell_grid]
set outbuf2_area [get_property [get_cells iout_buf2] area]
set outbuf2_width [expr round($outbuf2_area/$cell_height/$cell_grid)*$cell_grid]


#---------------------------------------------------------
# space for routing
#---------------------------------------------------------
set boundary_width [expr $DB_width+$welltap_width]
set boundary_height [expr $cell_height]


##---------------------------------------------------------
## set FloorPlan
##---------------------------------------------------------

set FP_width [expr 2*$boundary_width++$inbuf1_width+$inbuf2_width+$mux_blender_width+$outbuf2_width]
set FP_height [expr $blender_Nunit*$cell_height+2*$boundary_height]
#set FP_height [expr ceil((40)/$cell_height/2)*2*$cell_height]

floorPlan -site core -s $FP_width $FP_height 0 0 0 0



##---------------------------------------------------------
## welltap / boundary cell settings
##---------------------------------------------------------
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


addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width/2]  -cellInterval $FP_width -prefix WELLTAP

##---------------------------------------------------------
## M1 PG connect
##---------------------------------------------------------
globalNetConnect VDD -type tiehi -override
globalNetConnect VSS -type tielo -override
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override
globalNetConnect VDD -type pgpin -pin VPP -inst * -override
globalNetConnect VSS -type pgpin -pin VBB -inst * -override

addStripe -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -master "*"   \
  -merge_stripes_value 0.045   \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -extend_to design_boundary \
  -nets [list VDD VSS] 

deleteInst WELL* 
addEndCap 

addWellTap -cell TAPCELLBWP16P90 -inRowOffset 0 -cellInterval $FP_width -prefix WELLTAP





placeInstance iin_buf_even1 [expr $boundary_width] [expr $boundary_height+4*$cell_height]
placeInstance iin_buf_even2 [expr $boundary_width+$inbuf1_width] [expr $boundary_height+4*$cell_height] 

placeInstance iin_buf_odd1 [expr $boundary_width] [expr $boundary_height+11*$cell_height] 
placeInstance iin_buf_odd2 [expr $boundary_width+$inbuf1_width] [expr $boundary_height+11*$cell_height]


for { set k 0} {$k < $blender_Nunit} {incr k} {
	placeInstance imux_$k [expr $boundary_width+$inbuf1_width+$inbuf2_width] [expr $boundary_height+$k*$cell_height]
}

placeInstance iout_buf1  [expr $boundary_width+$inbuf1_width+$inbuf2_width+$mux_blender_width] [expr $boundary_height+7*$cell_height]
placeInstance iout_buf2 [expr $boundary_width+$inbuf1_width+$inbuf2_width+$mux_blender_width] [expr $boundary_height+8*$cell_height] 




addStripe -nets {VDD} \
  -layer M7 -direction vertical -width 0.8 -spacing 1 -start_offset $DB_width -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {VSS} \
  -layer M7 -direction vertical -width 0.8 -spacing 1 -start_offset $DB_width -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


##--------------------------------------------
## IO file #
##--------------------------------------------
#loadIoFile ${ioDir}/${DesignName}.io

set ph_in0_offset [get_property [get_pins iin_buf_odd1/I] y_coordinate]
set ph_in1_offset [get_property [get_pins iin_buf_even1/I] y_coordinate]

setPinAssignMode -pinEditInBatch true

editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing [expr $metal_space] -offsetStart $ph_in0_offset -pin {ph_in[0]}

editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing [expr $metal_space] -offsetStart $ph_in1_offset -pin {ph_in[1]}


editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -spreadDirection clockwise -edge 0 -layer 2 -spreadType range -offsetEnd [expr 6*$cell_height] -offsetStart [expr 6*$cell_height] -pin {thm_sel_bld* } 


editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 1 -layer 3 -spreadType start -spacing [expr $metal_space] -offsetStart [expr $boundary_width+$outbuf2_width/2] -pin {ph_out}



saveIoFile -locations ${ioDir}/${DesignName}.io




#------------------------------------------------------
set RUN_LAYOUT_ONLY 1
##------------------------------------------------------

##------------------------------------------------------
## pnr variable file-out ##
##------------------------------------------------------
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "${DesignName}_width:$FP_width\n"
puts -nonewline $fid "${DesignName}_height:$FP_height\n"
close $fid

saveDesign ${saveDir}/${vars(db_name)}.enc






##---------------------------------------------------------
## specify ILM 
##---------------------------------------------------------




