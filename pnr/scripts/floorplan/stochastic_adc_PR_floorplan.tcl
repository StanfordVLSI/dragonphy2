
set TDC_Nunit 256
set TDC_Nheight 16
set TDC_Nwidth 16

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

set digital_width 5

set TDC_inv_area [get_property [get_cells idchain/iTDC_delay_unit_dont_touch_0_/iinv/U1] area] 
set TDC_inv_width [expr round($TDC_inv_area/$cell_height/$cell_grid)*$cell_grid]

set TDC_ff_area [get_property [get_cells idchain/iTDC_delay_unit_dont_touch_0_/ff_out_reg/Q_reg] area] 
set TDC_ff_width [expr round($TDC_ff_area/$cell_height/$cell_grid)*$cell_grid]

set TDC_ff_PR_area [get_property [get_cells idchain/iTDC_delay_unit_dont_touch_0_/phase_reverse_reg/Q_reg] area] 
set TDC_ff_PR_width [expr round($TDC_ff_PR_area/$cell_height/$cell_grid)*$cell_grid]

set TDC_xnor_area [get_property [get_cells idchain/iTDC_delay_unit_dont_touch_0_/ix_nor/U1] area] 
set TDC_xnor_width [expr round($TDC_xnor_area/$cell_height/$cell_grid)*$cell_grid]


set delay_chain_width [expr (1*($TDC_inv_width+$TDC_ff_width)+$TDC_ff_PR_width+$TDC_xnor_width)*($TDC_Nwidth)+$welltap_width]
#set delay_chain_width [expr (2*($TDC_inv_width+$TDC_ff_width))*($TDC_Nwidth)+$welltap_width]
set delay_chain_height [expr $cell_height*($TDC_Nheight+8)]


set routing_width [expr ceil(5/$cell_grid)*$cell_grid]
set routing_height [expr 4*$cell_height]



##############
# Floor Plan #
##############

set FP_height [expr 2*($boundary_height+$blockage_height+$V2T_height+$cell_height)+$V2T_clock_gen_height]
set FP_width [expr ceil(($boundary_width+$V2T_width+$digital_width+$blockage_width+4*$welltap_width+2*$DB_width+$delay_chain_width+$routing_width)/$cell_grid)*$cell_grid]

floorPlan -site core -s $FP_width  $FP_height 0 0 0 0 

set origin1_x [expr $boundary_width]
set origin1_y [expr $FP_height/2-$V2T_clock_gen_height/2-$blockage_height-$cell_height-$V2T_height]

set origin2_x [expr $FP_width-$delay_chain_width-$routing_width-$welltap_width-$DB_width]
set origin2_y [expr $FP_height-$blockage_height-$cell_height-$routing_height-$delay_chain_height]

# specify BlackBox
#specifyBlackBox -masterInst iV2Tp_dont_touch -size $V2T_width $V2T_height -coreSpacing 0.0 0.0 0.0 0.0 -minPitchLeft 2 -minPitchRight 2 -minPitchTop 2 -minPitchBottom 2 -reservedLayer { 1 2 3 4 5 6 7 8 9 10} -pinLayerTop { 3 5 7 9} -pinLayerLeft { 2 4 6 8 10} -pinLayerBottom { 3 5 7 9} -pinLayerRight { 2 4 6 8 10} -routingHalo 0.2 -routingHaloTopLayer 10 -routingHaloBottomLayer 1 -placementHalo 0.0 0.0 0.0 0.0




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


#addWellTap -cell TAPCELLBWP16P90 -inRowOffset 1  -cellInterval $FP_width -prefix WELLTAP
#globalNetConnect AVDD -type pgpin -pin VDD -inst * -override
#globalNetConnect AVSS -type pgpin -pin VSS -inst * -override
#createRouteBlk -box 2 0 $FP_width $FP_height -name AVDD_M1_blk1 -layer 1
#createRouteBlk -box 0 [expr $origin1_y+$V2T_height+$cell_height] $FP_width [expr $FP_height-($origin1_y+$V2T_height+$cell_height)] -name AVDD_M1_blk2 -layer 1
#createRouteBlk -box 0 0 $FP_width $cell_height -name AVDD_M1_blk3 -layer 1
#createRouteBlk -box 0 $FP_height $FP_width [expr $FP_height-$cell_height] -name AVDD_M1_blk4 -layer 1

