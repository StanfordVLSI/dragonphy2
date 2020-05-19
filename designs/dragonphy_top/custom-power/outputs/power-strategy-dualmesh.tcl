#=========================================================================
# power-strategy-dualmesh.tcl
#=========================================================================
# This script implements a dual power mesh, with a fine-grain power mesh
# on the lower metal layers and a coarse-grain power mesh on the upper
# metal layers. Note that M2/M3 are expected to be horizontal/vertical,
# and the lower metal layer of the coarse power mesh is expected to be
# horizontal.
#
# Author : Christopher Torng
# Date   : March 26, 2018

#-------------------------------------------------------------------------
# Stdcell power rail preroute
#-------------------------------------------------------------------------
# Generate horizontal stdcell preroutes

sroute -nets {VDD VSS}

#-------------------------------------------------------------------------
# Shorter names from the ADK
#-------------------------------------------------------------------------

set pmesh_bot $ADK_POWER_MESH_BOT_LAYER
set pmesh_top $ADK_POWER_MESH_TOP_LAYER

#-------------------------------------------------------------------------
# M3 power stripe settings
#-------------------------------------------------------------------------
# We are using addStripe to add sets of stripes (a set includes both VSS
# and VDD).
#
# Set variables to space VSS and VDD straps evenly throughout the chip.
#
#     VSS    VDD    VSS
#     | |    | |    | |
#     | |    | |    | |
#     | |    | |    | |
#
#     _______ <---- $M3_str_pitch
#     ______________
#        ____   ^
#     ___  ^    |
#      ^   |    +-- $M3_str_interset_pitch
#      |   +------- $M3_str_intraset_spacing
#      +----------- $M3_str_width
#
# - M3_str_intraset_spacing : Space between VSS/VDD, chosen for constant
#                             pitch across all VSS and VDD stripes
# - M3_str_interset_pitch   : Pitch between same-signal stripes
#
# - M3_str_offset           : Offset from left edge of core to center the
#                             M3 stripe between vertical M3 routing tracks
#
# - M3_str_width            : M3 stripe width
# - M3_str_pitch            : Choosing an arbitrary M3 pitch that is a
#                             multiple of M3 signal pitch for now

# Get M3 min width and signal routing pitch as defined in the LEF

set M3_min_width    [dbGet [dbGetLayerByZ 3].minWidth]
set M3_route_pitchX [dbGet [dbGetLayerByZ 3].pitchX]

# Set M3 stripe variables

set M3_str_width            [expr  3 * $M3_min_width]
set M3_str_pitch            [expr 10 * $M3_route_pitchX]

set M3_str_intraset_spacing [expr $M3_str_pitch - $M3_str_width]
set M3_str_interset_pitch   [expr 2*$M3_str_pitch]

set M3_str_offset           [expr $M3_str_pitch + $M3_route_pitchX/2 - $M3_str_width/2]

setViaGenMode -reset
setViaGenMode -viarule_preference default
setViaGenMode -ignore_DRC false

setAddStripeMode -reset
setAddStripeMode -stacked_via_bottom_layer 2 \
                 -stacked_via_top_layer    3

addStripe -nets {VSS VDD} -layer 3 -direction vertical \
    -width $M3_str_width                                \
    -spacing $M3_str_intraset_spacing                   \
    -set_to_set_distance $M3_str_interset_pitch         \
    -start_offset $M3_str_offset

#-------------------------------------------------------------------------
# Power ring
#-------------------------------------------------------------------------

addRing -nets {VDD VSS} -type core_rings -follow core   \
        -layer [list top  $pmesh_bot bottom $pmesh_bot  \
                     left $pmesh_top right  $pmesh_top] \
        -width $savedvars(p_ring_width)                 \
        -spacing $savedvars(p_ring_spacing)             \
        -offset $savedvars(p_ring_spacing)              \
        -extend_corner {tl tr bl br lt lb rt rb}

#-------------------------------------------------------------------------
# Power mesh bottom settings (horizontal)
#-------------------------------------------------------------------------
# - pmesh_bot_str_width            : 8X thickness compared to M3
# - pmesh_bot_str_pitch            : Arbitrarily choosing the stripe pitch
# - pmesh_bot_str_intraset_spacing : Space between VSS/VDD, choosing
#                                    constant pitch across VSS/VDD stripes
# - pmesh_bot_str_interset_pitch   : Pitch between same-signal stripes

set pmesh_bot_str_width [expr  8 * $M3_str_width]
set pmesh_bot_str_pitch [expr 10 * $M3_str_pitch]

