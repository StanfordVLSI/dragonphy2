#enow#############
# MACRO Info #
##############
set welltap_width 0.72
set DB_width 0.36

set boundary_width [expr $welltap_width+$DB_width]
set boundary_height [expr $cell_height]

set acore_width 360.45
set acore_height [expr 702*$cell_height]

set input_buffer_width 53.1
set input_buffer_height [expr 87*$cell_height]

set output_buffer_width 13.05
set output_buffer_height [expr 32*$cell_height]

set memory_width 64.175
set memory_height 249.84

set blockage_width [expr 0.9]
set blockage_height [expr 2*$cell_height]

#set origin1_x [expr $routing_width_edge]
#set origin1_y [expr $boundary_height+$ADC_height+$BG_height]

#set origin2_x [expr $origin1_x+$ADC_width+$routing_width_side] 

##############
# Floor Plan #
##############
set FP_width [expr ceil(580/0.09)*0.09]
set FP_height [expr ceil(700/$cell_height)*$cell_height]
floorPlan -site core -s $FP_width $FP_height 0 0 0 0


set center_x [expr $FP_width/2]

######################
## Add welltap cell # 
######################
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
  -rule 10 \
  -bottom_tap_cell BOUNDARY_NTAPBWP16P90 \
  -top_tap_cell    BOUNDARY_PTAPBWP16P90 \
  -block_boundary_only true \
  -cell TAPCELLBWP16P90


#################################################################
##################### Place MACROs ##############################
#################################################################
## acore
set origin1_x  [expr $center_x-$acore_width/2]
set origin1_y  [expr $FP_height-2*$boundary_height-2*$blockage_height-$acore_height-2*$cell_height] 

## input_buffer_async
set origin0_x  [expr 6*$blockage_width+2*$DB_width+$welltap_width+2]
set origin0_y  [expr (ceil(260-$input_buffer_height/2)/$cell_height)*$cell_height]
# memory
set origin2_x  [expr $origin1_x+4*$blockage_width]
set origin2_y  [expr 2*$boundary_height+2*$blockage_height+$cell_height] 
# input_buffer_test
set origin3_x  [expr $FP_width-$origin0_x-$input_buffer_width]
set origin3_y  [expr (ceil(260-$input_buffer_height/2)/$cell_height)*$cell_height-$input_buffer_height+57*$cell_height]
# output_buffer_test
set origin4_x  [expr $origin3_x+$input_buffer_width/2+$blockage_width+10*$welltap_width+$DB_width] 
set origin4_y  [expr ceil((87-$output_buffer_height/2)/$cell_height)*$cell_height]



##
#Placement
placeInstance ibuf_async $origin0_x $origin0_y 
placeInstance iacore $origin1_x $origin1_y 
placeInstance idcore/oneshot_memory_i/sram_i/memory [expr $origin2_x] [expr $origin2_y]
placeInstance ibuf_test1 [expr $origin3_x] [expr $origin3_y] R180 
placeInstance ibuf_test0 [expr $origin3_x] [expr $origin3_y+$input_buffer_height+4*$cell_height] MY 
placeInstance ibuf_aux [expr $center_x-$input_buffer_width/2] [expr $origin1_y-$input_buffer_height-32*$cell_height] 
placeInstance idcore/out_buff_i $origin4_x $origin4_y

##  outmost blockcage
createPlaceBlockage -box 0 0 $FP_width  $blockage_height
createPlaceBlockage -box 0 $FP_height $FP_width  [expr $FP_height-$blockage_height]
createPlaceBlockage -box 0 0 $blockage_width $FP_height
createPlaceBlockage -box $FP_width 0 [expr $FP_width-$blockage_width] $FP_height

