
##---------------------------------------------------------
## set FloorPlan
##---------------------------------------------------------
floorPlan -site core -r 0.5 0.2 0 0 0 0
set FP_width [dbGet top.fPlan.box_sizex]
set FP_height [dbGet top.fPlan.box_sizey] 


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

deleteInst WELL*

addWellTap -cell TAPCELLBWP16P90 -inRowOffset 0 -cellInterval $FP_width -prefix WELLTAP

#--------------------------------------------
# IO file #
#--------------------------------------------
loadIoFile ${ioDir}/${DesignName}.io


##------------------------------------------------------
set RUN_LAYOUT_ONLY 0
##------------------------------------------------------


saveDesign ${saveDir}/${vars(db_name)}.enc

