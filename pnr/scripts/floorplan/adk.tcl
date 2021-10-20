#=========================================================================
# ASIC Design Kit Setup TCL File
#=========================================================================
# This file is sourced by every asic flow tcl script that uses the
# ASIC design kit. This allows us to set ADK-specific variables.

#-------------------------------------------------------------------------
# ADK_PROCESS
#-------------------------------------------------------------------------
# This variable is used by the Innovus Foundation Flow to automatically
# configure process-specific options (e.g., extraction engines).
#
# The process can be "28", "180", etc., with units in nm.

set ADK_PROCESS 16

#-------------------------------------------------------------------------
# Preferred routing layers
#-------------------------------------------------------------------------
# These variables are used by the Synopsys DC Topographical flow and also
# by the Innovus Foundation Flow. Typically the top few metal layers are
# reserved for power straps and maybe clock routing.

set ADK_MIN_ROUTING_LAYER_DC M2
set ADK_MAX_ROUTING_LAYER_DC M7

set ADK_MAX_ROUTING_LAYER_INNOVUS 7

#-------------------------------------------------------------------------
# Power mesh layers
#-------------------------------------------------------------------------
# These variables are used in Innovus scripts to reference the layers used
# for the coarse power mesh.
#
# Care must be taken to choose the right layers for the power mesh such
# that the bottom layer of the power mesh is perpendicular to the
# direction of the power rails in the stdcells. This allows Innovus to
# stamp stacked vias down at each intersection.

set ADK_POWER_MESH_BOT_LAYER 8
set ADK_POWER_MESH_TOP_LAYER 9

#-------------------------------------------------------------------------
# ADK_DRIVING_CELL
#-------------------------------------------------------------------------
# This variable should indicate which cell to use with the
# set_driving_cell command. The tools will assume all inputs to a block
# are being driven by this kind of cell. It should usually be some kind
# of simple inverter.

set ADK_DRIVING_CELL "INVD4BWP16P90"

#-------------------------------------------------------------------------
# ADK_TYPICAL_ON_CHIP_LOAD
#-------------------------------------------------------------------------
# Our default timing constraints assume that we are driving another block
# of on-chip logic. Select how much load capacitance in picofarads we
# should drive here. This is the load capacitance that the output pins of
# the block will expect to be driving.
#
# The stdcell lib shows about 6.5fF for an inverter x4, so about 7fF is
# reasonable.

set ADK_TYPICAL_ON_CHIP_LOAD 0.025

#-------------------------------------------------------------------------
# ADK_FILLER_CELLS
#-------------------------------------------------------------------------
# This variable should include a space delimited list of the names of
# the filler cells in the library. Note, you must order the filler cells
# from largest to smallest because ICC / Innovus will start by using the
# first filler cell, and only use the second filler cell if there is
# space.

set ADK_FILLER_CELLS [list \
   FILL64BWP16P90 \
   FILL64BWP16P90LVT \
   FILL64BWP16P90ULVT \
   FILL32BWP16P90 \
   FILL32BWP16P90LVT \
   FILL32BWP16P90ULVT \
   FILL16BWP16P90 \
   FILL16BWP16P90LVT \
   FILL16BWP16P90ULVT \
   FILL8BWP16P90 \
   FILL8BWP16P90LVT \
   FILL8BWP16P90ULVT \
   FILL4BWP16P90 \
   FILL4BWP16P90LVT \
   FILL4BWP16P90ULVT \
   FILL3BWP16P90 \
   FILL3BWP16P90LVT \
   FILL3BWP16P90ULVT \
   FILL2BWP16P90 \
   FILL2BWP16P90LVT \
   FILL2BWP16P90ULVT \
   FILL1BWP16P90 \
   FILL1BWP16P90LVT \
   FILL1BWP16P90ULVT \
   DCAP64BWP16P90 \
   DCAP64BWP16P90LVT \
   DCAP64BWP16P90ULVT \
   DCAP32BWP16P90 \
   DCAP32BWP16P90LVT \
   DCAP32BWP16P90ULVT \
   DCAP16BWP16P90 \
   DCAP16BWP16P90LVT \
   DCAP16BWP16P90ULVT \
   DCAP8BWP16P90 \
   DCAP8BWP16P90LVT \
   DCAP8BWP16P90ULVT \
   DCAP4BWP16P90 \
   DCAP4BWP16P90LVT \
   DCAP4BWP16P90ULVT]