set pmesh_bot_str_intraset_spacing [expr $pmesh_bot_str_pitch - $pmesh_bot_str_width]
set pmesh_bot_str_interset_pitch   [expr 2*$pmesh_bot_str_pitch]

setViaGenMode -reset
setViaGenMode -viarule_preference default
setViaGenMode -ignore_DRC false

setAddStripeMode -reset
setAddStripeMode -stacked_via_bottom_layer 3 \
                 -stacked_via_top_layer    $pmesh_top

# Add the stripes
#
# Use -start to offset the stripes slightly away from the core edge.
# Allow same-layer jogs to connect stripes to the core ring if some
# blockage is in the way (e.g., connections from core ring to pads).
# Restrict any routing around blockages to use only layers for power.

addStripe -nets {VSS VDD} -layer $pmesh_bot -direction horizontal \
    -width $pmesh_bot_str_width                                   \
    -spacing $pmesh_bot_str_intraset_spacing                      \
    -set_to_set_distance $pmesh_bot_str_interset_pitch            \
    -max_same_layer_jog_length $pmesh_bot_str_pitch               \
    -padcore_ring_bottom_layer_limit $pmesh_bot                   \
    -padcore_ring_top_layer_limit $pmesh_top                      \
    -start [expr $pmesh_bot_str_pitch]

#-------------------------------------------------------------------------
# Power mesh top settings (vertical)
#-------------------------------------------------------------------------
# - pmesh_top_str_width            : 16X thickness compared to M3
# - pmesh_top_str_pitch            : Arbitrarily choosing the stripe pitch
# - pmesh_top_str_intraset_spacing : Space between VSS/VDD, choosing
#                                    constant pitch across VSS/VDD stripes
# - pmesh_top_str_interset_pitch   : Pitch between same-signal stripes

set pmesh_top_str_width [expr 16 * $M3_str_width]
set pmesh_top_str_pitch [expr 20 * $M3_str_pitch] ; # Arbitrary

set pmesh_top_str_intraset_spacing [expr $pmesh_top_str_pitch - $pmesh_top_str_width]
set pmesh_top_str_interset_pitch   [expr 2*$pmesh_top_str_pitch]

setViaGenMode -reset
setViaGenMode -viarule_preference default
setViaGenMode -ignore_DRC false

setAddStripeMode -reset
setAddStripeMode -stacked_via_bottom_layer $pmesh_bot \
                 -stacked_via_top_layer    $pmesh_top

# Add the stripes
#
# Use -start to offset the stripes slightly away from the core edge.
# Allow same-layer jogs to connect stripes to the core ring if some
# blockage is in the way (e.g., connections from core ring to pads).
# Restrict any routing around blockages to use only layers for power.

addStripe -nets {VSS VDD} -layer $pmesh_top -direction vertical \
    -width $pmesh_top_str_width                                 \
    -spacing $pmesh_top_str_intraset_spacing                    \
    -set_to_set_distance $pmesh_top_str_interset_pitch          \
    -max_same_layer_jog_length $pmesh_top_str_pitch             \
    -padcore_ring_bottom_layer_limit $pmesh_bot                 \
    -padcore_ring_top_layer_limit $pmesh_top                    \
    -start [expr $pmesh_top_str_pitch/2]



# power for inout buffers / MDLL (stretch out M6)-----------------------------------------------------------
sroute -connect { blockPin } -layerChangeRange { M6 M6 } -blockPinTarget { boundaryWithPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets { DVDD DVSS CVDD } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }
sroute -connect { blockPin } -layerChangeRange { M6 M6 } -blockPinTarget { blockPin } -allowJogging 1 -crossoverViaLayerRange { M7 M6 } -nets { DVDD DVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M6 }
#--------------------------------------------------------------------------------------------------------------

#Routing blockages for input buffers
createRouteBlk -box $inbuf_async_x $inbuf_async_y [expr $inbuf_async_x+$input_buffer_width] [expr $inbuf_async_y+$input_buffer_height] -layer {7 8 9}
createRouteBlk -box $inbuf_main_x $inbuf_main_y [expr $inbuf_main_x+$input_buffer_width] [expr $inbuf_main_y+$input_buffer_height] -layer {7 8 9}
createRouteBlk -box $inbuf_mdll_ref_x $inbuf_mdll_ref_y [expr $inbuf_mdll_ref_x+$input_buffer_width] [expr $inbuf_mdll_ref_y+$input_buffer_height] -layer {7 8 9}
createRouteBlk -box $inbuf_mdll_mon_x $inbuf_mdll_mon_y [expr $inbuf_mdll_mon_x+$input_buffer_width] [expr $inbuf_mdll_mon_y+$input_buffer_height] -layer {7 8 9}


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
