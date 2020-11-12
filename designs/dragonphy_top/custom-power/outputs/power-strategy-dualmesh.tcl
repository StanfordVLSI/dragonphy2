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

	set sram_FP_adjust [snap_to_grid 350 $horiz_pitch]
    set bottom_y [snap_to_grid 100 $vert_pitch]

    set output_buffer_width 13.05;# [dbGet [dbGet -p top.insts.name *out_buff_i*].cell.size_x]
    set output_buffer_height 18.4032; # [dbGet [dbGet -p top.insts.name *out_buff_i*].cell.size_y]

    set acore_width [dbGet [dbGet -p top.insts.name *iacore*].cell.size_x]
    set acore_height [dbGet [dbGet -p top.insts.name *iacore*].cell.size_y]

    set pi_width [dbGet [lindex [dbGet -p top.insts.name *iPI*] 0].cell.size_x]
    set pi_height [dbGet [lindex [dbGet -p top.insts.name *iPI*] 0].cell.size_y]

    set indiv_width [dbGet [dbGet -p top.insts.name *indiv*].cell.size_x]
    set indiv_height [dbGet [dbGet -p top.insts.name *indiv*].cell.size_y]
    
    set mdll_width [dbGet [dbGet -p top.insts.name *imdll*].cell.size_x]
    set mdll_height [dbGet [dbGet -p top.insts.name *imdll*].cell.size_y]

    set sram_height [dbGet [dbGet -p top.insts.name *errt_i_sram_i_memory*].cell.size_y] 
    set sram_width  [dbGet [dbGet -p top.insts.name *errt_i_sram_i_memory*].cell.size_x] 

    set small_sram_height [dbGet [lindex [dbGet -p top.insts.name *hist_sram_inst_memory*] 0].cell.size_y] 
    set small_sram_width  [dbGet [lindex [dbGet -p top.insts.name *hist_sram_inst_memory*] 0].cell.size_x] 
	
	set term_height [dbGet [lindex [dbGet -p top.insts.name itx/buf1/i_term_p] 0].cell.size_y]
    set term_width [dbGet [lindex [dbGet -p top.insts.name itx/buf1/i_term_p] 0].cell.size_x]


    set core_margin_t 0;#$vert_pitch
    set core_margin_b 0;#$vert_pitch 
    set core_margin_r 0;#[expr 5 * $horiz_pitch]
    set core_margin_l 0;#[expr 5 * $horiz_pitch]

    



	set FP_width [snap_to_grid [expr 800  +  $sram_FP_adjust] $horiz_pitch ]
    set FP_height [snap_to_grid 700 $vert_pitch ]

    set sram_to_acore_spacing_x [snap_to_grid 40 $horiz_pitch]
    set sram_to_acore_spacing_y [snap_to_grid 40 $vert_pitch]
    
    set sram_to_buff_spacing_y [snap_to_grid 30 $vert_pitch]

    set sram_to_sram_spacing  [snap_to_grid 30 $horiz_pitch]
    set sram_neighbor_spacing [expr $sram_width + $sram_to_sram_spacing]
    set sram_pair_spacing [expr 2*$sram_width + $sram_to_sram_spacing]
    set sram_vert_spacing [snap_to_grid 200 $vert_pitch]
	
	set pi_to_pi_spacing    [snap_to_grid 25 $horiz_pitch]
    set pi_neighbor_spacing [expr $pi_width + $pi_to_pi_spacing]


	

	

	set origin_acore_x    [expr 199.98]
    set origin_acore_y    [expr 399.744 - $bottom_y]

	set origin_txindiv_x [expr [snap_to_grid 300 $horiz_pitch]]
    set origin_txindiv_y [expr [snap_to_grid 200 $vert_pitch]]

	set origin_sram_ffe_x [expr $origin_acore_x + $acore_width + 100 + 15*$blockage_width  + $core_margin_l]
    set origin_sram_ffe_y [expr 6*$blockage_height + $core_margin_b]

    set origin_sram_ffe_y2 [expr $FP_height - 6*$blockage_height - $core_margin_t -$sram_height]

    set origin_sram_adc_x [expr $origin_sram_ffe_x]
    set origin_sram_adc_y [expr 6*$blockage_height + $core_margin_b]
    set origin_sram_adc_y2 [expr $FP_height - 6*$blockage_height - $core_margin_t -$sram_height]

    set origin_async_x [expr 43.56]
    set origin_async_y [expr 312.192 - $bottom_y]

    set origin_out_x [expr 555.3]
    set origin_out_y [expr 140.544 - $bottom_y]

    set origin_main_x [expr 373.77]
    set origin_main_y [expr 312.192 - $bottom_y]

    set origin_mdll_x [expr 462.51]
    set origin_mdll_y [expr 301.824 - $bottom_y]

    set origin_mon_x [expr 566.82]
    set origin_mon_y [expr 184.32 - $bottom_y]

    set origin_ref_x [expr 504.09]
    set origin_ref_y [expr 184.32 - $bottom_y]

    set origin_txpi_x  [snap_to_grid 100 $horiz_pitch]
    set txpi_x_spacing [snap_to_grid [expr $pi_width + 30] $horiz_pitch]
    set origin_txpi_y  [snap_to_grid 75 $vert_pitch]
    set txpi_y_spacing [snap_to_grid [expr $pi_height + 30] $vert_pitch]

	set origin_term_n_x [snap_to_grid 15 $horiz_pitch]
    set origin_term_n_y [snap_to_grid 71 $vert_pitch]
    set origin_term_p_x [snap_to_grid 15 $horiz_pitch]
    set origin_term_p_y [snap_to_grid 142 $vert_pitch]


