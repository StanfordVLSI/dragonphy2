##---------------------------------------------------------
## load pnr variables
##---------------------------------------------------------
set fid [open "${pnrDir}/pnr_vars.txt" r]
set read_data [read -nonewline $fid]
close $fid

set pnr_data [split $read_data "\n"]
foreach block_data $pnr_data {
    set fields [split $block_data ":"]
    lassign $fields var_name var_value
set $var_name $var_value
}   

##---------------------------------------------------------
## set FloorPlan
##---------------------------------------------------------
floorPlan -site core -r 1 $utill 0 0 0 0
set raw_area [dbGet top.fPlan.area]
set FP_width $TDC_delay_chain_width
set FP_height [expr ceil($raw_area/$FP_width/$cell_height/2)*2*$cell_height]

floorPlan -site core -s $FP_width $FP_height 0 0 0 0


############
# P/G connect
############
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VDD -type tiehi
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VSS -type tielo
globalNetConnect VDD -type pgpin -pin VPP -inst *
globalNetConnect VSS -type pgpin -pin VBB -inst *

############
# Boundary cells
############

set FP_WTAP_S [expr $FP_width/2]
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

#addEndCap -coreBoundaryOnly
addWellTap -cell TAPCELLBWP16P90 -inRowOffset $FP_WTAP_S -cellInterval $FP_width -prefix WELLTAP


addStripe -nets { VDD VSS} \
  -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -merge_stripes_value 0.045   \
  -direction horizontal   \
  -extend_to design_boundary \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width  \
  -master "TAPCELL* BOUNDARY*"   


#--------------------------------------------
# IO file #
#--------------------------------------------
#loadIoFile ${ioDir}/${DesignName}.io


#---------------------------------------------
# set IO file
#---------------------------------------------
set in_pin_list "d_in[0]"
for { set k 1} {$k < $TDC_Nunit} {incr k} {
    lappend in_pin_list "d_in[$k]"
    }
setPinAssignMode -pinEditInBatch true
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -spreadDirection clockwise -edge 1 -layer 3 -spreadType range -offsetEnd $TDC_pin_spread_start -offsetStart $TDC_pin_spread_end -pin $in_pin_list

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr 2.5*$cell_height] -pin clk
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr 3.5*$cell_height] -pin sign_in


set wallace_adder_Nout [expr int(ceil(log10($TDC_Nunit)/log10(2)))]
set wallace_adder_outpin_offset [expr 1.5*$cell_height]


for { set k 0} {$k < $wallace_adder_Nout} {incr k} {
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr $wallace_adder_outpin_offset+($k)*$cell_height] -pin d_out[$k]
}
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr $wallace_adder_outpin_offset+($wallace_adder_Nout)*$cell_height] -pin sign_out

saveIoFile -locations ${ioDir}/${DesignName}.io



##--------------------------------------------
# power routing
##--------------------------------------------
addStripe -nets {VSS VDD} \
  -layer M7 -direction vertical -width $TDC_M7_width -spacing $TDC_M7_spacing -start_offset $TDC_M7_start_offset -stop_offset [expr $FP_width/2] -set_to_set_distance $TDC_M7_set_to_set -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {VSS VDD} \
  -layer M7 -direction vertical -width $TDC_M7_width -spacing $TDC_M7_spacing -start_offset [expr $TDC_M7_start_offset-$TDC_M7_width] -stop_offset [expr $FP_width/2] -set_to_set_distance $TDC_M7_set_to_set -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addWellTap -cell TAPCELLBWP16P90 -cellInterval $FP_width -prefix WELLTAP



##------------------------------------------------------
set RUN_LAYOUT_ONLY 0
##------------------------------------------------------

##------------------------------------------------------
## pnr variable file-out ##
##------------------------------------------------------
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "${DesignName}_width:$FP_width\n"
puts -nonewline $fid "${DesignName}_height:$FP_height\n"
puts -nonewline $fid "wallace_adder_Nout:$wallace_adder_Nout\n"
puts -nonewline $fid "wallace_adder_outpin_offset:$wallace_adder_outpin_offset\n"
close $fid

saveDesign ${saveDir}/${vars(db_name)}.enc

