#enow#############
# MACRO Info #
##############

set boundary_width [expr $welltap_width+$DB_width]
set boundary_height [expr $cell_height]
set blockage_width [expr 10*$cell_grid]
set blockage_height [expr 2*$cell_height]

#---------------------------------------
# macro size info
# --------------------------------------
set acore_width 400.77
set acore_height 393.984
set mdll_width 70.2
set mdll_height 70.848
set input_buffer_width 53.1
set input_buffer_height 50.112
set output_buffer_width 13.05
set output_buffer_height 18.432 
set memory_width 64.175
set memory_height 249.84

#---------------------------------------
# macro placement
# --------------------------------------
set acore_x 199.98
set acore_y 399.744
set mdll_x 462.51
set mdll_y 301.824
set inbuf_async_x 43.56
set inbuf_async_y 312.192
set inbuf_main_x 373.77
set inbuf_main_y 312.192
set inbuf_mdll_ref_x 504.09
set inbuf_mdll_ref_y 184.32
set inbuf_mdll_mon_x 566.82
set inbuf_mdll_mon_y 184.32
set outbuf_x 555.3
set outbuf_y 140.544

#set Nmemory 8
#set memory_x [expr ceil(80/$cell_grid)*$cell_grid] 
#set memory_y [expr ceil(20/$cell_height)*$cell_height] 
#set memory_pitch [expr ceil(15/$cell_grid)*$cell_grid]

# Floor Plan #-----------------------------------------------------------------------------
set FP_width 800
set FP_height 800
set center_x [expr $FP_width/2]
set center_y [expr $FP_height/2]
floorPlan -site core -s $FP_width $FP_height 0 0 0 0
#------------------------------------------------------------------------------------------


## welltap parameters ------------------------------------------------------------------ 
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
#------------------------------------------------------------------------------------------


#Macro Placement -------------------------------------------------------------------
placeInstance iacore $acore_x $acore_y 
placeInstance imdll $mdll_x $mdll_y 
placeInstance ibuf_async $inbuf_async_x $inbuf_async_y MY
placeInstance ibuf_main $inbuf_main_x $inbuf_main_y
placeInstance ibuf_mdll_ref $inbuf_mdll_ref_x $inbuf_mdll_ref_y
placeInstance ibuf_mdll_mon $inbuf_mdll_mon_x $inbuf_mdll_mon_y MY 
placeInstance idcore/out_buff_i $outbuf_x $outbuf_y

#for { set k 0} {$k < [expr $Nmemory/2]} {incr k} {
#        set x_cor [expr $memory_x+${k}*($memory_width+$memory_pitch)]
#        set y_cor [expr $memory_y]
#            placeInstance idcore/oneshot_multimemory_i/genblk3_${k}__sram_i/memory $x_cor $y_cor 
#    }

#for { set k 0} {$k < [expr $Nmemory/2]} {incr k} {
#        set x_cor [expr $memory_x+[expr $k+$Nmemory/2]*($memory_width+$memory_pitch)]
#        set y_cor [expr $memory_y]
#            placeInstance idcore/omm_ffe_i/genblk3_${k}__sram_i/memory $x_cor $y_cor 
#    }

#------------------------------------------------------------------------------------------


## outmost blockcage---------------------------------------------------------------------
createPlaceBlockage -box 0 0 $FP_width  $blockage_height
createPlaceBlockage -box 0 $FP_height $FP_width  [expr $FP_height-$blockage_height]
createPlaceBlockage -box 0 0 $blockage_width $FP_height
createPlaceBlockage -box $FP_width 0 [expr $FP_width-$blockage_width] $FP_height
#-------------------------------------------------------------------------------------


createPlaceBlockage -box [expr $inbuf_async_x - $blockage_width ] [expr $inbuf_async_y - $blockage_height] [expr $inbuf_async_x+$input_buffer_width + $blockage_width] [expr $inbuf_async_y+$input_buffer_height + $blockage_height] 