#    add_ndr -name tx_out_buf -spacing {M1:M7 0.12} -width {M1:M3 0.12 M4:M7 0.4}
#    setAttribute -net {itx/buf1/BTN itx/buf1/BTP ext_tx_outp ext_tx_outn} -non_default_rule tx_out_buf


#	placeInstance \
	itx/indiv \
		[expr $origin_txindiv_x-4.5]  \
		[expr $origin_txindiv_y-$vert_pitch] \
		MX

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
    [expr $origin_sram_ffe_x + 2*$sram_pair_spacing] \
    [expr $origin_sram_ffe_y2 - $blockage_height] \
    [expr $origin_sram_ffe_x + 2*$sram_pair_spacing + $small_sram_width + $blockage_width]\
    [expr $origin_sram_ffe_y2 + 2*$small_sram_height + $blockage_height] \
    -name memory_hist_blk -layer 1

createRouteBlk -box \
    [expr $origin_sram_adc_x - $blockage_width] \
    [expr $origin_sram_adc_y - $blockage_height] \
    [expr $origin_sram_adc_x + 2*$sram_pair_spacing + $sram_width +  $blockage_width] \
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
#sroute -connect { blockPin } -inst {ibuf_async ibuf_main ibuf_mdll_ref ibuf_mdll_mon} -layerChangeRange { M6 M6 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets {DVDD} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }
#sroute -connect { blockPin } -inst {ibuf_async ibuf_main ibuf_mdll_ref ibuf_mdll_mon}  -layerChangeRange { M6 M6 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets {DVSS} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }

#sroute -connect { blockPin } -layerChangeRange { M6 M6 } -blockPinTarget { blockPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets {DVDD} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }
#sroute -connect { blockPin } -layerChangeRange { M6 M6 } -blockPinTarget { blockPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets {DVSS} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }

#sroute -connect { blockPin } -inst {imdll} -layerChangeRange { M6 M6 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets {CVDD DVDD DVSS} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }

#sroute -connect { blockPin } -inst {ibuf_async ibuf_main ibuf_mdll_ref ibuf_mdll_mon} -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M8 M1 } -nets {DVDD DVSS} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M1 }
#sroute -connect { blockPin } -inst {idcore/out_buff_i} -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M8 M1 } -nets {DVDD DVSS} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M1 }

#--------------------------------------------------------------------------------------------------------------

createRouteBlk -box $acore_x [expr $acore_y+$acore_height] [expr $acore_x+$acore_width] $FP_height -layer {2 3 4 5 6 7 8 9} -name blk_acore_top

createRouteBlk -box $origin_term_p_x $origin_term_p_y [expr $origin_term_p_x+$term_width] [expr $origin_term_p_y+$term_height] -layer {7 8 9} -name blk_term_p
createRouteBlk -box $origin_term_n_x $origin_term_n_y [expr $origin_term_n_x+$term_width] [expr $origin_term_n_y+$term_height] -layer {7 8 9} -name blk_term_n