## macro blockage
## input_buffer_async
createPlaceBlockage -box [expr $origin0_x-5*$blockage_width] [expr $origin0_y-$blockage_width] [expr $origin0_x+$input_buffer_width+5*$blockage_width] [expr $origin0_y+$input_buffer_height+$blockage_width]
## acore
createPlaceBlockage -box [expr $origin1_x-$blockage_width] [expr $origin1_y-$blockage_width] [expr $origin1_x+$acore_width+$blockage_width] [expr $origin1_y+$acore_height+$blockage_width]
## memory
createPlaceBlockage -box [expr $origin2_x-5*$blockage_width] [expr $origin2_y-$blockage_width] [expr $origin2_x+$memory_width+5*$blockage_width] [expr $origin2_y+$memory_height+$blockage_width]
## input_buffer_test
createPlaceBlockage -box [expr $origin3_x-5*$blockage_width] [expr $origin3_y-$blockage_width] [expr $origin3_x+$input_buffer_width+5*$blockage_width] [expr $origin3_y+2*$input_buffer_height+$blockage_width+4*$cell_height]
## output_buffer
createPlaceBlockage -box [expr $origin4_x-$blockage_width] [expr $origin4_y-$blockage_width] [expr $origin4_x+$output_buffer_width+$blockage_width] [expr $origin4_y+$output_buffer_height+$blockage_width] 
## input_buffer_aux
createPlaceBlockage -box [expr $center_x-$input_buffer_width/2-5*$blockage_width] [expr $origin1_y-$input_buffer_height-32*$cell_height-$blockage_height] [expr $center_x-$input_buffer_width/2+$input_buffer_width+5*$blockage_width] [expr $origin1_y-32*$cell_height+$blockage_height] 



## boundary 
addEndCap



## welltap
## outmost welltap
addWellTap -cell TAPCELLBWP16P90 -cellInterval $FP_width -prefix WELLTAP 

## input_buffer_async
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin0_x+$input_buffer_width+$blockage_width+$DB_width] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin0_x+$input_buffer_width/2] -cellInterval 1000 -prefix WELLTAP

## input_buffer_test
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin0_x+$input_buffer_width+$blockage_width+$DB_width)-$welltap_width] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin0_x+$input_buffer_width/2)-$welltap_width] -cellInterval 1000 -prefix WELLTAP

##output_buffer
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin0_x+$input_buffer_width/2)-$welltap_width] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin0_x+$input_buffer_width/2)-$welltap_width] -cellInterval 1000 -prefix WELLTAP
#addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin0_x+$input_buffer_width/2)-$welltap_width] -cellInterval 1000 -prefix WELLTAP
#addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin0_x+$input_buffer_width/2)-$welltap_width] -cellInterval 1000 -prefix WELLTAP
#addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin4_x+$output_buffer_width+$blockage_width+$DB_width] -cellInterval 1000 -prefix WELLTAP
#addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin4_x+$output_buffer_width+$blockage_width+$DB_width] -cellInterval 1000 -prefix WELLTAP
#addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin4_x+$output_buffer_width+$blockage_width+$DB_width] -cellInterval 1000 -prefix WELLTAP
#addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin4_x+$output_buffer_width+$blockage_width+$DB_width] -cellInterval 1000 -prefix WELLTAP

# acore
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin1_x-$blockage_width-$DB_width-$welltap_width] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin1_x-$blockage_width-$DB_width)] -cellInterval 1000 -prefix WELLTAP

# memory
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin1_x+$memory_width/2+$blockage_width+$DB_width] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin1_x+$memory_width+$blockage_width+$DB_width] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin1_x+$memory_width+$blockage_width+$DB_width+30] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin1_x+$memory_width+$blockage_width+$DB_width+60] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin1_x+$memory_width/2+$blockage_width+$DB_width)] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin1_x+$memory_width+$blockage_width+$DB_width)] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin1_x+$memory_width+$blockage_width+$DB_width+30)] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin1_x+$memory_width+$blockage_width+$DB_width+60)] -cellInterval 1000 -prefix WELLTAP