createPlaceBlockage -box [expr $inbuf_main_x - $blockage_width ] [expr $inbuf_main_y - $blockage_height] [expr $inbuf_main_x+$input_buffer_width + $blockage_width] [expr $inbuf_main_y+$input_buffer_height + $blockage_height] 
createPlaceBlockage -box [expr $inbuf_mdll_ref_x - $blockage_width ] [expr $inbuf_mdll_ref_y - $blockage_height] [expr $inbuf_mdll_ref_x+$input_buffer_width + $blockage_width] [expr $inbuf_mdll_ref_y+$input_buffer_height + $blockage_height] 
createPlaceBlockage -box [expr $inbuf_mdll_mon_x - $blockage_width ] [expr $inbuf_mdll_mon_y - $blockage_height] [expr $inbuf_mdll_mon_x+$input_buffer_width + $blockage_width] [expr $inbuf_mdll_mon_y+$input_buffer_height + $blockage_height] 
createPlaceBlockage -box [expr $outbuf_x - $blockage_width ] [expr $outbuf_y - $blockage_height] [expr $outbuf_x+$output_buffer_width + $blockage_width] [expr $outbuf_y+$output_buffer_height + $blockage_height] 
createPlaceBlockage -box [expr $mdll_x - $blockage_width ] [expr $mdll_y - $blockage_height] [expr $mdll_x+$mdll_width + $blockage_width] [expr $mdll_y+$mdll_height + $blockage_height] 




## macro boundary ----------------------------------------------------------------- 
addEndCap
#-------------------------------------------------------------------------------------

## outmost welltap ----------------------------------------------------------------
addWellTap -cell TAPCELLBWP16P90 -cellInterval $FP_width -prefix WELLTAP 
#-------------------------------------------------------------------------------------


# (global power connect) --------------------------------------------------------
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

globalNetConnect DVDD -type pgpin -pin DVDD -inst {imdll} -override
globalNetConnect DVSS -type pgpin -pin DVSS -inst {imdll} -override

globalNetConnect CVDD -type pgpin -pin CVDD1 -inst {imdll} -override
globalNetConnect CVDD -type pgpin -pin CVDD2 -inst {imdll} -override
#-------------------------------------------------------------------------------------

# M1 blockages




# M1 power strips ---------------------------------------------------------------
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

#-------------------------------------------------------------------------------------

deleteRouteBlk -name *






# power for inout buffers / MDLL (stretch out M6)-----------------------------------------------------------
#sroute -connect { blockPin } -inst {ibuf_async ibuf_main ibuf_mdll_ref ibuf_mdll_mon} -layerChangeRange { M6 M6 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets {DVDD} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }
#sroute -connect { blockPin } -inst {ibuf_async ibuf_main ibuf_mdll_ref ibuf_mdll_mon}  -layerChangeRange { M6 M6 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets {DVSS} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }

#sroute -connect { blockPin } -layerChangeRange { M6 M6 } -blockPinTarget { blockPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets {DVDD} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }
#sroute -connect { blockPin } -layerChangeRange { M6 M6 } -blockPinTarget { blockPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets {DVSS} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }

#sroute -connect { blockPin } -inst {imdll} -layerChangeRange { M6 M6 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets {CVDD DVDD DVSS} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }

#sroute -connect { blockPin } -inst {ibuf_async ibuf_main ibuf_mdll_ref ibuf_mdll_mon} -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M8 M1 } -nets {DVDD DVSS} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M1 }



# --------------------------------------------------------------------------------------------------------------
# M7 power connections for macros
# --------------------------------------------------------------------------------------------------------------


set inbuf_M7_power_pin_offset1 20.996
set inbuf_M7_power_pin_offset2 21.104
set inbuf_M7_power_width 2
set inbuf_M7_power_space 1

sroute -connect { blockPin } -inst {idcore/out_buff_i} -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M8 M1 } -nets {DVDD DVSS} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M1 }