# --------------------------------------------------------------------------------------------------------------
# # M7 power connections for macros
# # --------------------------------------------------------------------------------------------------------------
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
# # M6 power connections for mdll
# # --------------------------------------------------------------------------------------------------------------
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

#createRouteBlk -box $inbuf_async_x $inbuf_async_y [expr $inbuf_async_x+$input_buffer_width] [expr $inbuf_async_y+$input_buffer_height+10*$cell_height] -layer {7} -name inbut_async_out_M7_blk
#createRouteBlk -box $inbuf_main_x $inbuf_main_y [expr $inbuf_main_x+$input_buffer_width] [expr $inbuf_main_y+$input_buffer_height+10*$cell_height] -layer {7}  -name inbut_main_out_M7_blk
#createRouteBlk -box $inbuf_mdll_ref_x $inbuf_mdll_ref_y [expr $inbuf_mdll_ref_x+$input_buffer_width] [expr $inbuf_mdll_ref_y+$input_buffer_height+10*$cell_height] -layer {7}  -name inbut_mdlll_ref_out_M7_blk
#createRouteBlk -box $inbuf_mdll_mon_x $inbuf_mdll_mon_y [expr $inbuf_mdll_mon_x+$input_buffer_width] [expr $inbuf_mdll_mon_y+$input_buffer_height+10*$cell_height] -layer {7}  -name inbut_mdll_mon_out_M7_blk

set outbuf_pin_width 4
set outbuf_pin_height 4
set outbuf_pin_space 4 
set outbuf_pin_offset_x [expr $output_buffer_width+3]
set outbuf_pin_offset_y [expr $outbuf_pin_space]

set pin_tx_outp_x $origin_async_x	
set pin_tx_outp_y [expr $origin_ref_y+$input_buffer_height-$outbuf_pin_height]
set pin_tx_outn_x $origin_async_x
set pin_tx_outn_y [expr $origin_ref_y]

#Routing blockages for output buffers
createRouteBlk -box [expr $outbuf_x+$output_buffer_width] [expr $outbuf_y-5]  [expr $outbuf_x+$output_buffer_width+10] [expr $outbuf_y+$output_buffer_height+5] -layer {7 8 9} -name blk_outbuf

#Routing blockages for tx_out
createRouteBlk -box [expr $pin_tx_outp_x-2] [expr $pin_tx_outn_y-2]  [expr $pin_tx_outp_x+$outbuf_pin_width+2] [expr $pin_tx_outp_y+$outbuf_pin_width+2] -layer {7 8 9} -name blk_tx_out


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
createRouteBlk -box $inbuf_main_x 0 [expr $acore_x+$acore_width] $acore_y -layer 7 -name M7_blk_pre_routed

addStripe -nets {DVDD DVSS} \
  -layer M7 -direction vertical -width $dcore_M7_width -spacing [expr $dcore_M7_space] -start_offset [expr $boundary_width] -set_to_set_distance $dcore_M7_set_to_set -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
#--------------------------------------------------------------------------------------------------------------
deleteRouteBlk -name {*out_M7_blk *pre_routed}

# stretch out acore DVDD/DVSS (M8)-------------------------------------------------------------------------
sroute -connect { blockPin } -layerChangeRange { M8 M9 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M8 M7 } -nets { DVDD DVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M7 } -inst {iacore}
#--------------------------------------------------------------------------------------------------------------


# dcore main power grid (M8)---------------------------------------------------------------------------
createRouteBlk -box 0 [expr $acore_y-$blockage_height] $FP_width $FP_height -layer 8 -name M8_blk_acore

addStripe -nets {DVDD DVSS} \
  -layer M8 -direction horizontal -width $dcore_M8_width -spacing [expr $dcore_M8_space] -start_offset [expr $boundary_width] -set_to_set_distance $dcore_M8_set_to_set -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
#--------------------------------------------------------------------------------------------------------------