# input_buffer_aux
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $center_x-$welltap_width/2] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $center_x-$input_buffer_width/2-$blockage_width-$DB_width-$welltap_width] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($center_x-$input_buffer_width/2-$blockage_width-$DB_width)] -cellInterval 1000 -prefix WELLTAP

## dcore
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin0_x+$input_buffer_width+$blockage_width+$DB_width+25] -cellInterval 1000 -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin0_x+$input_buffer_width+$blockage_width+$DB_width+25)] -cellInterval 1000 -prefix WELLTAP



gui_select -rect {471.778 697.873 480.697 250.453}
deleteSelectedFromFPlan




#################################################################################################################
###################  Power Connects  ############################################################################
#################################################################################################################

# (DVDD)
globalNetConnect DVDD -type pgpin -pin VDD -inst * -override
globalNetConnect DVSS -type pgpin -pin VSS -inst * -override
globalNetConnect DVDD -type pgpin -pin VPP -inst * -override
globalNetConnect DVSS -type pgpin -pin VBB -inst * -override

globalNetConnect DVDD -type pgpin -pin DVDD -inst {iacore} -override
globalNetConnect DVSS -type pgpin -pin DVSS -inst {iacore} -override

globalNetConnect AVDD -type pgpin -pin AVDD -inst {iacore} -override
globalNetConnect AVSS -type pgpin -pin AVSS -inst {iacore} -override

globalNetConnect CVDD -type pgpin -pin CVDD -inst {iacore} -override
globalNetConnect CVSS -type pgpin -pin CVSS -inst {iacore} -override

globalNetConnect DVDD -type pgpin -pin avdd -inst {*ibuf_*} -override
globalNetConnect DVSS -type pgpin -pin avss -inst {*ibuf_*} -override

createRouteBlk -box [expr $origin0_x-$blockage_width] [expr $origin0_y-$blockage_width] [expr $origin0_x+$input_buffer_width+$blockage_width] [expr $origin0_y+$input_buffer_height+$blockage_width] -name inbuf_async_blk -layer 1
createRouteBlk -box [expr $origin2_x-$blockage_width] [expr $origin2_y-$blockage_width] [expr $origin2_x+$memory_width+$blockage_width] [expr $origin2_y+$memory_height+$blockage_width] -name memory_blk -layer 1
createRouteBlk -box [expr $origin3_x-$blockage_width] [expr $origin3_y-$blockage_width] [expr $origin3_x+$input_buffer_width+$blockage_width] [expr $origin3_y+2*$input_buffer_height+$blockage_width] -name inbuf_test_blk -layer 1
createRouteBlk -box [expr $center_x-$input_buffer_width/2-$blockage_width] [expr $origin1_y-$input_buffer_height-32*$cell_height-$blockage_height] [expr $center_x-$input_buffer_width/2+$input_buffer_width+$blockage_width] [expr $origin1_y-32*$cell_height+$blockage_height] -name inbuf_aux_blk -layer 1 

addStripe -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -master "BOUND*"   \
  -merge_stripes_value 0.045   \
  -create_pins 1 \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -extend_to design_boundary \
  -nets {DVDD DVSS} 

deleteRouteBlk -name *




set input_buffer_offset 21.104
set output_buffer_offset 1.0

createRouteBlk -box [expr $origin1_x-$blockage_width] [expr $origin1_y-$blockage_width-$cell_height] [expr $origin1_x+$acore_width+$blockage_width] $FP_height -name acore_blk -layer 7

# input_buffers
addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width 2 -spacing 1 -start_offset [expr $origin0_x+$input_buffer_offset] -stop_offset [expr $FP_width-($origin0_x+$input_buffer_width-$input_buffer_offset+1)] -set_to_set_distance 6 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary

addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width 2 -spacing 1 -start_offset [expr $origin0_x+$input_buffer_offset] -stop_offset [expr $FP_width-($origin0_x+$input_buffer_width-$input_buffer_offset+1)] -set_to_set_distance 6 -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary

