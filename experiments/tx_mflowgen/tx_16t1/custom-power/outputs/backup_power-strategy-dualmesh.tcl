    proc snap_to_grid {input granularity} {
       set new_value [expr ceil($input / $granularity) * $granularity]
       return $new_value
    }

    # Set the floorplan to target a reasonable placement density with a good
    # aspect ratio (height:width). An aspect ratio of 2.0 here will make a
    # rectangular chip with a height that is twice the width.

    set core_aspect_ratio   1.00; # Aspect ratio 1.0 for a square chip
    set core_density_target 0.70; # Placement density of 70% is reasonable

    set vert_pitch  [dbGet top.fPlan.coreSite.size_y]
    set horiz_pitch [dbGet top.fPlan.coreSite.size_x]

    set core_margin_t 0;#$vert_pitch
    set core_margin_b 0;#$vert_pitch 
    set core_margin_r 0;#[expr 5 * $horiz_pitch]
    set core_margin_l 0;#[expr 5 * $horiz_pitch]


    set output_buffer_width [dbGet [dbGet -p top.insts.name *out_buff_i*].cell.size_x]
    set output_buffer_height [dbGet [dbGet -p top.insts.name *out_buff_i*].cell.size_y]
    
    set acore_width [dbGet [dbGet -p top.insts.name *iacore*].cell.size_x]
    set acore_height [dbGet [dbGet -p top.insts.name *iacore*].cell.size_y]


    set mdll_width [dbGet [dbGet -p top.insts.name *imdll*].cell.size_x]
    set mdll_height [dbGet [dbGet -p top.insts.name *imdll*].cell.size_y]


    set FP_width [snap_to_grid [expr 800 + $sram_FP_adjust] $horiz_pitch ]
    set FP_height [snap_to_grid 800 $vert_pitch ]

    set sram_to_acore_spacing_x [snap_to_grid 40 $horiz_pitch]
    set sram_to_acore_spacing_y [snap_to_grid 40 $vert_pitch]
    
    set sram_to_buff_spacing_y [snap_to_grid 30 $vert_pitch]

    set sram_to_sram_spacing  [snap_to_grid 30 $horiz_pitch]
    set sram_neighbor_spacing [expr $sram_width + $sram_to_sram_spacing]
    set sram_pair_spacing [expr 2*$sram_width + $sram_to_sram_spacing]
    set sram_vert_spacing [snap_to_grid 200 $vert_pitch]


    set origin_acore_x    [expr 199.98 + $sram_FP_adjust]
    set origin_acore_y    399.744
    
    set origin_sram_ffe_x [expr 6*$blockage_width  + $core_margin_l]
    set origin_sram_ffe_y [expr 6*$blockage_height + $core_margin_b]
   
    set origin_sram_ffe_y2 [expr $FP_height - 6*$blockage_height - $core_margin_t -$sram_height ]
 
    set origin_sram_adc_x [expr $origin_sram_ffe_x]
    set origin_sram_adc_y [expr 6*$blockage_height + $core_margin_b] 
    set origin_sram_adc_y2 [expr $FP_height - 6*$blockage_height - $core_margin_t -$sram_height ]

    set origin_async_x [expr 43.56 + $sram_FP_adjust]
    set origin_async_y 312.192
    
    set origin_out_x [expr 555.3 + $sram_FP_adjust]
    set origin_out_y 140.544

    set origin_main_x [expr 373.77 + $sram_FP_adjust]
    set origin_main_y 312.192
 
    set origin_mdll_x [expr 462.51 + $sram_FP_adjust]
    set origin_mdll_y 301.824   
    
    set origin_mon_x [expr 566.82 + $sram_FP_adjust]
    set origin_mon_y 184.32

    set origin_ref_x [expr 504.09 + $sram_FP_adjust]
    set origin_ref_y 184.32

createRouteBlk -box \
    [expr $origin_mdll_x-$blockage_width] \
    [expr $origin_mdll_y-$blockage_width] \
    [expr $origin_mdll_x+$mdll_width+$blockage_width] \
    [expr $origin_mdll_y+$mdll_height+$blockage_width] \
    -name mdll_block -layer 1

