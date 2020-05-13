# General tasks:
# TODO: remove inbuf_aux-related stuff
# TODO: add ibuf_main-related stuff
# TODO: add ibuf_mdll_ref-related stuff
# TODO: add imdll-related stuff
# TODO: add stuff for the various SRAM instances

createRouteBlk -box \
    [expr $origin0_x-$blockage_width] \
    [expr $origin0_y-$blockage_width] \
    [expr $origin0_x+$input_buffer_width+$blockage_width] \
    [expr $origin0_y+$input_buffer_height+$blockage_width] \
    -name inbuf_async_blk -layer 1

createRouteBlk -box \
    [expr $origin2_x-$blockage_width] \
    [expr $origin2_y-$blockage_width] \
    [expr $origin2_x+$memory_width+$blockage_width] \
    [expr $origin2_y+$memory_height+$blockage_width] \
    -name memory_blk -layer 1

# TODO: does this cover both ibuf_test0 and ibuf_test1?
createRouteBlk -box \
    [expr $origin3_x-$blockage_width] \
    [expr $origin3_y-$blockage_width] \
    [expr $origin3_x+$input_buffer_width+$blockage_width] \
    [expr $origin3_y+2*$input_buffer_height+$blockage_width] \
    -name inbuf_test_blk -layer 1

createRouteBlk -box \
    [expr $center_x-$input_buffer_width/2-$blockage_width] \
    [expr $origin1_y-$input_buffer_height-32*$cell_height-$blockage_height] \
    [expr $center_x-$input_buffer_width/2+$input_buffer_width+$blockage_width] \
    [expr $origin1_y-32*$cell_height+$blockage_height] \
    -name inbuf_aux_blk -layer 1

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

set input_buffer_offset 21.104
set output_buffer_offset 1.0

createRouteBlk -box \
    [expr $origin1_x-$blockage_width] \
    [expr $origin1_y-$blockage_width-$cell_height] \
    [expr $origin1_x+$acore_width+$blockage_width] \
    $FP_height \
    -name acore_blk \
    -layer 7

# input_buffers
addStripe \
    -nets {DVSS DVDD} \
    -layer M7 \
    -direction vertical \
    -width 2 -spacing 1 \
    -start_offset [expr $origin0_x+$input_buffer_offset] \
    -stop_offset [expr $FP_width-($origin0_x+$input_buffer_width-$input_buffer_offset+1)] \
    -set_to_set_distance 6 \
    -start_from left \
    -switch_layer_over_obs false \
    -max_same_layer_jog_length 2 \
    -padcore_ring_top_layer_limit AP \
    -padcore_ring_bottom_layer_limit M7 \
    -block_ring_top_layer_limit M7 \
    -block_ring_bottom_layer_limit M1 \
    -use_wire_group 0 \
    -snap_wire_center_to_grid None \
    -skip_via_on_pin {standardcell} \
    -skip_via_on_wire_shape {noshape} \
    -extend_to design_boundary

addStripe \
    -nets {DVSS DVDD} \
    -layer M7 \
    -direction vertical \
    -width 2 \
    -spacing 1 \
    -start_offset [expr $origin0_x+$input_buffer_offset] \
    -stop_offset [expr $FP_width-($origin0_x+$input_buffer_width-$input_buffer_offset+1)] \
    -set_to_set_distance 6 \
    -start_from right \
    -switch_layer_over_obs false \
    -max_same_layer_jog_length 2 \
    -padcore_ring_top_layer_limit AP \
    -padcore_ring_bottom_layer_limit M7 \
    -block_ring_top_layer_limit M7 \
    -block_ring_bottom_layer_limit M1 \
    -use_wire_group 0 \
    -snap_wire_center_to_grid None \
    -skip_via_on_pin {standardcell} \
    -skip_via_on_wire_shape {noshape} \
    -extend_to design_boundary

createRouteBlk -box \
    [expr $center_x-10] \
    [expr $origin1_y] \
    [expr $center_x+10] \
    [expr $origin1_y-30*$cell_height] \
    -name inbuf_aux_blk2 \
    -layer 7

# input_buffer_aux
addStripe \
    -nets {DVSS DVDD} \
    -layer M7 \
    -direction vertical \
    -width 2 \
    -spacing 1 \
    -start_offset [expr $center_x-$input_buffer_width/2+$input_buffer_offset] \
    -stop_offset [expr $FP_width-( $center_x+$input_buffer_width/2-$input_buffer_offset+1)] \
    -set_to_set_distance 6 \
    -start_from left \
    -switch_layer_over_obs false \
    -max_same_layer_jog_length 2 \
    -padcore_ring_top_layer_limit AP \
    -padcore_ring_bottom_layer_limit M7 \
    -block_ring_top_layer_limit M7 \
    -block_ring_bottom_layer_limit M1 \
    -use_wire_group 0 \
    -snap_wire_center_to_grid None \
    -skip_via_on_pin {standardcell} \
    -skip_via_on_wire_shape {noshape} \
    -extend_to design_boundary

