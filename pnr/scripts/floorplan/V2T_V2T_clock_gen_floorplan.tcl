

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
set V2T_clock_gen_height [expr 10*$cell_height]
set PFD_width 4.5

##############
# Floor Plan #
##############

set FP_height [expr 2*$boundary_height+2*$blockage_height+2*$V2T_height+$V2T_clock_gen_height]
set FP_width [expr ceil(($boundary_width+$V2T_width+$PFD_width+$blockage_width+4*$welltap_width+2*$DB_width+11)/$cell_grid)*$cell_grid]

floorPlan -site core -s $FP_width  $FP_height 0 0 0 0 

set origin1_x [expr $boundary_width]
set origin1_y [expr $FP_height/2-$V2T_clock_gen_height/2-$blockage_height-$V2T_height]


# specify BlackBox
specifyBlackBox -masterInst iV2Tp_dont_touch -size $V2T_width $V2T_height -coreSpacing 0.0 0.0 0.0 0.0 -minPitchLeft 2 -minPitchRight 2 -minPitchTop 2 -minPitchBottom 2 -reservedLayer { 1 2 3 4 5 6 7 8 9 10} -pinLayerTop { 3 5 7 9} -pinLayerLeft { 2 4 6 8 10} -pinLayerBottom { 3 5 7 9} -pinLayerRight { 2 4 6 8 10} -routingHalo 0.2 -routingHaloTopLayer 10 -routingHaloBottomLayer 1 -placementHalo 0.0 0.0 0.0 0.0




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
placeInstance iV2Tp_dont_touch $origin1_x [expr ($FP_height-$V2T_clock_gen_height)/2-$blockage_height-$V2T_height]
placeInstance iV2Tn_dont_touch $origin1_x [expr ($FP_height+$V2T_clock_gen_height)/2+$blockage_height] MX


# place blockage
createPlaceBlockage -box 0 0 [expr $V2T_width+$blockage_width]  [expr ($FP_height-$V2T_clock_gen_height)/2] -type hard
createPlaceBlockage -box 0 [expr ($FP_height+$V2T_clock_gen_height)/2] [expr $V2T_width+$blockage_width] $FP_height -type hard

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

# place V2T_clock_gen
#deletePlaceBlockage *V2T_clock_gen*
#placeInstance IV2Tclkgen $origin1_x [expr ($FP_height-$V2T_clock_gen_height)/2]  

# place PFD
#set PFD_x [expr $FP_width-$DB_width-2*$welltap_width-$wallace_adder_width-$PFD_width]
#set PFD_y [expr $FP_height/2-$PFD_height/2]
#placeInstance IPFD $PFD_x $PFD_y

# place TDC_delay_chain/wallce_adder
#placeInstance Iadder $origin2_x [expr $FP_height/2-($wallace_adder_height+$TDC_delay_chain_height)/2] 
#placeInstance Idchain $origin2_x [expr $FP_height/2+($wallace_adder_height-$TDC_delay_chain_height)/2]

addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin1_x+$V2T_width+$blockage_width+$DB_width]  -cellInterval $FP_width -prefix WELLTAP

addWellTap -cell TAPCELLBWP16P90 -inRowOffset 20  -cellInterval [expr $FP_width-20] -prefix WELLTAP


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
#editAddRoute [expr $PFD_x+$PFD_width/2-5*$pin_width] [expr $origin2_y+$wallace_adder_height+$TDC_delay_chain_height/2]
#editCommitRoute  [expr $origin2_x] [expr $origin2_y+$wallace_adder_height+$TDC_delay_chain_height/2] 

#editAddRoute [expr $PFD_x+ceil(5/$cell_grid)*$cell_grid/2]  [expr $PFD_y+$PFD_height]
#editCommitRoute [expr $PFD_x+$PFD_width/2]  [expr $PFD_y+$PFD_height+5*$cell_height]


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
#add_ndr -name NDR_5W2S -spacing {M1:M2 0.05 M3 0.05 M4:M7 0.05} -width {M1:M2 0.18 M3 0.18 M4:M7 0.2} 
#add_ndr -name NDR_WIDE -spacing {M1:M2 0.2 M3 0.2 M4:M7 0.2 M9 0.2} -width {M1:M2 1 M3 1 M4:M7 1.2 M8 1.3} 

#setAttribute -net pfd_out -non_default_rule NDR_WIDE

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

createInstGroup grp0 -region 0 [expr $FP_height/2-$V2T_clock_gen_height/2] 17.5 [expr $FP_height/2+$V2T_clock_gen_height/2]
addInstToInstGroup grp0 {iV2T_clock_gen}

#createInstGroup grp3 -region [expr $origin1_x+$V2T_clock_gen_width]  [expr $origin1_y+$V2T_clock_gen_height] $origin2_x [expr $FP_height-($origin1_y+$V2T_clock_gen_height)]
#addInstToInstGroup grp3 IPM/*

placeInstance iPFD/TinN_sampled_reg [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width] [expr $FP_height/2]
placeInstance iPFD/TinP_sampled_reg [expr $origin1_x+$V2T_width+$blockage_width+$DB_width+$welltap_width] [expr $FP_height/2-$cell_height]

setInstancePlacement -name {iPFD/TinN_sampled_reg iPFD/TinP_sampled_reg  } -status softFixed





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
loadIoFile ${ioDir}/${DesignName}.io


#setPinAssignMode -pinEditInBatch true
#set VinP_M8_offset [expr $origin1_y+$Vin_M8_offset]
#set VinN_M8_offset [expr $FP_height-($origin1_y+$Vin_M8_offset)]

#V2T
#editPin -pinWidth $SW_pin_length -pinDepth $welltap_width -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 8 -spreadType start -spacing $metal_space -offsetStart $VinP_M8_offset -pin VinP
#editPin -pinWidth $SW_pin_length -pinDepth $welltap_width -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 8 -spreadType start -spacing $metal_space -offsetStart $VinN_M8_offset -pin VinN

#V2T_clock_gen
#editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 0 -layer 6 -spreadType start -spacing $metal_space -offsetStart [expr $FP_height/2] -pin clk_in

#saveIoFile -locations ${ioDir}/${DesignName}.io



##--------------------------------------------
## power routing
##--------------------------------------------


sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { blockPin } -deleteExistingRoutes -allowJogging 1 -crossoverViaLayerRange { M7 M7 } -nets { AVDD AVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M7 }
sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M7 M7 } -nets { AVDD AVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M7 }

sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { blockPin } -deleteExistingRoutes -allowJogging 1 -crossoverViaLayerRange { M7 M7 } -nets { Vcal } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M7 }
sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M7 M7 } -nets { Vcal } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M7 }



#------------------------------------------------------
set RUN_LAYOUT_ONLY 0
##------------------------------------------------------

##------------------------------------------------------
## pnr variable file-out ##
##------------------------------------------------------
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "${DesignName}_width:$FP_width\n"
puts -nonewline $fid "${DesignName}_height:$FP_height\n"
puts -nonewline $fid "VinP_M8_offset:$VinP_M8_offset\n"
puts -nonewline $fid "VinN_M8_offset:$VinN_M8_offset\n"
close $fid

saveDesign ${saveDir}/${vars(db_name)}.enc


# DONT TOUCH
set_dont_touch [get_cells -hierarchical *dont_touch*]

##---------------------------------------------------------
## specify ILM 
##---------------------------------------------------------
#specifyIlm -cell V2T -dir ${libDir}


##-----------------------
# analog routes
##-----------------------
#routeMixedSignal -constraintFile ${scrDir}/floorplan/${DesignName}_MS_routes.tcl -deleteExistingRoutes