#-------------------------------------------------------------------------
# ADK_TIE_CELLS
#-------------------------------------------------------------------------
# This list should specify the cells to use for tying high to VDD and
# tying low to VSS.

set ADK_TIE_CELLS [list \
   TIEHBWP16P90 \
   TIELBWP16P90]

#-------------------------------------------------------------------------
# ADK_WELL_TAP_CELL
#-------------------------------------------------------------------------
# This list should specify the well tap cell if the stdcells in the
# library do not already include taps.

set ADK_WELL_TAP_CELL ""

#-------------------------------------------------------------------------
# adk_add_well_taps
#-------------------------------------------------------------------------
# Since TSMC16 requires different well tap cells to be specified for
# different edges, we provide a proc here that specifies well tap rules
# and finally adds the well taps

proc adk_set_well_tap_mode {} {
  set_well_tap_mode \
    -rule 6 \
    -bottom_tap_cell BOUNDARY_NTAPBWP16P90 \
    -top_tap_cell BOUNDARY_PTAPBWP16P90 \
    -cell TAPCELLBWP16P90
}

proc adk_add_well_taps {} {
  addWellTap -cellInterval 12
}


#------------------------------------------------------------------------
# Power domain related procedures
#------------------------------------------------------------------------

# Add endcaps and tap cells for always on domain
proc adk_add_endcap_well_taps_aon_pwr_domains {} {
 setEndCapMode \
  -rightEdge BOUNDARY_LEFTBWP16P90 \
  -leftEdge BOUNDARY_RIGHTBWP16P90 \
  -leftBottomCorner BOUNDARY_NCORNERBWP16P90 \
  -leftTopCorner BOUNDARY_PCORNERBWP16P90 \
  -rightTopEdge FILL3BWP16P90 \
  -rightBottomEdge FILL3BWP16P90 \
  -topEdge "BOUNDARY_PROW3BWP16P90 BOUNDARY_PROW2BWP16P90" \
  -bottomEdge "BOUNDARY_NROW3BWP16P90 BOUNDARY_NROW2BWP16P90" \
  -fitGap true \
  -boundary_tap true

 set_well_tap_mode \
  -rule 6 \
  -bottom_tap_cell BOUNDARY_NTAPBWP16P90 \
  -top_tap_cell BOUNDARY_PTAPBWP16P90 \
  -cell TAPCELLBWP16P90

 addEndCap -powerDomain AON
 addWellTap -powerDomain AON -cellInterval 12

}

# Add endcaps for the shutdown domain
proc adk_add_endcap_well_taps_sd_pwr_domains {} {
  setEndCapMode \
    -rightEdge BOUNDARY_LEFTBWP16P90 \
    -leftEdge BOUNDARY_RIGHTBWP16P90 \
    -leftBottomCorner BOUNDARY_NCORNERBWP16P90 \
    -leftTopCorner BOUNDARY_PCORNERBWP16P90 \
    -rightTopEdge FILL3BWP16P90 \
    -rightBottomEdge FILL3BWP16P90 \
    -topEdge "BOUNDARY_PROW3BWP16P90 BOUNDARY_PROW2BWP16P90" \
    -bottomEdge "BOUNDARY_NROW3BWP16P90 BOUNDARY_NROW2BWP16P90" \
    -fitGap true \
    -boundary_tap false

}

#-------------------------------------------------------------------------
# ADK_END_CAP_CELL
#-------------------------------------------------------------------------
# This list should specify the end cap cells if the library requires them.