#addStripe -pin_layer M1   \
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
  -nets [list AVDD AVSS] 

#deleteInst WELL* 
#deleteRouteBlk -name *

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

#M7 (Vcal)
sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { blockPin } -deleteExistingRoutes -allowJogging 1 -crossoverViaLayerRange { M7 M7 } -nets { Vcal } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M7 }
sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M7 M7 } -nets { Vcal } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M7 }


set Vcal_M7_offset [get_property [get_ports Vcal] x_coordinate] 
set VinP_M8_offset [get_property [get_pins iV2Tp_dont_touch/Vin] y_coordinate] 
set VinN_M8_offset [get_property [get_pins iV2Tn_dont_touch/Vin] y_coordinate] 

addWellTap -cell TAPCELLBWP16P90 -inRowOffset $Vcal_M7_offset -cellInterval $FP_width -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr ($origin1_x+$V2T_width+$blockage_width+$DB_width)+($FP_width-($origin1_x+$V2T_width+$blockage_width+$DB_width))/3]  -cellInterval [expr ($FP_width-($origin1_x+$V2T_width+$blockage_width+$DB_width))/3] -prefix WELLTAP

addWellTap -cell TAPCELLBWP16P90 -inRowOffset 0 -cellInterval [expr 2*$FP_width] -prefix WELLTAP


#SetTool addWire
#setEdit -layer_minimum M1
#setEdit -layer_maximum AP
#setEdit -force_regular 1
#getEdit -snap_to_track_regular
#getEdit -snap_to_pin
#viewLast
#setEdit -force_special 1
#getEdit -snap_to_track
#getEdit -snap_special_wire
#getEdit -align_wire_at_pin
#getEdit -snap_to_row
#getEdit -snap_to_pin
#setViaGenMode -ignore_DRC false
#setViaGenMode -use_fgc 1
#setViaGenMode -use_cce false


#setEdit -layer_horizontal M4
#setEdit -width_horizontal $TDC_Hwire_width
#setEdit -layer_vertical M5
#setEdit -width_vertical 1

#setEdit -nets pfd_out
#editAddRoute [expr $PFD_x+$digital_width/2-5*$pin_width] [expr $origin2_y+$wallace_adder_height+$TDC_delay_chain_height/2]
#editCommitRoute  [expr $origin2_x] [expr $origin2_y+$wallace_adder_height+$TDC_delay_chain_height/2] 

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
#add_ndr -name NDR_3W1S -spacing {M1:M2 0.05 M3 0.05 M4:M7 0.05} -width {M1:M2 0.12 M3 0.12 M4:M7 0.12} 
add_ndr -name NDR_4W4S -spacing {M1:M2 0.04 M3 0.16 M4:M7 0.16} -width {M1:M2 0.12 M3 0.16 M4:M7 0.16} 
#add_ndr -name NDR_5W2S -spacing {M1:M2 0.05 M3 0.05 M4:M7 0.05} -width {M1:M2 0.18 M3 0.18 M4:M7 0.2} 
#add_ndr -name NDR_WIDE -spacing {M1:M2 0.2 M3 0.2 M4:M7 0.2 M9 0.2} -width {M1:M2 1 M3 1 M4:M7 1.2 M8 1.3} 

setAttribute -net {clk_v2t*} -non_default_rule NDR_4W4S

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

set PM_area [get_property [get_cells iPM] area]
set PM_width [expr ceil(($PM_area/$V2T_height*1.2)/$cell_grid)*$cell_grid]

set PM_area [get_property [get_cells iPM] area]
set PM_width [expr ceil(10/$cell_grid)*$cell_grid]

createInstGroup grp0 -region 0 [expr $FP_height/2-$V2T_clock_gen_height/2] $V2T_clock_gen_width [expr $FP_height/2+$V2T_clock_gen_height/2]
addInstToInstGroup grp0 {iV2T_clock_gen}

createInstGroup grp1 -region [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width+$PM_width] $origin2_y $FP_width [expr $origin2_y+$delay_chain_height]
addInstToInstGroup grp1 {idchain}

createInstGroup grp2 -region [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width+$PM_width] 0 $FP_width $origin2_y 
addInstToInstGroup grp2 {iadder}

