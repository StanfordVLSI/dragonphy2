# Variables shared between init and power steps

# cell_height is from common_vars.tcl
set cell_height 0.576
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

set sram_width  64.175
set sram_height 249.840
 
set blockage_width [expr 0.9]
set blockage_height [expr 2*$cell_height]

set FP_width [expr ceil(580/0.09)*0.09]
set FP_height [expr ceil(700/$cell_height)*$cell_height]

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

set origin_sram_ffe_x [expr $origin1_x+4*$blockage_width]
set origin_sram_ffe_y [expr 2*$boundary_height+2*$blockage_height+$cell_height]