createRouteBlk -box \
    [expr $origin_async_x-$blockage_width] \
    [expr $origin_async_y-$blockage_width] \
    [expr $origin_async_x+$input_buffer_width+$blockage_width] \
    [expr $origin_async_y+$input_buffer_height+$blockage_width] \
    -name inbuf_async_blk -layer 1

createRouteBlk -box \
    [expr $origin_main_x-$blockage_width] \
    [expr $origin_main_y-$blockage_width] \
    [expr $origin_main_x+$input_buffer_width+$blockage_width] \
    [expr $origin_main_y+$input_buffer_height+$blockage_width] \
    -name inbuf_main_blk -layer 1

createRouteBlk -box \
    [expr $origin_mon_x-$blockage_width] \
    [expr $origin_mon_y-$blockage_width] \
    [expr $origin_mon_x+$input_buffer_width+$blockage_width] \
    [expr $origin_mon_y+$input_buffer_height+$blockage_width] \
    -name inbuf_mon_blk -layer 1

createRouteBlk -box \
    [expr $origin_ref_x-$blockage_width] \
    [expr $origin_ref_y-$blockage_width] \
    [expr $origin_ref_x+$input_buffer_width+$blockage_width] \
    [expr $origin_ref_y+$input_buffer_height+$blockage_width] \
    -name inbuf_ref_blk -layer 1

createRouteBlk -box \
    [expr $origin_sram_ffe_x - $blockage_width] \
    [expr $origin_sram_ffe_y2 - $blockage_height] \
    [expr $origin_sram_ffe_x + 2*$sram_pair_spacing + $blockage_width] \
    [expr $origin_sram_ffe_y2 + $sram_height       + $blockage_height] \
    -name memory_ffe_blk -layer 1

createRouteBlk -box \
    [expr $origin_sram_adc_x - $blockage_width] \
    [expr $origin_sram_adc_y - $blockage_height] \
    [expr $origin_sram_adc_x + 2*$sram_pair_spacing + $blockage_width] \
    [expr $origin_sram_adc_y + $sram_height         + $blockage_height] \
    -name memory_adc_blk -layer 1

createRouteBlk -box \
    [expr $origin_acore_x-$blockage_width] \
    [expr $origin_acore_y-$blockage_width] \
    [expr $origin_acore_x+$acore_width+$blockage_width] \
    [expr $origin_acore_y+$acore_height+$blockage_width] \
    -name acore_blk -layer 1


addStripe \
    -pin_layer M1 \
    -over_pins 1 \
    -block_ring_top_layer_limit M1 \
    -max_same_layer_jog_length 3.6 \
    -padcore_ring_bottom_layer_limit M1 \
    -padcore_ring_top_layer_limit M1 \
    -spacing 1.8 \
    -master "BOUND*" \
    -merge_stripes_value 0.045 \
    -create_pins 1 \
    -direction horizontal \
    -layer M1 \
    -block_ring_bottom_layer_limit M1 \
    -width pin_width \
    -extend_to design_boundary \
    -nets {DVDD DVSS}

deleteRouteBlk -name *


set acore_x $origin_acore_x
set acore_y $origin_acore_y    

set inbuf_async_x $origin_async_x 
set inbuf_async_y $origin_async_y 

set outbuf_x $origin_out_x 
set outbuf_y $origin_out_y 

set inbuf_main_x $origin_main_x 
set inbuf_main_y $origin_main_y 

set mdll_x $origin_mdll_x 
set mdll_y $origin_mdll_y 

set inbuf_mdll_mon_x $origin_mon_x 
set inbuf_mdll_mon_y $origin_mon_y 

set inbuf_mdll_ref_x $origin_ref_x 
set inbuf_mdll_ref_y $origin_ref_y 

