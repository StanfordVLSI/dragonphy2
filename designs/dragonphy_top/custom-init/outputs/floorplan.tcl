#=========================================================================
# floorplan.tcl
#=========================================================================
# Author : Christopher Torng
# Date   : March 26, 2018

#-------------------------------------------------------------------------
# Floorplan variables
#-------------------------------------------------------------------------

# Set the floorplan to target a reasonable placement density with a good
# aspect ratio (height:width). An aspect ratio of 2.0 here will make a
# rectangular chip with a height that is twice the width.

set core_aspect_ratio   1.00; # Aspect ratio 1.0 for a square chip
set core_density_target 0.70; # Placement density of 70% is reasonable

# Make room in the floorplan for the core power ring

set pwr_net_list {VDD VSS}; # List of power nets in the core power ring

set M1_min_width   [dbGet [dbGetLayerByZ 1].minWidth]
set M1_min_spacing [dbGet [dbGetLayerByZ 1].minSpacing]

set savedvars(p_ring_width)   [expr 48 * $M1_min_width];   # Arbitrary!
set savedvars(p_ring_spacing) [expr 24 * $M1_min_spacing]; # Arbitrary!

# Core bounding box margins

set core_margin_t [expr ([llength $pwr_net_list] * ($savedvars(p_ring_width) + $savedvars(p_ring_spacing))) + $savedvars(p_ring_spacing)]
set core_margin_b [expr ([llength $pwr_net_list] * ($savedvars(p_ring_width) + $savedvars(p_ring_spacing))) + $savedvars(p_ring_spacing)]
set core_margin_r [expr ([llength $pwr_net_list] * ($savedvars(p_ring_width) + $savedvars(p_ring_spacing))) + $savedvars(p_ring_spacing)]
set core_margin_l [expr ([llength $pwr_net_list] * ($savedvars(p_ring_width) + $savedvars(p_ring_spacing))) + $savedvars(p_ring_spacing)]

#-------------------------------------------------------------------------
# Floorplan
#-------------------------------------------------------------------------

# Calling floorPlan with the "-r" flag sizes the floorplan according to
# the core aspect ratio and a density target (70% is a reasonable
# density).
#

floorPlan -r $core_aspect_ratio $core_density_target \
             $core_margin_l $core_margin_b $core_margin_r $core_margin_t

setFlipping s

# Use automatic floorplan synthesis to pack macros (e.g., SRAMs) together

###################
# Place Instances #
###################

# TODO: place multiple memory instances, i.e.
# idcore/oneshot_multimemory_i/sram_i[k]/memory
# idcore/omm_ffe_i/sram_i[k]/memory
# for 0 <= k <= N_mem_tiles-1
for {set k 0} {$k<($::env(num_mem_tiles)-1)} {incr k} {
    placeInstance \
        idcore/oneshot_multimemory_i/sram_i[k]/memory \
        [expr $origin_sram_ffe_x + $k*($sram_width + 8*$welltap_width)] \
        [expr $origin_sram_ffe_y + $sram_height    + 4*$cell_height]

    placeInstance \
        idcore/omm_ffe_i/sram_i[k]/memory \
        [expr $origin_sram_ffe_x + $k*($sram_width + 8*$welltap_width)] \
        [expr $origin_sram_ffe_y ]
}

###################
# Place Blockages #
###################

createPlaceBlockage -box \
    [expr $origin_sram_ffe_x - $blockage_width] \
    [expr $origin_sram_ffe_y - $blockage_width] \
    [expr $origin_sram_ffe_x + 4*$sram_width  + 24*$welltap_width + $blockage_width] \
    [expr $origin_sram_ffe_y + 2*$sram_height + 4*$cell_height + $blockage_width]


planDesign