#dcore main power grid (M9)---------------------------------------------------------------------------------
createRouteBlk -box [expr $acore_x-10]  $inbuf_async_y $acore_x $FP_height -layer 9 -name M9_blk_acore_left
createRouteBlk -box 0 $FP_height $FP_width [expr $FP_height-10] -layer {9} -name M9_blk_top
createRouteBlk -box $acore_x $acore_y [expr $acore_x+$acore_width] [expr $acore_y+$acore_height] -layer 9 -name M9_blk_acore
createRouteBlk -box 0 0 $FP_width $FP_height -layer 7 -name M9_via_blk

addStripe -nets {DVDD DVSS} \
  -layer M9 -direction vertical -width $dcore_M9_width -spacing [expr $dcore_M9_space] -start_offset [expr $boundary_width] -set_to_set_distance $dcore_M9_set_to_set -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
#--------------------------------------------------------------------------------------------------------------

deleteRouteBlk -name M9_via_blk
deleteRouteBlk -name M9_blk_top


# analog signal pin parameters ------------------------------------------------------------------------------
set rx_in_pin_width 57
set rx_in_pin_height 10
set rx_in_pin_offset_x 138.385
set rx_in_pin_offset_y 211.576

set rx_in_test_pin_width 5
set rx_in_test_pin_height 5
set rx_inp_test_pin_offset_x 187.695
set rx_inn_test_pin_offset_x 227.695

set Vcm_pin_width 5
set Vcm_pin_height 5
set Vcm_pin_offset_x 207.74
set Vcm_pin_offset_y [expr $acore_height-$Vcm_pin_height] 

set Vcal_pin_width 5
set Vcal_pin_height 5
set Vcal_pin_offset_x 269.095
set Vcal_pin_offset_y [expr $acore_height-$Vcm_pin_height] 

set inbuf_pin_width 8.951
set inbuf_pin_height 8.1
set inbuf_pin_offset_x 0.018
set inbuf_pin_offset_y 3.205


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
createPhysicalPin ext_clk_async_n -net ext_clk_async_n -layer 10 -rect [expr $inbuf_async_x+$inbuf_pin_offset_x] [expr $inbuf_async_y+$inbuf_pin_offset_y] [expr $inbuf_async_x+$inbuf_pin_offset_x+$inbuf_pin_width] [expr $inbuf_async_y+$inbuf_pin_offset_y+$inbuf_pin_height]
createPhysicalPin ext_clk_async_p -net ext_clk_async_p -layer 10 -rect [expr $inbuf_async_x+$input_buffer_width-($inbuf_pin_offset_x)] [expr $inbuf_async_y+$inbuf_pin_offset_y] [expr $inbuf_async_x+$input_buffer_width-($inbuf_pin_width)] [expr $inbuf_async_y+$inbuf_pin_offset_y+$inbuf_pin_height]

# [ext_clk]
createPhysicalPin ext_clkp -net ext_clkp -layer 10 -rect [expr $inbuf_main_x+$inbuf_pin_offset_x] [expr $inbuf_main_y+$inbuf_pin_offset_y] [expr $inbuf_main_x+$inbuf_pin_offset_x+$inbuf_pin_width] [expr $inbuf_main_y+$inbuf_pin_offset_y+$inbuf_pin_height]
createPhysicalPin ext_clkn -net ext_clkn -layer 10 -rect [expr $inbuf_main_x+$input_buffer_width-($inbuf_pin_offset_x)] [expr $inbuf_main_y+$inbuf_pin_offset_y] [expr $inbuf_main_x+$input_buffer_width-($inbuf_pin_width)] [expr $inbuf_main_y+$inbuf_pin_offset_y+$inbuf_pin_height]

# [ext_mdll_clk_ref]
createPhysicalPin ext_mdll_clk_refp -net ext_mdll_clk_refp -layer 10 -rect [expr $inbuf_mdll_ref_x+$inbuf_pin_offset_x] [expr $inbuf_mdll_ref_y+$inbuf_pin_offset_y] [expr $inbuf_mdll_ref_x+$inbuf_pin_offset_x+$inbuf_pin_width] [expr $inbuf_mdll_ref_y+$inbuf_pin_offset_y+$inbuf_pin_height]
createPhysicalPin ext_mdll_clk_refn -net ext_mdll_clk_refn -layer 10 -rect [expr $inbuf_mdll_ref_x+$input_buffer_width-($inbuf_pin_offset_x)] [expr $inbuf_mdll_ref_y+$inbuf_pin_offset_y] [expr $inbuf_mdll_ref_x+$input_buffer_width-($inbuf_pin_width)] [expr $inbuf_mdll_ref_y+$inbuf_pin_offset_y+$inbuf_pin_height]

