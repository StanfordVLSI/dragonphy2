
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

set boundary_width 0
set boundary_height [expr 2*$cell_height]
set blockage_width [expr 10*$cell_grid]
set blockage_height [expr 2*$cell_height]

set V2T_clock_gen_height [expr ceil((2*$DVDD_M8_width+$DVDD_M8_space)/(2*$cell_height))*2*$cell_height]


##############
# Floor Plan #
##############

set FP_width $stochastic_adc_PR_width 
set FP_height $stochastic_adc_PR_height

floorPlan -site core -s $FP_width  $FP_height 0 0 0 0 

set origin1_x [expr $boundary_width]
set origin1_y [expr $FP_height/2-$V2T_clock_gen_height/2-$blockage_height-$cell_height-$V2T_height]

######################
## Add boundary cell # 
######################
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



# place V2T 
placeInstance iV2Tp_dont_touch $origin1_x $origin1_y
placeInstance iV2Tn_dont_touch $origin1_x [expr ($FP_height-$origin1_y)-$V2T_height] MX


# place blockage
createPlaceBlockage -box 0 0 [expr $V2T_width+$blockage_width]  [expr $origin1_y+$V2T_height+$blockage_height] -type hard
createPlaceBlockage -box 0 $FP_height [expr $V2T_width+$blockage_width] [expr $FP_height-($origin1_y+$V2T_height+$blockage_height)] -type hard
createPlaceBlockage -box 0  $FP_height $FP_width [expr $FP_height-$boundary_height]
createPlaceBlockage -box 0  0 $FP_width $boundary_height

###############
# P/G connect #
###############
globalNetConnect DVDD -type tiehi -override
globalNetConnect DVSS -type tielo -override
globalNetConnect DVDD -type pgpin -pin VDD -inst * -override
globalNetConnect DVSS -type pgpin -pin VSS -inst * -override
globalNetConnect DVDD -type pgpin -pin VPP -inst * -override
globalNetConnect DVSS -type pgpin -pin VBB -inst * -override

globalNetConnect AVDD -type pgpin -pin VDD -inst iV2Tp_dont_touch -override
globalNetConnect AVSS -type pgpin -pin VSS -inst iV2Tp_dont_touch -override
globalNetConnect AVDD -type pgpin -pin VDD -inst iV2Tn_dont_touch -override
globalNetConnect AVSS -type pgpin -pin VSS -inst iV2Tn_dont_touch -override


addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-$welltap_width-$DB_width]  -cellInterval $FP_width -prefix WELLTAP

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
  -nets [list DVDD DVSS] 

deleteInst WELL* 

addEndCap 

set origin2_x [expr $boundary_width+$V2T_width+$blockage_width+$DB_width+4.5] 
set origin2_y [expr $boundary_height+2*$cell_height]
placeInstance inew_tdc $origin2_x $origin2_y

#M7 (Vcal)
sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { blockPin } -deleteExistingRoutes -allowJogging 1 -crossoverViaLayerRange { M7 M7 } -nets { Vcal } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M7 }
sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M7 M7 } -nets { Vcal } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M7 }


set VinP_M8_offset [get_property [get_pins iV2Tp_dont_touch/Vin] y_coordinate] 
set VinN_M8_offset [get_property [get_pins iV2Tn_dont_touch/Vin] y_coordinate] 

addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin2_x+$new_tdc_width] -cellInterval 20 -prefix WELLTAP

addWellTap -cell TAPCELLBWP16P90 -inRowOffset $Vcal_M7_offset -cellInterval $FP_width -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr 2*$Vcal_M7_offset] -cellInterval $FP_width -prefix WELLTAP



#editAddRoute [expr $PFD_x+ceil(5/$cell_grid)*$cell_grid/2]  [expr $PFD_y+$PFD_height]
#editCommitRoute [expr $PFD_x+$digital_width/2]  [expr $PFD_y+$PFD_height+5*$cell_height]


#setEdit -layer_vertical M7
#setEdit -width_vertical $V2T_M7_width
#setEdit -nets Vcal
#editAddRoute $Vcal_M7_offset 0
#editCommitRoute $Vcal_M7_offset $FP_height



