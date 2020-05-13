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