set ADK_END_CAP_CELL ""

#-------------------------------------------------------------------------
# adk_add_end_caps
#-------------------------------------------------------------------------
# Since TSMC16 requires different end cap cells to be specified for
# different edges, we provide a proc here that specifies end cap rules
# and finally adds the and caps

proc adk_set_end_cap_mode {} {
  setEndCapMode \
    -rightEdge BOUNDARY_LEFTBWP16P90 \
    -leftEdge BOUNDARY_RIGHTBWP16P90 \
    -leftBottomCorner BOUNDARY_NCORNERBWP16P90 \
    -leftTopCorner BOUNDARY_PCORNERBWP16P90 \
    -rightTopEdge FILL3BWP16P90 \
    -rightBottomEdge FILL3BWP16P90 \
    -topEdge "BOUNDARY_PROW3BWP16P90 BOUNDARY_PROW2BWP16P90 BOUNDARY_PROW1BWP16P90" \
    -bottomEdge "BOUNDARY_NROW3BWP16P90 BOUNDARY_NROW2BWP16P90 BOUNDARY_NROW1BWP16P90" \
    -fitGap true \
    -boundary_tap true
}

proc adk_set_end_cap_mode_pwr_domains {} {
  setEndCapMode \
    -rightEdge BOUNDARY_LEFTBWP16P90 \
    -leftEdge BOUNDARY_RIGHTBWP16P90 \
    -leftBottomCorner BOUNDARY_NCORNERBWP16P90 \
    -leftTopCorner BOUNDARY_PCORNERBWP16P90 \
    -rightTopEdge FILL3BWP16P90 \
    -rightBottomEdge FILL3BWP16P90 \
    -topEdge "BOUNDARY_PROW3BWP16P90 BOUNDARY_PROW2BWP16P90" \
    -bottomEdge "BOUNDARY_NROW3BWP16P90 BOUNDARY_NROW2BWP16P90" \
    -fitGap true \
    -boundary_tap false
}

proc adk_add_end_caps {} {
  addEndCap
}

#-------------------------------------------------------------------------
# ADK_ANTENNA_CELL
#-------------------------------------------------------------------------
# This list has the antenna diode cell used to avoid antenna DRC
# violations.

set ADK_ANTENNA_CELL "ANTENNABWP16P90"

#-------------------------------------------------------------------------
# ADK_LVS_EXCLUDE_CELL_LIST (OPTIONAL)
#-------------------------------------------------------------------------
# For LVS, we usually want a netlist that excludes physical cells that
# have no devices in them (or else LVS will have issues). Specifically for
# filler cells, the extracted layout will not have any trace of the
# fillers because there are no devices in them. Meanwhile, the schematic
# generated from the netlist will show filler cells instances with VDD/VSS
# ports, and this will cause LVS to flag a "mismatch" with the layout.
#
# This list can be used to filter out physical-only cells from the netlist
# generated for LVS. If this is left empty, LVS will just be a bit more
# difficult to deal with.

set ADK_LVS_EXCLUDE_CELL_LIST \
  "*FILL* BOUNDARY* *CORNER* *ICOVL* *DTCD* *TAPCELL* N16_SR_B_1KX1K_DPO_DOD_FFC_5x5"

#-------------------------------------------------------------------------
# ADK_VIRTUOSO_EXCLUDE_CELL_LIST (OPTIONAL)
#-------------------------------------------------------------------------
# Similar to the case with LVS, we may want to filter out certain cells
# for Virtuoso simulation. Specifically, decaps can make Virtuoso
# simulation very slow. While we do eventually want to do a complete
# simulation including decaps, excluding them can speed up simulation
# significantly.
#
# This list can be used to filter out such cells from the netlist
# generated for Virtuoso simulation. If this is left empty, then Virtuoso
# simulations will just run more slowly.

set ADK_VIRTUOSO_EXCLUDE_CELL_LIST \
  "FILL*"