createRouteBlk -box \
    [expr $origin0_x-$blockage_width] \
    [expr $origin0_y-$blockage_width] \
    [expr $origin0_x+$input_buffer_width+$blockage_width] \
    [expr $origin0_y+$input_buffer_height+$blockage_width] \
    -name inbuf_async_blk \
    -layer 7

createRouteBlk -box \
    [expr $origin3_x-$blockage_width] \
    [expr $origin3_y-$blockage_width] \
    [expr $origin3_x+$input_buffer_width+$blockage_width] \
    [expr $origin3_y+2*$input_buffer_height+$blockage_width+4*$cell_height] \
    -name inbuf_test_blk \
    -layer 7

createRouteBlk -box \
    [expr $center_x-$input_buffer_width/2-$blockage_width] \
    [expr $origin1_y-$input_buffer_height-32*$cell_height-$blockage_height] \
    [expr $center_x-$input_buffer_width/2+$input_buffer_width+$blockage_width] \
    [expr $origin1_y-32*$cell_height+$blockage_height] \
    -name inbuf_aux_blk \
    -layer 7

# output_buffer
addStripe \
    -nets {DVSS DVDD} \
    -layer M7 \
    -direction vertical \
    -width 1 \
    -spacing 0.5 \
    -start_offset [expr $origin4_x+$output_buffer_offset] \
    -stop_offset 8 \
    -set_to_set_distance 8.55 \
    -start_from left \
    -switch_layer_over_obs false \
    -max_same_layer_jog_length 2 \
    -padcore_ring_top_layer_limit AP \
    -padcore_ring_bottom_layer_limit M7 \
    -block_ring_top_layer_limit M7 \
    -block_ring_bottom_layer_limit M1 \
    -use_wire_group 0
    -snap_wire_center_to_grid None \
    -skip_via_on_pin {standardcell} \
    -skip_via_on_wire_shape {noshape} \
    -extend_to design_boundary

addStripe \
    -nets {DVSS DVDD} \
    -layer M7 \
    -direction vertical \
    -width 1 \
    -spacing 0.5 \
    -start_offset [expr $origin4_x+$output_buffer_offset] \
    -stop_offset 8 \
    -set_to_set_distance 8.55 \
    -start_from right \
    -switch_layer_over_obs false \
    -max_same_layer_jog_length 2 \
    -padcore_ring_top_layer_limit AP \
    -padcore_ring_bottom_layer_limit M7 \
    -block_ring_top_layer_limit M7 \
    -block_ring_bottom_layer_limit M1 \
    -use_wire_group 0 \
    -snap_wire_center_to_grid None \
    -skip_via_on_pin {standardcell} \
    -skip_via_on_wire_shape {noshape} \
    -extend_to design_boundary

#dcore

#outmost stripe

addStripe \
    -nets {DVDD DVSS} \
    -layer M7 \
    -direction vertical \
    -width 1 \
    -spacing 0.5 \
    -start_offset 0.5 \
    -set_to_set_distance 1000 \
    -start_from right \
    -switch_layer_over_obs false \
    -max_same_layer_jog_length 2 \
    -padcore_ring_top_layer_limit AP \
    -padcore_ring_bottom_layer_limit M7 \
    -block_ring_top_layer_limit M7 \
    -block_ring_bottom_layer_limit M1 \
    -use_wire_group 0 \
    -snap_wire_center_to_grid None \
    -skip_via_on_pin {standardcell} \
    -skip_via_on_wire_shape {noshape} \
    -extend_to design_boundary

addStripe \
    -nets {DVSS DVDD} \
    -layer M7 \
    -direction vertical \
    -width 1 \
    -spacing 0.5 \
    -start_offset 0.5 \
    -set_to_set_distance 1000 \
    -start_from left \
    -switch_layer_over_obs false \
    -max_same_layer_jog_length 2 \
    -padcore_ring_top_layer_limit AP \
    -padcore_ring_bottom_layer_limit M7 \
    -block_ring_top_layer_limit M7 \
    -block_ring_bottom_layer_limit M1 \
    -use_wire_group 0 \
    -snap_wire_center_to_grid None \
    -skip_via_on_pin {standardcell} \
    -skip_via_on_wire_shape {noshape} \
    -extend_to design_boundary