# memory
#addStripe -nets {DVSS DVDD} \
#  -layer M7 -direction vertical -width 2 -spacing 2 -start_offset  [expr $origin2_x+5.2]  -stop_offset [expr $FP_width-( $origin2_x+$memory_width+1)] -set_to_set_distance 16 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary

createRouteBlk -box [expr $center_x-10] [expr $origin1_y] [expr $center_x+10] [expr $origin1_y-30*$cell_height] -name inbuf_aux_blk2 -layer 7 

# input_buffer_aux
addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width 2 -spacing 1 -start_offset  [expr $center_x-$input_buffer_width/2+$input_buffer_offset]  -stop_offset [expr $FP_width-( $center_x+$input_buffer_width/2-$input_buffer_offset+1)] -set_to_set_distance 6 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary


createRouteBlk -box [expr $origin0_x-$blockage_width] [expr $origin0_y-$blockage_width] [expr $origin0_x+$input_buffer_width+$blockage_width] [expr $origin0_y+$input_buffer_height+$blockage_width] -name inbuf_async_blk -layer 7
createRouteBlk -box [expr $origin3_x-$blockage_width] [expr $origin3_y-$blockage_width] [expr $origin3_x+$input_buffer_width+$blockage_width] [expr $origin3_y+2*$input_buffer_height+$blockage_width+4*$cell_height] -name inbuf_test_blk -layer 7
createRouteBlk -box [expr $center_x-$input_buffer_width/2-$blockage_width] [expr $origin1_y-$input_buffer_height-32*$cell_height-$blockage_height] [expr $center_x-$input_buffer_width/2+$input_buffer_width+$blockage_width] [expr $origin1_y-32*$cell_height+$blockage_height] -name inbuf_aux_blk -layer 7 

# output_buffer
addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width 1 -spacing 0.5 -start_offset  [expr $origin4_x+$output_buffer_offset]  -stop_offset 8 -set_to_set_distance 8.55 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary

addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width 1 -spacing 0.5 -start_offset  [expr $origin4_x+$output_buffer_offset]  -stop_offset 8 -set_to_set_distance 8.55 -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary







#dcore 
#outmost stripe
addStripe -nets {DVDD DVSS} \
  -layer M7 -direction vertical -width 1 -spacing 0.5 -start_offset 0.5 -set_to_set_distance 1000 -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary

addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width 1 -spacing 0.5 -start_offset 0.5 -set_to_set_distance 1000 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary

# center stripe
addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width 1 -spacing 3 -start_offset 42 -stop_offset [expr $FP_width/2] -set_to_set_distance 20 -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary

addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width 1 -spacing 3 -start_offset 42 -stop_offset [expr $FP_width/2] -set_to_set_distance 20 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary

#selectWire 182.0000 0.0000 184.0000 291.0060 7 DVSS
#deleteSelectedFromFPlan
#selectWire 188.0000 0.0000 190.0000 291.0060 7 DVDD
#deleteSelectedFromFPlan


#sroute -connect { blockPin } -layerChangeRange { M7 } -blockPinTarget { blockPin } -deleteExistingRoutes -allowJogging 1 -crossoverViaLayerRange { M7 M1 } -nets { DVDD DVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M1 }
#sroute -connect { blockPin } -layerChangeRange { M7} -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M7 M1 } -nets { DVDD DVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M1 }


deleteRouteBlk -name *
createRouteBlk -box 0 0 [expr $FP_width] [expr $FP_height] -name entire_design_blk -layer 7


