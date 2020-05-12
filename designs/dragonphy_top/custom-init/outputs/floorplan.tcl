##############################
# Begin Variable Definitions #
##############################

# These variable definitions need to be shared with the "power" step
# Right now you just need to copy and paste these definitions into
# power-strategy-dualmesh.
# TODO: Figure out a better way to do this... (maybe another step?)

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

##############################
#  End Variable Definitions  #
##############################

##############
# Floor Plan #
##############

floorPlan -site core -s $FP_width $FP_height 0 0 0 0

###################
# Place Instances #
###################

placeInstance \
    ibuf_async \
    $origin0_x \
    $origin0_y

placeInstance \
    iacore \
    $origin1_x \
    $origin1_y

placeInstance \
    ibuf_test1 \
    [expr $origin3_x] \
    [expr $origin3_y] \
    R180

placeInstance \
    ibuf_test0 \
    [expr $origin3_x] \
    [expr $origin3_y+$input_buffer_height+4*$cell_height] \
    MY

placeInstance \
    idcore/out_buff_i \
    $origin4_x \
    $origin4_y

# TODO: place multiple memory instances, i.e.
# idcore/oneshot_multimemory/sram_i[k]/memory
# for 0 <= k <= N_mem_tiles-1

# TODO: place ibuf_main
# TODO: place ibuf_mdll_ref
# TODO: place imdll

###################
# Place Blockages #
###################

# outermost blockage
createPlaceBlockage -box \
    0 \
    0 \
    $FP_width \
    $blockage_height

createPlaceBlockage -box \
    0 \
    $FP_height \
    $FP_width \
    [expr $FP_height-$blockage_height]

createPlaceBlockage -box \
    0 \
    0 \
    $blockage_width \
    $FP_height

createPlaceBlockage -box \
    $FP_width \
    0 \
    [expr $FP_width-$blockage_width] \
    $FP_height

# input_buffer_async
createPlaceBlockage -box \
    [expr $origin0_x-5*$blockage_width] \
    [expr $origin0_y-$blockage_width] \
    [expr $origin0_x+$input_buffer_width+5*$blockage_width] \
    [expr $origin0_y+$input_buffer_height+$blockage_width]

# acore
createPlaceBlockage -box \
    [expr $origin1_x-$blockage_width] \
    [expr $origin1_y-$blockage_width] \
    [expr $origin1_x+$acore_width+$blockage_width] \
    [expr $origin1_y+$acore_height+$blockage_width]

# input_buffer_test
# TODO: does this cover both ibuf_test0 and ibuf_test1?
createPlaceBlockage -box \
    [expr $origin3_x-5*$blockage_width] \
    [expr $origin3_y-$blockage_width] \
    [expr $origin3_x+$input_buffer_width+5*$blockage_width] \
    [expr $origin3_y+2*$input_buffer_height+$blockage_width+4*$cell_height]

# output_buffer
createPlaceBlockage -box \
    [expr $origin4_x-$blockage_width] \
    [expr $origin4_y-$blockage_width] \
    [expr $origin4_x+$output_buffer_width+$blockage_width] \
    [expr $origin4_y+$output_buffer_height+$blockage_width]

# TODO: create blockage for multiple memory instances, i.e.
# idcore/oneshot_multimemory/sram_i[k]/memory
# for 0 <= k <= N_mem_tiles-1

# TODO: create blockage for ibuf_main
# TODO: create blockage ibuf_mdll_ref
# TODO: create blockage for imdll