#######
# NDR #
#######
#add_ndr -name NDR_2W1S -spacing {M1:M2 0.05 M3 0.05 M4:M7 0.05} -width {M1:M2 0.64 M3 0.76 M4:M7 0.08} 
add_ndr -name NDR_3W3S -spacing {M1:M2 0.12 M3 0.12 M4:M7 0.12} -width {M1:M2 0.12 M3 0.12 M4:M7 0.12} 
#add_ndr -name NDR_4W4S -spacing {M1:M2 0.04 M3 0.16 M4:M7 0.16} -width {M1:M2 0.12 M3 0.16 M4:M7 0.16} 
#add_ndr -name NDR_5W2S -spacing {M1:M2 0.05 M3 0.05 M4:M7 0.05} -width {M1:M2 0.18 M3 0.18 M4:M7 0.2} 
#add_ndr -name NDR_WIDE -spacing {M1:M2 0.2 M3 0.2 M4:M7 0.2 M9 0.2} -width {M1:M2 1 M3 1 M4:M7 1.2 M8 1.3} 

setAttribute -net {clk_v2t*} -non_default_rule NDR_3W3S

#foreach_in_collection i [get_nets *CLK*] {
#        setAttribute -net [get_object_name $i] -non_default_rule NDR_3W1S
#}
#foreach_in_collection i [get_nets *clk*] {
#        setAttribute -net [get_object_name $i] -non_default_rule NDR_2W1S
#}
#foreach_in_collection i [get_nets *sync*] {
#        setAttribute -net [get_object_name $i] -non_default_rule NDR_3W1S
#}
#foreach_in_collection i [get_nets *Vin*] {
#        setAttribute -net [get_object_name $i] -non_default_rule NDR_WIDE
#}
#foreach_in_collection i [get_nets *cal*] {
#        setAttribute -net [get_object_name $i] -non_default_rule NDR_WIDE
#}
#foreach_in_collection i [get_nets *v2t_out*] {
#        setAttribute -net [get_object_name $i] -non_default_rule NDR_5W2S
#}

#setObjFPlanBox Module V2T_clock_gen  0 [expr $origin1_y+$V2T_height] 20 [expr $FP_height-($origin1_y+$V2T_height)]
#createFence iV2T_clock_gen 0 [expr $origin1_y+$V2T_height+$blockage_height+$cell_height] 20 [expr $FP_height-($origin1_y+$V2T_height+$blockage_height+$cell_height)]







## placement groups -----------------------------------------------------------------------------------------

set V2T_clock_gen_width $Vcal_M7_offset

#set PM_area [get_property [get_cells iPM] area]
#set PM_width [expr ceil(($PM_area/$V2T_height*1.2)/$cell_grid)*$cell_grid]
set PM_width 0

createInstGroup grp0 -region 0 [expr $FP_height/2-$V2T_clock_gen_height/2] $V2T_clock_gen_width [expr $FP_height/2+$V2T_clock_gen_height/2]
addInstToInstGroup grp0 {iV2T_clock_gen}
createInstGroup grp1 -region $V2T_clock_gen_width [expr $FP_height/2-$V2T_clock_gen_height/2] $V2T_width [expr $FP_height/2+$V2T_clock_gen_height/2]
addInstToInstGroup grp1 {idcdl_coarse ib2t_tdc}


##--------------------------------------------
## IO file #
##--------------------------------------------
#loadIoFile ${ioDir}/${DesignName}.io

setPinAssignMode -pinEditInBatch true

#V2T pins
editPin -pinWidth $SW_pin_length -pinDepth $welltap_width -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 8 -spreadType start -spacing $metal_space -offsetStart $VinP_M8_offset -pin VinP
editPin -pinWidth $SW_pin_length -pinDepth $welltap_width -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 8 -spreadType start -spacing $metal_space -offsetStart $VinN_M8_offset -pin VinN

#V2T_clock_gen pins
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 0 -layer 4 -spreadType start -spacing $metal_space -offsetStart [expr $FP_height/2] -pin clk_in

#en_sync
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr $FP_height/2-$cell_height] -pin en_sync_in
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr $FP_height/2+$cell_height] -pin en_sync_out

#clk_adder
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr $FP_height/2-3*$cell_height] -pin clk_adder

#clk_async
#editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr $FP_height/2-2*$cell_height] -pin clk_async

#clk_retimer
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr $FP_height/2-2*$cell_height] -pin clk_retimer

#rstb
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr $FP_height/2+2*$cell_height] -pin rstb

#en_TDC_phase_reverse
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr $FP_height/2+3*$cell_height] -pin en_TDC_phase_reverse