createRouteBlk -box [expr $origin0_x-$blockage_width] [expr $origin0_y-$blockage_width] [expr $origin0_x+$input_buffer_width+$blockage_width] [expr $origin0_y+$input_buffer_height+$blockage_width] -name inbuf_async_blk -layer {8 9}
createRouteBlk -box [expr $origin3_x-$blockage_width] [expr $origin3_y-$blockage_width] [expr $origin3_x+$input_buffer_width+$blockage_width] [expr $origin3_y+2*$input_buffer_height+$blockage_width+4*$cell_height] -name inbuf_test_blk -layer {8 9}
createRouteBlk -box [expr $center_x-$input_buffer_width/2-$blockage_width] [expr $origin1_y-$input_buffer_height-32*$cell_height-$blockage_height] [expr $center_x-$input_buffer_width/2+$input_buffer_width+$blockage_width] [expr $origin1_y-32*$cell_height+$blockage_height] -name inbuf_aux_blk -layer {8 9}
createRouteBlk -box [expr $origin1_x] [expr $FP_height] [expr $origin1_x+$acore_width] [expr $origin1_y-$blockage_height-2*$cell_height] -name acore_blk2 -layer {8 9}


sroute -connect { blockPin } -layerChangeRange { M8 M8 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M8 M7 } -nets { DVDD DVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M7 }

createRouteBlk -box 0 [expr $FP_height] [expr $FP_width] [expr $origin1_y] -name acore_blk_M8 -layer 8

addStripe -nets {DVDD DVSS } \
  -layer M8 -direction horizontal -width 2 -spacing 1 -start_offset 3 -set_to_set_distance 12 -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary 


deleteRouteBlk -name  acore_blk_M8

#addStripe -nets {DVSS DVDD } \
#  -layer M9 -direction vertical -width 4 -spacing 2 -start_offset 2  -set_to_set_distance 20 -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary 


deleteRouteBlk -name *


## RDL routing
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

set RDL_width1 4.0
set ext_clkp_offset 156.4
set ext_rx_inn_test_offset 171.0
set ext_rx_inp_test_offset 185.4
set ext_clkn_offset 199.6

setEdit -layer_vertical M10
setEdit -width_vertical $RDL_width1
setEdit -layer_horizontal M10
setEdit -width_horizontal $RDL_width1

setEdit -nets ext_clkp
editAddRoute [expr $origin1_x+$ext_clkp_offset+$RDL_width1/2]  [expr $origin1_y+4]
editCommitRoute [expr $origin1_x+$ext_clkp_offset+$RDL_width1/2]  0
setEdit -nets ext_clkn
editAddRoute [expr $origin1_x+$ext_clkn_offset+$RDL_width1/2]  [expr $origin1_y+4]
editCommitRoute [expr $origin1_x+$ext_clkn_offset+$RDL_width1/2]  0

setEdit -nets ext_rx_inn_test
editAddRoute [expr $origin1_x+$ext_rx_inn_test_offset+$RDL_width1/2]  [expr $origin1_y+4]
editCommitRoute [expr $origin1_x+$ext_rx_inn_test_offset+$RDL_width1/2]  0
setEdit -nets ext_rx_inp_test
editAddRoute [expr $origin1_x+$ext_rx_inp_test_offset+$RDL_width1/2]  [expr $origin1_y+4]
editCommitRoute [expr $origin1_x+$ext_rx_inp_test_offset+$RDL_width1/2]  0




###########
# IO file #
###########
loadIoFile ./data/butterphy_top.io

setEdit -nets ext_clk_async_n
editAddRoute 0 [expr $origin0_y+20.592]
editCommitRoute [expr $origin0_x+$input_buffer_width]  [expr $origin0_y+20.592]
editAddRoute [expr $origin0_x+$input_buffer_width] [expr $origin0_y+4]
editCommitRoute [expr $origin0_x+$input_buffer_width]  [expr $origin0_y+20.592]


setEdit -nets ext_clk_test0_n
editAddRoute $FP_width  [expr $origin3_y+$input_buffer_height+4*$cell_height+23.04]
editCommitRoute [expr $FP_width-($origin0_x+$input_buffer_width)]  [expr $origin3_y+$input_buffer_height+4*$cell_height+23.04]
editAddRoute [expr $FP_width-($origin0_x+$input_buffer_width)]  [expr $origin3_y+$input_buffer_height+4*$cell_height+23.04]
editCommitRoute [expr $FP_width-($origin0_x+$input_buffer_width)]  [expr $origin3_y+$input_buffer_height+4*$cell_height+4]