# [ext_mell_clk_mon]
createPhysicalPin ext_mdll_clk_monn -net ext_mdll_clk_monn -layer 10 -rect [expr $inbuf_mdll_mon_x+$inbuf_pin_offset_x] [expr $inbuf_mdll_mon_y+$inbuf_pin_offset_y] [expr $inbuf_mdll_mon_x+$inbuf_pin_offset_x+$inbuf_pin_width] [expr $inbuf_mdll_mon_y+$inbuf_pin_offset_y+$inbuf_pin_height]
createPhysicalPin ext_mdll_clk_monp -net ext_mdll_clk_monp -layer 10 -rect [expr $inbuf_mdll_mon_x+$input_buffer_width-($inbuf_pin_offset_x)] [expr $inbuf_mdll_mon_y+$inbuf_pin_offset_y] [expr $inbuf_mdll_mon_x+$input_buffer_width-($inbuf_pin_width)] [expr $inbuf_mdll_mon_y+$inbuf_pin_offset_y+$inbuf_pin_height]


#[tx_outputs]
createPhysicalPin ext_tx_outp -net ext_tx_outp -layer 10 -rect $pin_tx_outp_x $pin_tx_outp_y [expr $pin_tx_outp_x+$outbuf_pin_width] [expr $pin_tx_outp_y+$outbuf_pin_height]
createPhysicalPin ext_tx_outn -net ext_tx_outn -layer 10 -rect $pin_tx_outn_x $pin_tx_outn_y [expr $pin_tx_outn_x+$outbuf_pin_width] [expr $pin_tx_outn_y+$outbuf_pin_height]





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
set digital_pins {ext_rstb ext_dump_start *phy* ramp_clock freq_lvl_cross}
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -spreadDirection counterclockwise -edge 2 -layer 2  -spreadType start -unit MICRON -offsetStart $digital_pin_start_offset -spacing $digital_pin_space -pin $digital_pins
# ----------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------
# Assign clk_cgra    --------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -spreadDirection counterclockwise -edge 3 -layer 3  -spreadType start -unit MICRON -offsetStart [expr $origin_acore_x+$acore_width/2+20] -spacing $digital_pin_space -pin clk_cgra
# ----------------------------------------------------------------------------------------------------

deleteRouteBlk -name blk_outbuf
deleteRouteBlk -name blk_tx_out



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


deleteRouteBlk -name blk_term_p
deleteRouteBlk -name blk_term_n

createRouteBlk -box [expr $origin_term_p_x] [expr $origin_term_p_y+$term_height] [expr $origin_term_p_x+$term_width] [expr $origin_term_p_y+$term_height-$cell_height] -layer {1 2 3 4 5 6 7} -name fence_term_p1
createRouteBlk -box [expr $origin_term_p_x] [expr $origin_term_p_y] [expr $origin_term_p_x+$cell_height] [expr $origin_term_p_y+$term_height] -layer {1 2 3 4 5 6 7} -name fence_term_p2
createRouteBlk -box [expr $origin_term_p_x+$term_width] [expr $origin_term_p_y] [expr $origin_term_p_x+$term_width-$cell_height] [expr $origin_term_p_y+$term_height] -layer {1 2 3 4 5 6 7} -name fence_term_p3

createRouteBlk -box [expr $origin_term_n_x] [expr $origin_term_n_y] [expr $origin_term_n_x+$term_width] [expr $origin_term_n_y+$cell_height] -layer {1 2 3 4 5 6 7} -name fence_term_n1
createRouteBlk -box [expr $origin_term_n_x] [expr $origin_term_n_y] [expr $origin_term_n_x+$cell_height] [expr $origin_term_n_y+$term_height] -layer {1 2 3 4 5 6 7} -name fence_term_n2
createRouteBlk -box [expr $origin_term_n_x+$term_width] [expr $origin_term_n_y] [expr $origin_term_n_x+$term_width-$cell_height] [expr $origin_term_n_y+$term_height] -layer {1 2 3 4 5 6 7} -name fence_term_n3



