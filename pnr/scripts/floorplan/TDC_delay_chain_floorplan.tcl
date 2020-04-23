

floorPlan -site core -r 0.5 0.7 0 0 0 0
set FP_width [dbGet top.fPlan.box_sizex]
set FP_height [dbGet top.fPlan.box_sizey]

######################
## Add boundary cell # 
######################
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
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width/2-$welltap_width/2] -cellInterval [expr 2*$FP_width] -prefix WELLTAP


#######
# NDR #
#######


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
  -master "TAPCELL* BOUNDARY*"   \
  -merge_stripes_value 0.145   \
  -extend_to design_boundary \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -nets [list $gnd_name $pwr_name]

deleteInst WELL*
addWellTap -cell TAPCELLBWP16P90 -inRowOffset 0 -cellInterval [expr $FP_width] -prefix WELLTAP

#---------------------------------------------
# load IO file
#---------------------------------------------
loadIoFile ${ioDir}/TDC_delay_chain.io

#---------------------------------------------
# set IO file
#---------------------------------------------
#set TDC_pin_spread_start 1.0
#set TDC_pin_spread_end 1.0

#set out_pin_list "ff_out[0]"
#for { set k 1} {$k < $TDC_Nunit} {incr k} {
#	lappend out_pin_list "ff_out[$k]"
#}

#setPinAssignMode -pinEditInBatch true
#editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -spreadDirection counterclockwise -edge 3 -layer 3 -spreadType range -offsetEnd $TDC_pin_spread_end -offsetStart $TDC_pin_spread_start -pin $out_pin_list

#editPin -pinWidth $TDC_Hwire_width -pinDepth $welltap_width -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 4 -spreadType start -spacing $metal_space -offsetStart [expr $FP_height/2] -pin Tin
#editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr 1.5*$cell_height] -pin clk
#editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr 1.5*$cell_height] -pin del_out

#saveIoFile -locations ${ioDir}/${DesignName}.io


##--------------------------------------------
## power routing
##--------------------------------------------
#set TDC_M7_spacing [expr $ff_width+$TDC_M7_width+$TDC_Vwire_width+$metal_space-$TDC_M7_width]
#set TDC_M7_start_offset [expr $origin_x+($ff_width+$TDC_M7_width+$TDC_Vwire_width+$metal_space)]
#set TDC_M7_set_to_set [expr ($TDC_M7_width+$TDC_Vwire_width+$metal_space+$ff_width)*2]

#addStripe -nets {VSS VDD} \
  -layer M7 -direction vertical -width $TDC_M7_width -spacing $TDC_M7_spacing -start_offset $TDC_M7_start_offset -stop_offset [expr $FP_width/2] -set_to_set_distance $TDC_M7_set_to_set -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

#addStripe -nets {VSS VDD} \
  -layer M7 -direction vertical -width $TDC_M7_width -spacing $TDC_M7_spacing -start_offset [expr $TDC_M7_start_offset-$TDC_M7_width] -stop_offset [expr $FP_width/2] -set_to_set_distance $TDC_M7_set_to_set -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

#addStripe -nets {VDD VSS} \
# -layer M8 -direction horizontal -width 2 -spacing 1  -start_offset 0 -start_from top -set_to_set_distance 6 -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

#addStripe -nets {VSS VDD} \
# -layer M9 -direction vertical -width 4 -spacing 1  -start_offset 1.7 -start_from right -set_to_set_distance 10 -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


##------------------------------------------------------
#set_dont_touch *
set RUN_LAYOUT_ONLY 0
##------------------------------------------------------

###########################
## pnr variable file-out ##
###########################
#set fid [open "${pnrDir}/pnr_vars.txt" a]
#puts -nonewline $fid "${DesignName}_width:$FP_width\n"
#puts -nonewline $fid "${DesignName}_height:$FP_height\n"
#puts -nonewline $fid "TDC_Nunit:$TDC_Nunit\n"
#puts -nonewline $fid "TDC_M7_width:$TDC_M7_width\n"
#puts -nonewline $fid "TDC_M7_spacing:$TDC_M7_spacing\n"
#puts -nonewline $fid "TDC_M7_start_offset:$TDC_M7_start_offset\n"
#puts -nonewline $fid "TDC_M7_set_to_set:$TDC_M7_set_to_set\n"
#puts -nonewline $fid "TDC_pin_spread_start:$TDC_pin_spread_start\n"
#puts -nonewline $fid "TDC_pin_spread_end:$TDC_pin_spread_end\n"
#puts -nonewline $fid "TDC_Hwire_width:$TDC_Hwire_width\n"
#close $fid


saveDesign ${saveDir}/${vars(db_name)}.enc