createInstGroup grp3 -region [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width] [expr $FP_height/2+$V2T_clock_gen_height/2] [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width+$PM_width] $FP_height
addInstToInstGroup grp3 {idcdl_coarse/* ib2t_tdc/*}

createInstGroup grp5 -region $V2T_clock_gen_width [expr $FP_height/2-$V2T_clock_gen_height/2] [expr $origin1_x+$V2T_width] [expr $FP_height/2+$V2T_clock_gen_height/2]
addInstToInstGroup grp5 {iPM/iPM_sub/* ipm_mux*} 

createInstGroup grp4 -region [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width] 0 [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width+$PM_width] [expr $FP_height/2-$V2T_clock_gen_height/2] 
addInstToInstGroup grp4 {iPM/*}

createInstGroup grp6 -region [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width] [expr $FP_height/2+$V2T_clock_gen_height/2] [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width+$PM_width] [expr $FP_height/2-$V2T_clock_gen_height/2] 
addInstToInstGroup grp6 {iPFD/*}



#createRouteBlk -box 13 [expr $origin1_y+$V2T_height+$blockage_height+$cell_height] 16 [expr $FP_height-($origin1_y+$V2T_height+$blockage_height+$cell_height)] -layer 6 

#createInstGroup grp4 -region [expr $origin1_x+$V2T_width+$blockage_width] 0 [expr $origin1_x+$V2T_width+$blockage_width+5] [expr ($origin1_y+$V2T_height)]
#addInstToInstGroup grp4 {ib2tp}

#createInstGroup grp5 -region [expr $origin1_x+$V2T_width+$blockage_width] $FP_height [expr $origin1_x+$V2T_width+$blockage_width+5] [expr $FP_width-($origin1_y+$V2T_height)]
#addInstToInstGroup grp5 {ib2tn}

#placeInstance IMUX0_PM [expr $origin1_x+$V2T_clock_gen_width+$blockage_width+$DB_width+2.7] [expr $origin1_y+$V2T_height+9*$cell_height]  
#placeInstance IMUX1_PM [expr $origin1_x+$V2T_clock_gen_width+$blockage_width+$DB_width+2.7] [expr $origin1_y+$V2T_height+8*$cell_height]  
#placeInstance IMUX00_PM [expr $origin1_x+$V2T_clock_gen_width+$blockage_width+$DB_width+2.7] [expr $origin1_y+$V2T_height+10*$cell_height] R180 
#placeInstance IMUX11_PM [expr $origin1_x+$V2T_clock_gen_width+$blockage_width+$DB_width+2.7] [expr $origin1_y+$V2T_height+7*$cell_height] MY
#placeInstance IPM/uPMSUB/uXOR0 [expr $origin1_x+$V2T_clock_gen_width+$blockage_width+$DB_width+3.6] [expr $origin1_y+$V2T_height+9*$cell_height]  
#placeInstance IPM/uPMSUB/uXOR1 [expr $origin1_x+$V2T_clock_gen_width+$blockage_width+$DB_width+3.6] [expr $origin1_y+$V2T_height+8*$cell_height]  
#placeInstance Iinv_V2Tp_0 [expr $PFD_x-$welltap_width-0.36] [expr 33*$cell_height] MY 
#placeInstance Iinv_V2Tp_1 [expr $PFD_x-$welltap_width-0.36-0.72] [expr 33*$cell_height] MY 
#placeInstance Iinv_V2Tn_0 [expr $PFD_x-$welltap_width-0.36] [expr 36*$cell_height] R180 
#placeInstance Iinv_V2Tn_1 [expr $PFD_x-$welltap_width-0.36-0.72] [expr 36*$cell_height] R180 
#placeInstance IPM/uPMSUB/ff_in_reg [expr $origin1_x+$V2T_clock_gen_width+$DB_width+6] [expr $origin1_y+$V2T_height+9*$cell_height]  
#placeInstance IPM/uPMSUB/ff_ref_reg [expr $origin1_x+$V2T_clock_gen_width+$DB_width+6] [expr $origin1_y+$V2T_height+8*$cell_height]  
#placeInstance IPM/uPMSUB/uBD0 [expr $origin1_x+$V2T_clock_gen_width+$DB_width+6] [expr $origin1_y+$V2T_height+10*$cell_height]  
#placeInstance IPM/uPMSUB/uBD1 [expr $origin1_x+$V2T_clock_gen_width+$DB_width+6] [expr $origin1_y+$V2T_height+7*$cell_height]  
#placeInstance Ibuf_adder 42.57 20.16
#placeInstance Ibuf_async_0 16.47 [expr  40*$cell_height]
#placeInstance Ibuf_async_1 16.83 [expr  40*$cell_height]
#placeInstance Ibuf_clk_div_0 [expr $FP_width-5.85] [expr  4*$cell_height]
#placeInstance Ibuf_clk_div_1 [expr $FP_width-5.4] [expr  4*$cell_height]


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

#clk_async
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr $FP_height/2-4*$cell_height] -pin clk_async

#rstb
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 2 -spreadType start -spacing $metal_space -offsetStart [expr $FP_height/2+4*$cell_height] -pin rstb

#PM outputs
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 2 -spreadType start -spacing [expr 4*$metal_space] -offsetStart [expr $boundary_height+2*$cell_height] -pin {ctl_v2t_p* pm_out*}

#adder outputs
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 2 -spreadType start -spacing [expr 8*$metal_space] -offsetStart [expr $boundary_height+32*(4*$metal_space+$pin_width)] -pin {adder_out* sign_out clk_adder}

# controls
editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 2 -layer 2 -spreadType start -spacing [expr 4*$metal_space] -offsetStart [expr $boundary_height+2*$cell_height] -pin {ctl_v2t_n* ctl_dcdl* sel* alws_on del_out en_pm en_slice init* en_TDC_phase_reverse}

saveIoFile -locations ${ioDir}/${DesignName}.io

#place PFD input FFs
placeInstance iPFD/TinN_sampled_reg [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width] [expr $FP_height/2]
placeInstance iPFD/TinP_sampled_reg [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width] [expr $FP_height/2-$cell_height]

setInstancePlacement -name {iPFD/TinN_sampled_reg iPFD/TinP_sampled_reg  } -status softFixed


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
  -layer M7 -direction vertical -width $DVDD_M7_width -spacing $DVDD_M7_space -start_offset [expr 3*($DB_width+$welltap_width)] -stop_offset [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width] -set_to_set_distance [expr 4*($DVDD_M7_width+$DVDD_M7_space)] -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


addStripe -nets {DVDD} \
  -layer M7 -direction vertical -width $DVDD_M7_width -spacing $DVDD_M7_space -start_offset [expr $welltap_width] -set_to_set_distance [expr $FP_width] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width $DVDD_M7_width -spacing $DVDD_M7_space -start_offset [expr $V2T_clk_pin_offset1+$SW_width+1.5*$DVDD_M7_width] -stop_offset [expr $FP_width-$V2T_clk_pin_offset2] -set_to_set_distance [expr 2*($DVDD_M7_width+$DVDD_M7_space)] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width $DVDD_M7_width -spacing $DVDD_M7_space -start_offset [expr $V2T_clk_pin_offset2+$SW_width+1.5*$DVDD_M7_width] -set_to_set_distance [expr $FP_width] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


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


createRouteBlk -box [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width] 0 $FP_width $FP_height -layer 7 

#M9 (DVDD)
addStripe -nets {DVDD DVSS} \
-layer M9 -direction vertical -width $M9_width -spacing $M9_space -start_offset [expr 3*($DB_width+$welltap_width)] -stop_offset [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width] -set_to_set_distance [expr 2*($M9_width+$M9_space)] -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

deleteRouteBlk -all


#------------------------------------------------------
set RUN_LAYOUT_ONLY 0
##------------------------------------------------------

##------------------------------------------------------
## pnr variable file-out ##
##------------------------------------------------------
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "${DesignName}_width:$FP_width\n"
puts -nonewline $fid "${DesignName}_height:$FP_height\n"
puts -nonewline $fid "Vcal_M7_offset:$Vcal_M7_offset\n"
puts -nonewline $fid "VinP_M8_offset:$VinP_M8_offset\n"
puts -nonewline $fid "VinN_M8_offset:$VinN_M8_offset\n"
close $fid

saveDesign ${saveDir}/${vars(db_name)}.enc


##---------------------------------------------------------
## specify ILM 
##---------------------------------------------------------
#specifyIlm -cell V2T -dir ${libDir}