# center stripe
addStripe -nets {DVSS DVDD} \
    -layer M7 \
    -direction vertical \
    -width 1 \
    -spacing 3 \
    -start_offset 42 \
    -stop_offset [expr $FP_width/2] \
    -set_to_set_distance 20 \
    -start_from right \
    -switch_layer_over_obs false \
    -max_same_layer_jog_length 2 \
    -padcore_ring_top_layer_limit AP \
    -padcore_ring_bottom_layer_limit M7 \
    -block_ring_top_layer_limit M7 \
    -block_ring_bottom_layer_limit M1 \
    -use_wire_group 0 \
    -snap_wire_center_to_grid None \
    -skip_via_on_pin {standardcell} \
    -skip_via_on_wire_shape {noshape} \
    -extend_to design_boundary

addStripe \
    -nets {DVSS DVDD} \
    -layer M7 \
    -direction vertical \
    -width 1 \
    -spacing 3 \
    -start_offset 42 \
    -stop_offset [expr $FP_width/2] \
    -set_to_set_distance 20 \
    -start_from left \
    -switch_layer_over_obs false \
    -max_same_layer_jog_length 2 \
    -padcore_ring_top_layer_limit AP \
    -padcore_ring_bottom_layer_limit M7 \
    -block_ring_top_layer_limit M7 \
    -block_ring_bottom_layer_limit M1 \
    -use_wire_group 0 \
    -snap_wire_center_to_grid None \
    -skip_via_on_pin {standardcell} \
    -skip_via_on_wire_shape {noshape} \
    -extend_to design_boundary

deleteRouteBlk -name *

createRouteBlk -box \
    0 \
    0 \
    [expr $FP_width] \
    [expr $FP_height] \
    -name entire_design_blk \
    -layer 7

createRouteBlk -box \
    [expr $origin0_x-$blockage_width] \
    [expr $origin0_y-$blockage_width] \
    [expr $origin0_x+$input_buffer_width+$blockage_width] \
    [expr $origin0_y+$input_buffer_height+$blockage_width] \
    -name inbuf_async_blk \
    -layer {8 9}

createRouteBlk -box \
    [expr $origin3_x-$blockage_width] \
    [expr $origin3_y-$blockage_width] \
    [expr $origin3_x+$input_buffer_width+$blockage_width] \
    [expr $origin3_y+2*$input_buffer_height+$blockage_width+4*$cell_height] \
    -name inbuf_test_blk \
    -layer {8 9}

createRouteBlk -box \
    [expr $center_x-$input_buffer_width/2-$blockage_width] \
    [expr $origin1_y-$input_buffer_height-32*$cell_height-$blockage_height] \
    [expr $center_x-$input_buffer_width/2+$input_buffer_width+$blockage_width] \
    [expr $origin1_y-32*$cell_height+$blockage_height] \
    -name inbuf_aux_blk \
    -layer {8 9}

createRouteBlk -box \
    [expr $origin1_x] \
    [expr $FP_height] \
    [expr $origin1_x+$acore_width] \
    [expr $origin1_y-$blockage_height-2*$cell_height] \
    -name acore_blk2 \
    -layer {8 9}

sroute \
    -connect { blockPin } \
    -layerChangeRange { M8 M8 } \
    -blockPinTarget { boundaryWithPin } \
    -allowJogging 0 \
    -crossoverViaLayerRange { M8 M7 } \
    -nets { DVDD DVSS } \
    -allowLayerChange 0 \
    -blockPin useLef \
    -targetViaLayerRange { M8 M7 }

createRouteBlk -box \
    0 \
    [expr $FP_height] \
    [expr $FP_width] \
    [expr $origin1_y] \
    -name acore_blk_M8 \
    -layer 8

addStripe \
    -nets {DVDD DVSS } \
    -layer M8 \
    -direction horizontal \
    -width 2 \
    -spacing 1 \
    -start_offset 3 \
    -set_to_set_distance 12 \
    -start_from bottom \
    -switch_layer_over_obs false \
    -max_same_layer_jog_length 2 \
    -padcore_ring_top_layer_limit AP \
    -padcore_ring_bottom_layer_limit M1 \
    -block_ring_top_layer_limit M7 \
    -block_ring_bottom_layer_limit M1 \
    -use_wire_group 0 \
    -snap_wire_center_to_grid None \
    -skip_via_on_pin {standardcell} \
    -skip_via_on_wire_shape {noshape} \
    -create_pins 1 \
    -extend_to design_boundary

deleteRouteBlk -name acore_blk_M8

deleteRouteBlk -name *