setEdit -nets ext_clk_test1_n
editAddRoute $FP_width  [expr $origin3_y+$input_buffer_height-23.04]
editCommitRoute [expr $FP_width-($origin0_x+$input_buffer_width)]  [expr $origin3_y+$input_buffer_height-23.04]
editAddRoute  [expr $FP_width-($origin0_x+$input_buffer_width)]  [expr $origin3_y+$input_buffer_height-23.04]
editCommitRoute [expr $FP_width-($origin0_x+$input_buffer_width)]  [expr $origin3_y+$input_buffer_height-4]










sroute -connect { blockPin } -layerChangeRange { M10 M10 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M10 M10 } -nets { AVDD AVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M10 M10 }

sroute -connect { blockPin } -layerChangeRange { M10 M10 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M10 M10 } -nets { CVDD CVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M10 M10 }



createRouteBlk -box [expr $origin0_x] [expr $origin0_y] [expr $origin0_x+$input_buffer_width] [expr $origin0_y+$input_buffer_height] -name inbuf_async_blk -layer {7 8 9}
createRouteBlk -box [expr $origin3_x] [expr $origin3_y] [expr $origin3_x+$input_buffer_width] [expr $origin3_y+$input_buffer_height] -name inbuf_test_blk1 -layer {7 8 9}
createRouteBlk -box [expr $origin3_x] [expr $origin3_y+$input_buffer_height+4*$cell_height] [expr $origin3_x+$input_buffer_width] [expr $origin3_y+2*$input_buffer_height+4*$cell_height] -name inbuf_test_blk2 -layer {7 8 9}
createRouteBlk -box [expr $center_x-$input_buffer_width/2] [expr $origin1_y-$input_buffer_height-32*$cell_height] [expr $center_x-$input_buffer_width/2+$input_buffer_width] [expr $origin1_y-32*$cell_height] -name inbuf_aux_blk -layer {7 8 9}
createRouteBlk -box [expr $origin2_x] [expr $origin2_y] [expr $origin2_x+$memory_width] [expr $origin2_y+$memory_height] -name memory_blk -layer {4 5 6 7}


createRouteBlk -box [expr $origin1_x-$blockage_width-$DB_width-$welltap_width] $FP_height [expr  $origin1_x+$blockage_width+$DB_width+$welltap_width+$acore_width] [expr $origin1_y+$acore_height] -name acore_blk -layer {1 2 3 4 5 6 7 8}




sroute -connect { blockPin } -layerChangeRange { M9 M9 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M9 M9 } -nets { AVDD AVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M9 M9 }



createRouteBlk -box 0 0 $FP_width $FP_height -name phy_blk -layer {7}

createRouteBlk -box [expr $origin4_x+$output_buffer_width] [expr $origin4_y-20]  $FP_width [expr $origin4_y+$output_buffer_height+20] -name output_blk -layer {9}

addStripe -nets {DVSS DVDD } \
  -layer M9 -direction vertical -width 4 -spacing 2 -start_offset 1.03 -set_to_set_distance 20.16 -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary 


deleteRouteBlk -name output_blk

## Instance Group for JTAG
createInstGroup grp0 -region [expr $origin2_x+$memory_width]  0 [expr $origin1_x+$acore_width] [expr $origin1_y]
addInstToInstGroup grp0 idcore/jtag_i/*


## NDR
add_ndr -name NDR_5W2S -spacing {M1:M2 0.05 M3 0.05 M4:M7 0.05} -width {M1:M2 0.18 M3 0.18 M4:M7 0.2

foreach_in_collection i [get_nets *clk_out*] {
        setAttribute -net [get_object_name $i] -non_default_rule NDR_5W2S
}
foreach_in_collection i [get_nets *clk_trig*] {
        setAttribute -net [get_object_name $i] -non_default_rule NDR_5W2S
}