# power for inout buffers / MDLL (stretch out M6)-----------------------------------------------------------
sroute -connect { blockPin } -layerChangeRange { M6 M6 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets { DVDD DVSS CVDD } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }
sroute -connect { blockPin } -layerChangeRange { M6 M6 } -blockPinTarget { blockPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets { DVDD DVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }





#--------------------------------------------------------------------------------------------------------------


# M10 physical pin assignment for AVDD/AVSS/CVDD/CVSS-----------------------------------------------------------
set M10_power_width 20
set CVDD_pin_offset_y 97.626
set CVSS_pin_offset_y 127.626
set AVSS_pin_offset_y 285.526
set AVDD_pin_offset_y 315.526

#[CVDD/CVSS]
createPhysicalPin CVDD -net CVDD -layer 10 -rect [expr $acore_x] [expr $acore_y+$CVDD_pin_offset_y] [expr $acore_x+$acore_width]  [expr $acore_y+$CVDD_pin_offset_y+$M10_power_width]
createPhysicalPin CVSS -net CVSS -layer 10 -rect [expr $acore_x] [expr $acore_y+$CVSS_pin_offset_y] [expr $acore_x+$acore_width]  [expr $acore_y+$CVSS_pin_offset_y+$M10_power_width]
#[AVDD/AVSS]
createPhysicalPin AVSS -net AVSS -layer 10 -rect [expr $acore_x] [expr $acore_y+$AVSS_pin_offset_y] [expr $acore_x+$acore_width]  [expr $acore_y+$AVSS_pin_offset_y+$M10_power_width]
createPhysicalPin AVDD -net AVDD -layer 10 -rect [expr $acore_x] [expr $acore_y+$AVDD_pin_offset_y] [expr $acore_x+$acore_width]  [expr $acore_y+$AVDD_pin_offset_y+$M10_power_width]

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




#Routing blockages for input buffers
createRouteBlk -box $inbuf_async_x $inbuf_async_y [expr $inbuf_async_x+$input_buffer_width] [expr $inbuf_async_y+$input_buffer_height] -layer {7 8 9}
createRouteBlk -box $inbuf_main_x $inbuf_main_y [expr $inbuf_main_x+$input_buffer_width] [expr $inbuf_main_y+$input_buffer_height] -layer {7 8 9}
createRouteBlk -box $inbuf_mdll_ref_x $inbuf_mdll_ref_y [expr $inbuf_mdll_ref_x+$input_buffer_width] [expr $inbuf_mdll_ref_y+$input_buffer_height] -layer {7 8 9}
createRouteBlk -box $inbuf_mdll_mon_x $inbuf_mdll_mon_y [expr $inbuf_mdll_mon_x+$input_buffer_width] [expr $inbuf_mdll_mon_y+$input_buffer_height] -layer {7 8 9}


#Routing blockages for output buffers
createRouteBlk -box [expr $outbuf_x+$output_buffer_width] [expr $outbuf_y-5]  [expr $outbuf_x+$output_buffer_width+10] [expr $outbuf_y+$output_buffer_height+5] -layer {7 8 9} -name blk_outbuf


# power grid parameters --------------------------------------------------------------------------------
set dcore_M7_width 1
set dcore_M7_space 1
set dcore_M7_set_to_set 16

set dcore_M8_width 2
set dcore_M8_space 1
set dcore_M8_set_to_set 12

set dcore_M9_width 4
set dcore_M9_space 1
set dcore_M9_set_to_set 20
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
createRouteBlk -box $acore_x [expr $acore_y+$acore_height] [expr $acore_x+$acore_width] $FP_height -layer {2 3 4 5 6 7 8 9} -name blk_acore_top
createRouteBlk -box 0 0 $FP_width $FP_height -layer 7 -name M9_via_blk

addStripe -nets {DVDD DVSS} \
  -layer M9 -direction vertical -width $dcore_M9_width -spacing [expr $dcore_M9_space] -start_offset [expr $boundary_width] -set_to_set_distance $dcore_M9_set_to_set -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
#--------------------------------------------------------------------------------------------------------------

deleteRouteBlk -name M9_via_blk


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

set outbuf_pin_width 4
set outbuf_pin_height 4
set outbuf_pin_space 4 
set outbuf_pin_offset_x [expr $output_buffer_width+3]
set outbuf_pin_offset_y [expr $outbuf_pin_space]

#----------------------------------------------------------------------------------------------------


setPtnPinStatus -cell dragonphy_top -pin {*} -status unplaced -silent
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


set pin_clk_out_p_x [expr $outbuf_x+$outbuf_pin_offset_x]
set pin_clk_out_p_y [expr $outbuf_y+$output_buffer_height/2+$outbuf_pin_offset_y+$outbuf_pin_space+$outbuf_pin_height-1.8]

set pin_clk_out_n_x [expr $outbuf_x+$outbuf_pin_offset_x]
set pin_clk_out_n_y [expr $outbuf_y+$output_buffer_height/2+$outbuf_pin_offset_y]

set pin_clk_trig_p_x [expr $outbuf_x+$outbuf_pin_offset_x]
set pin_clk_trig_p_y [expr $outbuf_y+$output_buffer_height/2-$outbuf_pin_height-($outbuf_pin_offset_y)]

set pin_clk_trig_n_x [expr $outbuf_x+$outbuf_pin_offset_x]
set pin_clk_trig_n_y [expr $outbuf_y+$output_buffer_height/2-$outbuf_pin_height-($outbuf_pin_offset_y+$outbuf_pin_space+$outbuf_pin_height)+1.8]

# [clk_out]
createPhysicalPin clk_out_p -net clk_out_p -layer 10 -rect $pin_clk_out_p_x $pin_clk_out_p_y [expr $pin_clk_out_p_x+$outbuf_pin_width] [expr $pin_clk_out_p_y+$outbuf_pin_height]
createPhysicalPin clk_out_n -net clk_out_n -layer 10 -rect $pin_clk_out_n_x $pin_clk_out_n_y [expr $pin_clk_out_n_x+$outbuf_pin_width] [expr $pin_clk_out_n_y+$outbuf_pin_height]

# [clk_trig]
createPhysicalPin clk_trig_p -net clk_trig_p -layer 10 -rect $pin_clk_trig_p_x $pin_clk_trig_p_y [expr $pin_clk_trig_p_x+$outbuf_pin_width] [expr $pin_clk_trig_p_y+$outbuf_pin_height]
createPhysicalPin clk_trig_n -net clk_trig_n -layer 10 -rect $pin_clk_trig_n_x $pin_clk_trig_n_y [expr $pin_clk_trig_n_x+$outbuf_pin_width] [expr $pin_clk_trig_n_y+$outbuf_pin_height]

# [clk_out]
#[expr $outbuf_x+$outbuf_pin_offset_x] [expr $outbuf_y+$output_buffer_height/2+$outbuf_pin_offset_y] [expr $outbuf_x+$outbuf_pin_offset_x+$outbuf_pin_width] [expr $outbuf_y+$output_buffer_height/2+$outbuf_pin_offset_y+$outbuf_pin_height]
#createPhysicalPin clk_out_p -net clk_out_p -layer 10 -rect [expr $outbuf_x+$outbuf_pin_offset_x] [expr $outbuf_y+$output_buffer_height/2+$outbuf_pin_offset_y+$outbuf_pin_space+$outbuf_pin_height] [expr $outbuf_x+$outbuf_pin_offset_x+$outbuf_pin_width] [expr $outbuf_y+$output_buffer_height/2+$outbuf_pin_offset_y+$outbuf_pin_space+2*$outbuf_pin_height] 
# [clk_trig]
#createPhysicalPin clk_trig_p -net clk_trig_p -layer 10 -rect [expr $outbuf_x+$outbuf_pin_offset_x] [expr $outbuf_y+$output_buffer_height/2-($outbuf_pin_offset_y)] [expr $outbuf_x+$outbuf_pin_offset_x+$outbuf_pin_width] [expr $outbuf_y+$output_buffer_height/2-($outbuf_pin_offset_y+$outbuf_pin_height)]
#createPhysicalPin clk_trig_n -net clk_trig_n -layer 10 -rect [expr $outbuf_x+$outbuf_pin_offset_x] [expr $outbuf_y+$output_buffer_height/2-($outbuf_pin_offset_y+$outbuf_pin_space+$outbuf_pin_height)] [expr $outbuf_x+$outbuf_pin_offset_x+$outbuf_pin_width] [expr $outbuf_y+$output_buffer_height/2-($outbuf_pin_offset_y+$outbuf_pin_space+2*$outbuf_pin_height)] 
# ----------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------
# Assign slow Digital signal pins -------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------
set pin_width 0.04
set pin_depth 0.4
set digital_pin_start_offset 500
set digital_pin_space 10
set digital_pins {ext_rstb ext_dump_start *phy*}
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -spreadDirection counterclockwise -edge 2 -layer 2  -spreadType start -unit MICRON -offsetStart $digital_pin_start_offset -spacing $digital_pin_space -pin $digital_pins
# ----------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------
# Assign clk_cgra    --------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -spreadDirection counterclockwise -edge 3 -layer 3  -spreadType start -unit MICRON -offsetStart [expr $FP_width/2] -spacing $digital_pin_space -pin clk_cgra
# ----------------------------------------------------------------------------------------------------

deleteRouteBlk -name blk_outbuf



## adding special wires for output pins of output_buffer 
set lead_length 1
set add_offset [expr $outbuf_pin_width/2]
set out_pin_x [get_property [get_pins idcore/out_buff_i/clock_out_p] x_coordinate] 
set clock_out_p_pin_y [get_property [get_pins idcore/out_buff_i/clock_out_p] y_coordinate] 
set clock_out_n_pin_y [get_property [get_pins idcore/out_buff_i/clock_out_n] y_coordinate] 
set trigg_out_p_pin_y [get_property [get_pins idcore/out_buff_i/trigg_out_p] y_coordinate] 
set trigg_out_n_pin_y [get_property [get_pins idcore/out_buff_i/trigg_out_n] y_coordinate] 

setEdit -layer_horizontal M4
setEdit -layer_vertical M5
setEdit -width_horizontal 0.18
setEdit -width_vertical 0.2

setEdit -nets clk_out_p
editAddRoute [expr $out_pin_x] [expr $clock_out_p_pin_y]
editCommitRoute [expr $out_pin_x+$lead_length] [expr $clock_out_p_pin_y] 
editAddRoute [expr $out_pin_x+$lead_length] [expr $clock_out_p_pin_y] 
editCommitRoute [expr $out_pin_x+$lead_length] [expr $pin_clk_out_p_y+$outbuf_pin_height/2]
editAddRoute [expr $out_pin_x+$lead_length] [expr $pin_clk_out_p_y+$outbuf_pin_height/2]
editCommitRoute [expr $pin_clk_out_p_x+$outbuf_pin_width/2+$add_offset] [expr $pin_clk_out_p_y+$outbuf_pin_height/2] 

setEdit -nets clk_out_n
editAddRoute [expr $out_pin_x] [expr $clock_out_n_pin_y]
editCommitRoute [expr $out_pin_x+2*$lead_length] [expr $clock_out_n_pin_y] 
editAddRoute [expr $out_pin_x+2*$lead_length] [expr $clock_out_n_pin_y] 
editCommitRoute [expr $out_pin_x+2*$lead_length] [expr $pin_clk_out_n_y+$outbuf_pin_height/2]
editAddRoute [expr $out_pin_x+2*$lead_length] [expr $pin_clk_out_n_y+$outbuf_pin_height/2]
editCommitRoute [expr $pin_clk_out_n_x+$outbuf_pin_width/2+$add_offset] [expr $pin_clk_out_n_y+$outbuf_pin_height/2] 

setEdit -nets clk_trig_p
editAddRoute [expr $out_pin_x] [expr $trigg_out_p_pin_y]
editCommitRoute [expr $out_pin_x+2*$lead_length] [expr $trigg_out_p_pin_y] 
editAddRoute [expr $out_pin_x+2*$lead_length] [expr $trigg_out_p_pin_y] 
editCommitRoute [expr $out_pin_x+2*$lead_length] [expr $pin_clk_trig_p_y+$outbuf_pin_height/2]
editAddRoute [expr $out_pin_x+2*$lead_length] [expr $pin_clk_trig_p_y+$outbuf_pin_height/2]
editCommitRoute [expr $pin_clk_trig_p_x+$outbuf_pin_width/2+$add_offset] [expr $pin_clk_trig_p_y+$outbuf_pin_height/2] 

setEdit -nets clk_trig_n
editAddRoute [expr $out_pin_x] [expr $trigg_out_n_pin_y]
editCommitRoute [expr $out_pin_x+$lead_length] [expr $trigg_out_n_pin_y] 
editAddRoute [expr $out_pin_x+$lead_length] [expr $trigg_out_n_pin_y] 
editCommitRoute [expr $out_pin_x+$lead_length] [expr $pin_clk_trig_n_y+$outbuf_pin_height/2]
editAddRoute [expr $out_pin_x+$lead_length] [expr $pin_clk_trig_n_y+$outbuf_pin_height/2]
editCommitRoute [expr $pin_clk_trig_n_x+$outbuf_pin_width/2+$add_offset] [expr $pin_clk_trig_n_y+$outbuf_pin_height/2] 