#adder outputs
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 2 -spreadType start -spacing [expr 8*$metal_space] -offsetStart [expr $boundary_height+32*(4*$metal_space+$pin_width)] -pin {adder_out* sign_out}

# controls
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 2 -layer 2 -spreadType start -spacing [expr 6*$metal_space] -offsetStart [expr $boundary_height+$cell_height] -pin {del_out}

editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 2 -spreadType start -spacing [expr 6*$metal_space] -offsetStart [expr $boundary_height+4*$cell_height] -pin {ctl_v2t_p* retimer_mux* sign_PFD_clk_in init* alws_on en_slice}

editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 2 -layer 2 -spreadType start -spacing [expr 6*$metal_space] -offsetStart [expr $boundary_height+4*$cell_height] -pin {ctl_v2t_n* sel* ctl_dcdl*}

saveIoFile -locations ${ioDir}/${DesignName}.io


##-----------------------
# analog routes
##-----------------------
routeMixedSignal -constraintFile ${scrDir}/floorplan/${DesignName}_MS_routes.tcl -deleteExistingRoutes



##--------------------------------------------
## power routing
##--------------------------------------------


#M7 (AVDD)
sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { blockPin } -deleteExistingRoutes -allowJogging 1 -crossoverViaLayerRange { M7 M7 } -nets { AVDD AVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M7 }
sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M7 M7 } -nets { AVDD AVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M7 }


#M7 (DVDD)
addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width $DVDD_M7_width -spacing $DVDD_M7_space -start_offset [expr ($origin2_x+$new_tdc_width+($DVDD_M7_width+$DVDD_M7_space))] -set_to_set_distance [expr 4*($DVDD_M7_width+$DVDD_M7_space)] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


addStripe -nets {DVDD} \
  -layer M7 -direction vertical -width $DVDD_M7_width -spacing $DVDD_M7_space -start_offset [expr $welltap_width] -set_to_set_distance [expr $FP_width] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width $DVDD_M7_width -spacing $DVDD_M7_space -start_offset [expr $V2T_clk_pin_offset1+$SW_width+1.5*$DVDD_M7_width] -stop_offset [expr $FP_width-$V2T_clk_pin_offset2] -set_to_set_distance [expr 2*($DVDD_M7_width+$DVDD_M7_space)] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width $DVDD_M7_width -spacing $DVDD_M7_space -start_offset [expr $V2T_clk_pin_offset2+$SW_width+1.5*$DVDD_M7_width] -set_to_set_distance [expr $FP_width] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

#M7 (DVDD-TDC)
sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M7 M1 } -nets { DVDD DVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M1} -inst {inew_tdc}

uiSetTool addWire
setEdit -layer_minimum M1
setEdit -layer_maximum AP
setEdit -force_regular 1
getEdit -snap_to_track_regular
getEdit -snap_to_pin
viewLast
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
setEdit -width_vertical $DVDD_M7_width

set new_tdc_M7_offset [expr $welltap_width+$Dcell_inv_inv_width/2-1.5*$DVDD_M7_width]
set new_tdc_M7_set_to_set [expr $Dcell_inv_inv_width+$welltap_width]
createRouteBlk -box $origin2_x $origin2_y [expr $origin2_x+$new_tdc_width] [expr $origin2_y+$new_tdc_height] -layer {6}

setEdit -nets {DVDD}
editAddRoute [expr $origin2_x+$new_tdc_M7_offset] 0
editCommitRoute  [expr $origin2_x+$new_tdc_M7_offset] $FP_height
setEdit -nets {DVSS}
editAddRoute [expr $origin2_x+$new_tdc_M7_offset+3*$DVDD_M7_width] 0
editCommitRoute  [expr $origin2_x+$new_tdc_M7_offset+3*$DVDD_M7_width] $FP_height
setEdit -nets {DVDD}
editAddRoute [expr $origin2_x+$new_tdc_M7_offset+$new_tdc_M7_set_to_set] 0
editCommitRoute  [expr $origin2_x+$new_tdc_M7_offset+$new_tdc_M7_set_to_set] $FP_height
setEdit -nets {DVSS}
editAddRoute [expr $origin2_x+$new_tdc_M7_offset+3*$DVDD_M7_width+$new_tdc_M7_set_to_set] 0
editCommitRoute  [expr $origin2_x+$new_tdc_M7_offset+3*$DVDD_M7_width+$new_tdc_M7_set_to_set] $FP_height

