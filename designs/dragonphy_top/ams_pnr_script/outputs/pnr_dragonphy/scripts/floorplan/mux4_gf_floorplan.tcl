
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

##---------------------------------------------------------
## set FloorPlan
##---------------------------------------------------------
floorPlan -site core -r 1 0.7 0 0 0 0
set raw_area [dbGet top.fPlan.area]

set FP_height [expr 4*$cell_height]
set FP_width [expr ceil(($raw_area/$FP_height)/$cell_grid)*$cell_grid]

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


#addStripe -nets {VDD} \
#  -layer M7 -direction vertical -width [expr $DVDD_M7_width] -spacing $FP_width -start_offset 0 -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

#addStripe -nets {VSS} \
#  -layer M7 -direction vertical -width [expr $DVDD_M7_width] -spacing $FP_width -start_offset 0 -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1



##--------------------------------------------
## IO file #
##--------------------------------------------
#loadIoFile ${ioDir}/${DesignName}.io


setPinAssignMode -pinEditInBatch true

editPin -pinWidth [expr $PI_MS_net_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 0 -layer 2 -spreadType start -spacing [expr $cell_height] -offsetStart [expr $cell_height/2] -pin {in*}

editPin -pinWidth [expr $PI_MS_net_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 2 -spreadType start -spacing [expr $cell_height] -offsetStart [expr $FP_height/2] -pin {out}

editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -spreadDirection counterclockwise -edge 3 -layer 3 -spreadType range -offsetStart [expr 2*$DVDD_M7_width] -offsetEnd [expr 2*$DVDD_M7_width] -pin {en_gf sel*}

saveIoFile -locations ${ioDir}/${DesignName}.io



#------------------------------------------------------
set RUN_LAYOUT_ONLY 0
##------------------------------------------------------

##------------------------------------------------------
## pnr variable file-out ##
##------------------------------------------------------
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "${DesignName}_width:$FP_width\n"
puts -nonewline $fid "${DesignName}_height:$FP_height\n"
close $fid

#saveDesign ${saveDir}/${vars(db_name)}.enc