addStripe -nets {DVDD DVSS} \
  -layer M7 -direction vertical -width $inbuf_M7_power_width -spacing $inbuf_M7_power_space -start_offset [expr $inbuf_async_x+$inbuf_M7_power_pin_offset1] -stop_offset [expr $FP_width-($inbuf_async_x+$inbuf_M7_power_pin_offset1+4*$inbuf_M7_power_width+3*$inbuf_M7_power_space)] -set_to_set_distance [expr 2*($inbuf_M7_power_width+$inbuf_M7_power_space)]  -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary

addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width $inbuf_M7_power_width -spacing $inbuf_M7_power_space -start_offset [expr $inbuf_main_x+$inbuf_M7_power_pin_offset2] -stop_offset [expr $FP_width-($inbuf_main_x+$inbuf_M7_power_pin_offset2+4*$inbuf_M7_power_width+3*$inbuf_M7_power_space)] -set_to_set_distance [expr 2*($inbuf_M7_power_width+$inbuf_M7_power_space)]  -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary


createRouteBlk -box 0 $mdll_y $inbuf_mdll_mon_x $FP_height -layer 7 -name M7_blk_mdll
createRouteBlk -box $outbuf_x 0 [expr $outbuf_x+$output_buffer_width] $outbuf_y -layer 7 -name M7_blk_inbuff_mdll

addStripe -nets {DVSS DVDD} \
  -layer M7 -direction vertical -width $inbuf_M7_power_width -spacing $inbuf_M7_power_space -start_offset [expr $inbuf_mdll_ref_x+$inbuf_M7_power_pin_offset2] -stop_offset [expr $FP_width-($inbuf_mdll_ref_x+$inbuf_M7_power_pin_offset2+4*$inbuf_M7_power_width+3*$inbuf_M7_power_space)] -set_to_set_distance [expr 2*($inbuf_M7_power_width+$inbuf_M7_power_space)]  -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary


addStripe -nets {DVDD DVSS} \
  -layer M7 -direction vertical -width $inbuf_M7_power_width -spacing $inbuf_M7_power_space -start_offset [expr $inbuf_mdll_mon_x+$inbuf_M7_power_pin_offset1] -stop_offset [expr $FP_width-($inbuf_mdll_mon_x+$inbuf_M7_power_pin_offset1+4*$inbuf_M7_power_width+3*$inbuf_M7_power_space)] -set_to_set_distance [expr 2*($inbuf_M7_power_width+$inbuf_M7_power_space)]  -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary


addStripe -nets {DVDD DVSS} \
  -layer M7 -direction vertical -width [expr $inbuf_M7_power_width/2] -spacing [expr $inbuf_M7_power_space] -start_offset [expr $outbuf_x+$output_buffer_width/2-$inbuf_M7_power_space/2-$inbuf_M7_power_width/2] -set_to_set_distance $FP_width  -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
deleteRouteBlk -name M7_blk_inbuff_mdll

deleteRouteBlk -name M7_blk_*

addStripe -nets {DVDD DVSS} \
  -layer M7 -direction vertical -width [expr $inbuf_M7_power_width/2] -spacing [expr $inbuf_M7_power_space] -start_offset [expr ($inbuf_main_x+$input_buffer_width+$mdll_x)/2-$inbuf_M7_power_space/2-$inbuf_M7_power_width/2] -set_to_set_distance $FP_width  -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary

sroute -connect { blockPin } -inst {imdll} -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M8 M1 } -nets {DVDD DVSS} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M1 }



# --------------------------------------------------------------------------------------------------------------
# M6 power connections for mdll
# --------------------------------------------------------------------------------------------------------------
set mdll_CVDD_pin_offset1 5.768
set mdll_CVDD_pin_offset2 61.480
set mdll_CVDD_pin_width 1
set mdll_CVDD_pin_space 1.6


