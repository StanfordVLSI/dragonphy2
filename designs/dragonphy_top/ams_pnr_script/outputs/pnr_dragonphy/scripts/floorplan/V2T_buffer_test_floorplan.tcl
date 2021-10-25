
##---------------------------------------------------------
## set FloorPlan
##---------------------------------------------------------
floorPlan -site core -r 1 0.3 0 0 0 0
set raw_area [dbGet top.fPlan.area]
set FP_height [expr 2*$cell_height]
set FP_width [expr ceil($raw_area/$FP_height/$cell_grid)*$cell_grid]
floorPlan -site core -s $FP_width [expr 2*$FP_height] 0 0 0 0


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
addWellTap -cell TAPCELLBWP16P90 -inRowOffset 0 -cellInterval $FP_width -prefix WELLTAP


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
setPinAssignMode -pinEditInBatch true

editPin -pinWidth $pin_width -pinDepth [expr $pin_depth] -spacing [expr 8*$pin_width] -fixOverlap 1 -spreadDirection clockwise -edge 0 -layer 2 -spreadType center -pin {clk_in clk_div_in}

editPin -pinWidth $pin_width -pinDepth [expr $pin_depth] -spacing [expr 8*$pin_width] -fixOverlap 1 -spreadDirection clockwise -edge 2 -layer 2 -spreadType center -pin {out outb}


##------------------------------------------------------
set RUN_LAYOUT_ONLY 0
##------------------------------------------------------

##------------------------------------------------------
## pnr variable file-out ##
##------------------------------------------------------
#set fid [open "${pnrDir}/pnr_vars.txt" a]
#puts -nonewline $fid "${DesignName}_width:$FP_width\n"
#puts -nonewline $fid "${DesignName}_height:$FP_height\n"
#puts -nonewline $fid "wallace_adder_Nout:$wallace_adder_Nout\n"
#puts -nonewline $fid "wallace_adder_outpin_offset:$wallace_adder_outpin_offset\n"
#close $fid

#saveDesign ${saveDir}/${vars(db_name)}.enc

