# Variables shared between init and power steps

# cell_height is from common_vars.tcl
proc snap_to_grid {input granularity} {
   set new_value [expr ceil($input / $granularity) * $granularity]
   return $new_value
}

set cell_height [dbGet top.fPlan.coreSite.size_y]
set vert_pitch  [dbGet top.fPlan.coreSite.size_y]
set horiz_pitch [dbGet top.fPlan.coreSite.size_x]

set core_margin_t $vert_pitch
set core_margin_b $vert_pitch 
set core_margin_r [expr 5 * $horiz_pitch]
set core_margin_l [expr 5 * $horiz_pitch]

set welltap_width 0.72
set DB_width 0.36

set boundary_width [expr $welltap_width+$DB_width]
set boundary_height [expr $cell_height]

set acore_width [snap_to_grid 400 horiz_pitch]
set acore_height [snap_to_grid 400 vert_pitch]

set input_buffer_width 53.1
set input_buffer_height [expr 87*$cell_height]

set output_buffer_width 13.05
set output_buffer_height [expr 32*$cell_height]

set memory_width 64.175
set memory_height 249.84

set sram_width  64.175
set sram_height 249.840
set sram_to_acore_spacing_x [snap_to_grid 40 $horiz_pitch]
set sram_to_acore_spacing_y [snap_to_grid 40 $vert_pitch]

set sram_to_sram_spacing  [snap_to_grid 15 $horiz_pitch]
set sram_neighbor_spacing $sram_width + $sram_to_sram_spacing
set sram_pair_spacing 2*$sram_width + $sram_to_sram_spacing
set sram_vert_spacing [snap_to_grid 200 $vert_pitch]

set blockage_width [expr 0.9]
set blockage_height [expr 2*$cell_height]

set FP_width [snap_to_grid 800 $horiz_pitch ]
set FP_height [snap_to_grid 700 $vert_pitch ]

set center_x [expr $FP_width/2]

# acore
set origin1_x [expr $center_x-$acore_width/2]
set origin1_y [expr $FP_height-2*$boundary_height-2*$blockage_height-$acore_height-2*$cell_height]

# input_buffer_async
set origin0_x [expr 6*$blockage_width+2*$DB_width+$welltap_width+2]
set origin0_y [expr (ceil(260-$input_buffer_height/2)/$cell_height)*$cell_height]

# memory
set origin2_x [expr $origin1_x+4*$blockage_width]
set origin2_y [expr 2*$boundary_height+2*$blockage_height+$cell_height]

# input_buffer_test
set origin3_x [expr $FP_width-$origin0_x-$input_buffer_width]
set origin3_y [expr (ceil(260-$input_buffer_height/2)/$cell_height)*$cell_height-$input_buffer_height+57*$cell_height]

# output_buffer_test
set origin4_x [expr $origin3_x+$input_buffer_width/2+$blockage_width+10*$welltap_width+$DB_width]
set origin4_y [expr ceil((87-$output_buffer_height/2)/$cell_height)*$cell_height]

set origin_acore_x    [expr $sram_pair_spacing + $sram_to_acore_spacing_x ]
set origin_acore_y    [expr $sram_height + $sram_to_acore_spacing_y ]

set origin_sram_ffe_x [expr $blockage_width  + $core_margin_l]
set origin_sram_ffe_y [expr $blockage_height + $core_margin_b]

set origin_sram_adc_x [expr $blockage_width  + $core_margin_l + 2*$sram_width + $sram_to_sram_spacing]
set origin_sram_adc_y [expr $blockage_height + $core_margin_b]