setEdit -nets {DVSS}
editAddRoute [expr $origin2_x+$new_tdc_M7_offset+2*$new_tdc_M7_set_to_set+$welltap_width] 0
editCommitRoute  [expr $origin2_x+$new_tdc_M7_offset+2*$new_tdc_M7_set_to_set+$welltap_width] $FP_height
setEdit -nets {DVDD}
editAddRoute [expr $origin2_x+$new_tdc_M7_offset+3*$DVDD_M7_width+2*$new_tdc_M7_set_to_set+$welltap_width] 0
editCommitRoute  [expr $origin2_x+$new_tdc_M7_offset+3*$DVDD_M7_width+2*$new_tdc_M7_set_to_set+$welltap_width] $FP_height
setEdit -nets {DVSS}
editAddRoute [expr $origin2_x+$new_tdc_M7_offset+$new_tdc_M7_set_to_set+2*$new_tdc_M7_set_to_set+$welltap_width] 0
editCommitRoute  [expr $origin2_x+$new_tdc_M7_offset+$new_tdc_M7_set_to_set+2*$new_tdc_M7_set_to_set+$welltap_width] $FP_height
setEdit -nets {DVDD}
editAddRoute [expr $origin2_x+$new_tdc_M7_offset+3*$DVDD_M7_width+$new_tdc_M7_set_to_set+2*$new_tdc_M7_set_to_set+$welltap_width] 0
editCommitRoute  [expr $origin2_x+$new_tdc_M7_offset+3*$DVDD_M7_width+$new_tdc_M7_set_to_set+2*$new_tdc_M7_set_to_set+$welltap_width] $FP_height


#M8 (DVDD)
addStripe -nets {DVSS DVDD} \
-layer M8 -direction horizontal -width $DVDD_M8_width -spacing $DVDD_M8_space -start_offset [expr $FP_height/2-$DVDD_M8_space/2-$DVDD_M8_width] -stop_offset [expr $FP_height/2-$DVDD_M8_space/2-$DVDD_M8_width] -set_to_set_distance $FP_height -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

createRouteBlk -box 0 0 [expr $origin1_x+$V2T_width+$blockage_width] $FP_height  -layer 8

addStripe -nets {DVSS DVDD} \
-layer M8 -direction horizontal -width $DVDD_M8_width -spacing $DVDD_M8_space -start_offset [expr $FP_height/2+$DVDD_M8_space/2+$DVDD_M8_width+2*$DVDD_M8_space] -set_to_set_distance [expr 2*($DVDD_M8_width+$DVDD_M8_space)+$DVDD_M8_space] -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {DVDD DVSS} \
-layer M8 -direction horizontal -width $DVDD_M8_width -spacing $DVDD_M8_space -start_offset [expr $FP_height/2+$DVDD_M8_space/2+$DVDD_M8_width+2*$DVDD_M8_space] -set_to_set_distance [expr 2*($DVDD_M8_width+$DVDD_M8_space)+$DVDD_M8_space] -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

deleteRouteBlk -all

#M9 (AVDD)
sroute -connect { blockPin } -layerChangeRange { M9 M9 } -blockPinTarget { blockPin } -allowJogging 1 -crossoverViaLayerRange { M9 M9 } -nets { AVDD AVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M9 M9 }
sroute -connect { blockPin } -layerChangeRange { M9 M9 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M9 M9 } -nets { AVDD AVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M9 M9 }


createRouteBlk -box [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width] 0 $FP_width $FP_height -layer {7}  

#M9 (DVDD)
addStripe -nets {DVDD DVSS} \
-layer M9 -direction vertical -width $M9_width -spacing $M9_space -start_offset [expr 3*($DB_width+$welltap_width)] -stop_offset [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width] -set_to_set_distance [expr 2*($M9_width+$M9_space)] -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape { noshape} -extend_to design_boundary -create_pins 1

deleteRouteBlk -all


createRouteBlk -box $origin2_x $origin2_y [expr $origin2_x+$new_tdc_width] [expr $origin2_y+$new_tdc_height] -layer {6 7 8}

placeInstance idcdl_coarse/in_and_in/U1 [expr $V2T_clk_pin_offset2+$SW_width+3*$DVDD_M7_width] [expr $FP_height/2]


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

#saveDesign ${saveDir}/${vars(db_name)}.enc