createRouteBlk -box 0 0 $mdll_x $FP_height -layer 6 -name M6_blk_mdll_left
createRouteBlk -box $inbuf_mdll_mon_x 0 $FP_width $FP_height -layer 6 -name M6_blk_mdll_right

addStripe -nets {CVDD CVDD} \
  -layer M6 -direction horizontal -width $mdll_CVDD_pin_width -spacing $mdll_CVDD_pin_space -start_offset [expr $mdll_y+$mdll_CVDD_pin_offset1] -set_to_set_distance $FP_width  -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary

addStripe -nets {CVDD CVDD} \
  -layer M6 -direction horizontal -width $mdll_CVDD_pin_width -spacing $mdll_CVDD_pin_space -start_offset [expr $mdll_y+$mdll_CVDD_pin_offset2] -set_to_set_distance $FP_width  -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary

deleteRouteBlk -name M6_blk_mdll_*



if {0} {

# power grid parameters --------------------------------------------------------------------------------
set dcore_M7_width 1
set dcore_M7_space 1
set dcore_M7_set_to_set 100

set dcore_M8_width 2
set dcore_M8_space 1
set dcore_M8_set_to_set 100

set dcore_M9_width 4
set dcore_M9_space 1
set dcore_M9_set_to_set 100
#--------------------------------------------------------------------------------------------------------------


# dcore main power grid (M7)---------------------------------------------------------------------------
createRouteBlk -box $acore_x  $acore_y [expr $acore_x+$acore_width] $FP_height -layer 7 -name M7_blk_acore

addStripe -nets {DVDD DVSS} \
  -layer M7 -direction vertical -width $dcore_M7_width -spacing [expr $dcore_M7_space] -start_offset [expr $boundary_width] -set_to_set_distance $dcore_M7_set_to_set -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
#--------------------------------------------------------------------------------------------------------------


# stretch out acore DVDD/DVSS (M8)-------------------------------------------------------------------------
sroute -connect { blockPin } -layerChangeRange { M8 M9 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M8 M7 } -nets { DVDD DVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M7 }
#--------------------------------------------------------------------------------------------------------------


# dcore main power grid (M8)---------------------------------------------------------------------------
createRouteBlk -box 0 [expr $acore_y-$blockage_height] $FP_width $FP_height -layer 8 -name M8_blk_acore

addStripe -nets {DVDD DVSS} \
  -layer M8 -direction horizontal -width $dcore_M8_width -spacing [expr $dcore_M8_space] -start_offset [expr $boundary_width] -set_to_set_distance $dcore_M8_set_to_set -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
#--------------------------------------------------------------------------------------------------------------


#dcore main power grid (M9)---------------------------------------------------------------------------------
createRouteBlk -box [expr $acore_x-10]  $acore_y $acore_x $FP_height -layer 9 -name M9_blk_acore_left
createRouteBlk -box $acore_x [expr $acore_y+$acore_height] [expr $acore_x+$acore_width] $FP_height -layer 9 -name M9_blk_acore_top
createRouteBlk -box 0 0 $FP_width $FP_height -layer 7 -name M9_via_blk

addStripe -nets {DVDD DVSS} \
  -layer M9 -direction vertical -width $dcore_M9_width -spacing [expr $dcore_M9_space] -start_offset [expr $boundary_width] -set_to_set_distance $dcore_M9_set_to_set -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
#--------------------------------------------------------------------------------------------------------------

deleteRouteBlk -all


# analog signal pin parameters ------------------------------------------------------------------------------
set rx_in_pin_width 57
set rx_in_pin_height 10
set rx_in_pin_offset_x 138.385
set rx_in_pin_offset_y 211.576

set rx_in_test_pin_width 5
set rx_in_test_pin_height 5
set rx_inp_test_pin_offset_x 178.22
set rx_inn_test_pin_offset_x 218.54

set Vcm_pin_width 5
set Vcm_pin_height 5
set Vcm_pin_offset_x 198.38
set Vcm_pin_offset_y [expr $acore_height-$Vcm_pin_height] 

set Vcal_pin_width 5
set Vcal_pin_height 5
set Vcal_pin_offset_x 253.82
set Vcal_pin_offset_y [expr $acore_height-$Vcm_pin_height] 

set inbuf_pin_width 8.951
set inbuf_pin_height 8.1
set inbuf_pin_offset_x 0.018
set inbuf_pin_offset_y 3.205

set outbuf_pin_width 3.6
set outbuf_pin_height 3.6
set outbuf_pin_space 3.6 
set outbuf_pin_offset_x [expr $output_buffer_width+3]
set outbuf_pin_offset_y [expr $outbuf_pin_space/2]

set M10_power_width 20
set CVDD_pin_offset_y 97.626
set CVSS_pin_offset_y 127.626
set AVSS_pin_offset_y 285.526
set AVDD_pin_offset_y 315.526
#----------------------------------------------------------------------------------------------------



#----------------------------------------------------------------------------------------------------
# Assigning Analog signal pins ----------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------

# [ext_rx_in]
createPhysicalPin ext_rx_inp -net ext_rx_inp -layer 10 -rect [expr $acore_x+$rx_in_pin_offset_x] [expr $acore_y+$rx_in_pin_offset_y] [expr $acore_x+$rx_in_pin_offset_x+$rx_in_pin_width] [expr $acore_y+$rx_in_pin_offset_y+$rx_in_pin_height] 
createPhysicalPin ext_rx_inn -net ext_rx_inn -layer 10 -rect [expr $acore_x+$acore_width-($rx_in_pin_offset_x)] [expr $acore_y+$rx_in_pin_offset_y] [expr $acore_x+$acore_width-($rx_in_pin_offset_x+$rx_in_pin_width)] [expr $acore_y+$rx_in_pin_offset_y+$rx_in_pin_height] 
# [Vcm]
createPhysicalPin ext_Vcm -net ext_Vcm -layer 9 -rect [expr $acore_x+$Vcm_pin_offset_x] [expr $acore_y+$Vcm_pin_offset_y] [expr $acore_x+$Vcm_pin_offset_x+$Vcm_pin_width] [expr $acore_y+$Vcm_pin_offset_y+$Vcm_pin_height] 
# [Vcal]
createPhysicalPin ext_Vcal -net ext_Vcal -layer 9 -rect [expr $acore_x+$Vcal_pin_offset_x] [expr $acore_y+$Vcal_pin_offset_y] [expr $acore_x+$Vcal_pin_offset_x+$Vcal_pin_width] [expr $acore_y+$Vcal_pin_offset_y+$Vcal_pin_height] 

#[ext_rx_in_test]
createPhysicalPin ext_rx_inp_test -net ext_rx_inp_test -layer 9 -rect [expr $acore_x+$rx_inp_test_pin_offset_x] [expr $acore_y] [expr $acore_x+$rx_inp_test_pin_offset_x+$rx_in_test_pin_width] [expr $acore_y+$rx_in_test_pin_height] 
createPhysicalPin ext_rx_inn_test -net ext_rx_inn_test -layer 9 -rect [expr $acore_x+$rx_inn_test_pin_offset_x] [expr $acore_y] [expr $acore_x+$rx_inn_test_pin_offset_x+$rx_in_test_pin_width] [expr $acore_y+$rx_in_test_pin_height] 


# [ext_clk_async]
createPhysicalPin ext_clk_async_p -net ext_clk_async_p -layer 10 -rect [expr $inbuf_async_x+$inbuf_pin_offset_x] [expr $inbuf_async_y+$inbuf_pin_offset_y] [expr $inbuf_async_x+$inbuf_pin_offset_x+$inbuf_pin_width] [expr $inbuf_async_y+$inbuf_pin_offset_y+$inbuf_pin_height]
createPhysicalPin ext_clk_async_n -net ext_clk_async_n -layer 10 -rect [expr $inbuf_async_x+$input_buffer_width-($inbuf_pin_offset_x)] [expr $inbuf_async_y+$inbuf_pin_offset_y] [expr $inbuf_async_x+$input_buffer_width-($inbuf_pin_width)] [expr $inbuf_async_y+$inbuf_pin_offset_y+$inbuf_pin_height]
# [ext_clk]
createPhysicalPin ext_clkp -net ext_clkp -layer 10 -rect [expr $inbuf_main_x+$inbuf_pin_offset_x] [expr $inbuf_main_y+$inbuf_pin_offset_y] [expr $inbuf_main_x+$inbuf_pin_offset_x+$inbuf_pin_width] [expr $inbuf_main_y+$inbuf_pin_offset_y+$inbuf_pin_height]
createPhysicalPin ext_clkn -net ext_clkn -layer 10 -rect [expr $inbuf_main_x+$input_buffer_width-($inbuf_pin_offset_x)] [expr $inbuf_main_y+$inbuf_pin_offset_y] [expr $inbuf_main_x+$input_buffer_width-($inbuf_pin_width)] [expr $inbuf_main_y+$inbuf_pin_offset_y+$inbuf_pin_height]
# [ext_mell_clk_ref]
createPhysicalPin ext_mdll_clk_refp -net ext_mdll_clk_refp -layer 10 -rect [expr $inbuf_mdll_ref_x+$inbuf_pin_offset_x] [expr $inbuf_mdll_ref_y+$inbuf_pin_offset_y] [expr $inbuf_mdll_ref_x+$inbuf_pin_offset_x+$inbuf_pin_width] [expr $inbuf_mdll_ref_y+$inbuf_pin_offset_y+$inbuf_pin_height]
createPhysicalPin ext_mdll_clk_refn -net ext_mdll_clk_refn -layer 10 -rect [expr $inbuf_mdll_ref_x+$input_buffer_width-($inbuf_pin_offset_x)] [expr $inbuf_mdll_ref_y+$inbuf_pin_offset_y] [expr $inbuf_mdll_ref_x+$input_buffer_width-($inbuf_pin_width)] [expr $inbuf_mdll_ref_y+$inbuf_pin_offset_y+$inbuf_pin_height]
# [ext_mell_clk_mon]
createPhysicalPin ext_mdll_clk_monp -net ext_mdll_clk_monp -layer 10 -rect [expr $inbuf_mdll_mon_x+$inbuf_pin_offset_x] [expr $inbuf_mdll_mon_y+$inbuf_pin_offset_y] [expr $inbuf_mdll_mon_x+$inbuf_pin_offset_x+$inbuf_pin_width] [expr $inbuf_mdll_mon_y+$inbuf_pin_offset_y+$inbuf_pin_height]
createPhysicalPin ext_mdll_clk_monn -net ext_mdll_clk_monn -layer 10 -rect [expr $inbuf_mdll_mon_x+$input_buffer_width-($inbuf_pin_offset_x)] [expr $inbuf_mdll_mon_y+$inbuf_pin_offset_y] [expr $inbuf_mdll_mon_x+$input_buffer_width-($inbuf_pin_width)] [expr $inbuf_mdll_mon_y+$inbuf_pin_offset_y+$inbuf_pin_height]
# [clk_out]
createPhysicalPin clk_out_n -net clk_out_n -layer 10 -rect [expr $outbuf_x+$outbuf_pin_offset_x] [expr $outbuf_y+$output_buffer_height/2+$outbuf_pin_offset_y] [expr $outbuf_x+$outbuf_pin_offset_x+$outbuf_pin_width] [expr $outbuf_y+$output_buffer_height/2+$outbuf_pin_offset_y+$outbuf_pin_height]
createPhysicalPin clk_out_p -net clk_out_p -layer 10 -rect [expr $outbuf_x+$outbuf_pin_offset_x] [expr $outbuf_y+$output_buffer_height/2+$outbuf_pin_offset_y+$outbuf_pin_space+$outbuf_pin_height] [expr $outbuf_x+$outbuf_pin_offset_x+$outbuf_pin_width] [expr $outbuf_y+$output_buffer_height/2+$outbuf_pin_offset_y+$outbuf_pin_space+2*$outbuf_pin_height] 
# [clk_trig]
createPhysicalPin clk_trig_p -net clk_trig_p -layer 10 -rect [expr $outbuf_x+$outbuf_pin_offset_x] [expr $outbuf_y+$output_buffer_height/2-($outbuf_pin_offset_y)] [expr $outbuf_x+$outbuf_pin_offset_x+$outbuf_pin_width] [expr $outbuf_y+$output_buffer_height/2-($outbuf_pin_offset_y+$outbuf_pin_height)]
createPhysicalPin clk_trig_n -net clk_trig_n -layer 10 -rect [expr $outbuf_x+$outbuf_pin_offset_x] [expr $outbuf_y+$output_buffer_height/2-($outbuf_pin_offset_y+$outbuf_pin_space+$outbuf_pin_height)] [expr $outbuf_x+$outbuf_pin_offset_x+$outbuf_pin_width] [expr $outbuf_y+$output_buffer_height/2-($outbuf_pin_offset_y+$outbuf_pin_space+2*$outbuf_pin_height)] 
#[CVDD/CVSS]
createPhysicalPin CVDD -net CVDD -layer 10 -rect [expr $acore_x] [expr $acore_y+$CVDD_pin_offset_y] [expr $acore_x+$acore_width]  [expr $acore_y+$CVDD_pin_offset_y+$M10_power_width]
createPhysicalPin CVSS -net CVSS -layer 10 -rect [expr $acore_x] [expr $acore_y+$CVSS_pin_offset_y] [expr $acore_x+$acore_width]  [expr $acore_y+$CVSS_pin_offset_y+$M10_power_width]
#[AVDD/AVSS]
createPhysicalPin AVSS -net AVSS -layer 10 -rect [expr $acore_x] [expr $acore_y+$AVSS_pin_offset_y] [expr $acore_x+$acore_width]  [expr $acore_y+$AVSS_pin_offset_y+$M10_power_width]
createPhysicalPin AVDD -net AVDD -layer 10 -rect [expr $acore_x] [expr $acore_y+$AVDD_pin_offset_y] [expr $acore_x+$acore_width]  [expr $acore_y+$AVDD_pin_offset_y+$M10_power_width]
# ----------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------
# Assign Digital signal pins -------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------
set pin_width 0.04
set pin_depth 0.4
set digital_pin_start_offset 500
set digital_pin_space 10
set digital_pins {ext_rstb ext_dump_start *phy*}
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -spreadDirection counterclockwise -edge 2 -layer 2  -spreadType start -unit MICRON -offsetStart $digital_pin_start_offset -spacing $digital_pin_space -pin $digital_pins
# ----------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------
# special route
# ----------------------------------------------------------------------------------------------------
# [CVDD connection between ACORE and MDLL]

setEdit -layer_minimum M1
setEdit -layer_maximum AP
setEdit -force_regular 1
getEdit -snap_to_track_regular
getEdit -snap_to_pin
setEdit -force_special 1
getEdit -snap_to_track
getEdit -snap_special_wire
getEdit -align_wire_at_pin
getEdit -snap_to_row
getEdit -snap_to_pin
setViaGenMode -ignore_DRC false
setViaGenMode -use_fgc 1
setViaGenMode -use_cce false

setEdit -layer_vertical M10
setEdit -width_vertical $M10_power_width
setEdit -nets CVDD
editAddRoute [expr $mdll_x+$mdll_width+$M10_power_width] [expr $acore_y+$CVDD_pin_offset_y]
editCommitRoute [expr $mdll_x+$mdll_width+10] [expr $mdll_y] 

# ----------------------------------------------------------------------------------------------------

}

