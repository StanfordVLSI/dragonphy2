
set Nti 16
set rx_in_width 5.0
set rx_in_space 10.0

#---------------------------------------------------------
# load pnr variables
#---------------------------------------------------------
set fid [open "${pnrDir}/pnr_vars.txt" r]
set read_data [read -nonewline $fid]
close $fid

set pnr_data [split $read_data "\n"]
foreach block_data $pnr_data {
    set fields [split $block_data ":"]
       lassign $fields var_name var_value
              set $var_name $var_value
}

set SW_offset 6.4

set boundary_width [expr $welltap_width+$DB_width]
set boundary_height [expr 2*$cell_height]
set blockage_width [expr ceil(5/$cell_grid)*$cell_grid]
set blockage_height [expr ceil($blockage_width/$cell_height)*$cell_height]

set routing_height_center [expr 16*$cell_height]
set routing_width_center [expr ceil(40/$cell_grid)*$cell_grid]
set routing_width_side [expr 2*($DB_width+$welltap_width+$blockage_width)+3*$DCAP64_width]
set routing_width_edge [expr 2*($DB_width)+4*$DCAP64_width]

set origin1_x [expr $routing_width_edge]
set origin1_y [expr $boundary_height+$stochastic_adc_PR_height+$biasgen_height]
set origin2_x [expr $origin1_x+$stochastic_adc_PR_width+$routing_width_side] 
set origin2_y [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height]

##############
# Floor Plan #
##############
set FP_width [expr 2*$routing_width_edge+2*$stochastic_adc_PR_width+2*$routing_width_side+2*$phase_interpolator_width+$routing_width_center]
set FP_height [expr 2*$boundary_height+9*$stochastic_adc_PR_height+2*$biasgen_height]

floorPlan -site core -s $FP_width $FP_height 0 0 0 0



######################
## Add welltap cell # 
######################
setEndCapMode -reset
setEndCapMode \
  -rightEdge BOUNDARY_LEFTBWP16P90  \
  -leftEdge  BOUNDARY_RIGHTBWP16P90 \
  -leftBottomCorner BOUNDARY_NCORNERBWP16P90 \
 -leftTopCorner    BOUNDARY_PCORNERBWP16P90 \
  -rightTopEdge    FILL3BWP16P90 \
  -rightBottomEdge FILL3BWP16P90 \
  -bottomEdge "BOUNDARY_NROW2BWP16P90 BOUNDARY_NROW3BWP16P90" \
  -topEdge    "BOUNDARY_PROW2BWP16P90 BOUNDARY_PROW3BWP16P90" \
  -fitGap true \
  -prefix BNDRY \
  -boundary_tap true
set_well_tap_mode \
  -rule 10 \
  -bottom_tap_cell BOUNDARY_NTAPBWP16P90 \
  -top_tap_cell    BOUNDARY_PTAPBWP16P90 \
  -block_boundary_only true \
  -cell TAPCELLBWP16P90


#################################################################
##################### Place MACROs ##############################
#################################################################
## PIs
placeInstance iPI_0__iPI [expr $origin2_x] [expr $origin2_y] R180
placeInstance iPI_1__iPI [expr $origin2_x] [expr $origin2_y+$phase_interpolator_height+2*$routing_height_center] MY 
placeInstance iPI_2__iPI [expr $FP_width-( $origin2_x)-$phase_interpolator_width] [expr $origin2_y+$phase_interpolator_height+2*$routing_height_center]
placeInstance iPI_3__iPI [expr $FP_width-( $origin2_x)-$phase_interpolator_width] [expr $origin2_y] MX

createPlaceBlockage -box [expr $origin2_x] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height-$cell_height] [expr $origin2_x+$phase_interpolator_width+0.9] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center+$cell_height]
createPlaceBlockage -box [expr $origin2_x] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center-$cell_height] [expr $origin2_x+$phase_interpolator_width+0.9] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height+$cell_height] 
createPlaceBlockage -box [expr $FP_width-( $origin2_x)-$phase_interpolator_width-0.9] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center-$cell_height] [expr $FP_width-( $origin2_x)] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height+$cell_height]
createPlaceBlockage -box [expr $FP_width-( $origin2_x)-$phase_interpolator_width-0.9] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height-$cell_height] [expr $FP_width-( $origin2_x)] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center+$cell_height]

## ADCs
for { set k 0} {$k < $Nti} {incr k} {
       if {$k < [expr $Nti/2]} {
		set x_cor [expr $origin1_x]
		set y_cor [expr $origin1_y+($k)*$stochastic_adc_PR_height]
        	placeInstance iADC_$k\__iADC $x_cor $y_cor MY
	} else {
		set x_cor [expr $FP_width-$origin1_x-$stochastic_adc_PR_width]
		set y_cor [expr $origin1_y+($Nti-$k-1)*$stochastic_adc_PR_height]
        	placeInstance iADC_$k\__iADC $x_cor $y_cor
	}
}
placeInstance iADCrep0 [expr $origin1_x] [expr $origin1_y+(-1)*$stochastic_adc_PR_height] MY
placeInstance iADCrep1 [expr $FP_width-$origin1_x-$stochastic_adc_PR_width] [expr $origin1_y+(-1)*$stochastic_adc_PR_height]

#Biasgens
placeInstance iBG_0__iBG [expr $origin1_x] [expr $origin1_y+(-1)*$stochastic_adc_PR_height-$biasgen_height] MY
placeInstance iBG_1__iBG [expr $origin1_x] [expr $origin1_y+(8)*$stochastic_adc_PR_height] MY
placeInstance iBG_2__iBG [expr $FP_width-$origin1_x-$stochastic_adc_PR_width] [expr $origin1_y+(8)*$stochastic_adc_PR_height]
placeInstance iBG_3__iBG [expr $FP_width-$origin1_x-$stochastic_adc_PR_width] [expr $origin1_y+(-1)*$stochastic_adc_PR_height-$biasgen_height]

#input buffer
placeInstance iinbuf [expr $FP_width/2-$input_buffer_width/2+0.045] [expr $origin1_y]
createPlaceBlockage -box [expr $FP_width/2-$input_buffer_width/2+0.045-0.9] [expr $origin1_y-$cell_height] [expr $FP_width/2-$input_buffer_width/2+0.045+$input_buffer_width+0.9] [expr $origin1_y+$input_buffer_height+$cell_height]


# switches
placeInstance iSnH/ISWp0 [expr $origin2_x-$SW_width-$SW_offset] [expr $origin1_y+2*$stochastic_adc_PR_height+$cell_height] R180
placeInstance iSnH/ISWn0 [expr $origin2_x-$SW_width-$SW_offset] [expr $origin1_y+2*$stochastic_adc_PR_height-$SW_height-$cell_height] MY
placeInstance iSnH/ISWp1 [expr $origin2_x-$SW_width-$SW_offset] [expr $origin1_y+6*$stochastic_adc_PR_height+$cell_height] R180
placeInstance iSnH/ISWn1 [expr $origin2_x-$SW_width-$SW_offset] [expr $origin1_y+6*$stochastic_adc_PR_height-$SW_height-$cell_height] MY
placeInstance iSnH/ISWp2 [expr $FP_width-($origin2_x-$SW_width-$SW_offset)-$SW_width] [expr $origin1_y+6*$stochastic_adc_PR_height+$cell_height] MX
placeInstance iSnH/ISWn2 [expr $FP_width-($origin2_x-$SW_width-$SW_offset)-$SW_width] [expr $origin1_y+6*$stochastic_adc_PR_height-$SW_height-$cell_height]
placeInstance iSnH/ISWp3 [expr $FP_width-($origin2_x-$SW_width-$SW_offset)-$SW_width] [expr $origin1_y+2*$stochastic_adc_PR_height+$cell_height] MX
placeInstance iSnH/ISWn3 [expr $FP_width-($origin2_x-$SW_width-$SW_offset)-$SW_width] [expr $origin1_y+2*$stochastic_adc_PR_height-$SW_height-$cell_height]


#termination
placeInstance iterm [expr $FP_width/2-$termination_width/2] [expr $FP_height-$boundary_height-$biasgen_height-$stochastic_adc_PR_height]


createPlaceBlockage -box [expr $origin1_x-$blockage_width] [expr $boundary_height] [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] [expr $FP_height-$boundary_height]
createPlaceBlockage -box [expr $FP_width-($origin1_x-$blockage_width)] [expr $boundary_height] [expr $FP_width-($origin1_x+$stochastic_adc_PR_width)-$blockage_width] [expr $FP_height-$boundary_height]


createPlaceBlockage -box [expr $origin2_x-2*$blockage_width] [expr $boundary_height] [expr $origin2_x] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height] 
createPlaceBlockage -box [expr $FP_width-($origin2_x-2*$blockage_width)] [expr $boundary_height] [expr $FP_width-($origin2_x)] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height]


createPlaceBlockage -box [expr ($origin1_x+$stochastic_adc_PR_width)] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height] [ expr $FP_width-($origin1_x+$stochastic_adc_PR_width)] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height+8*$cell_height]


createPlaceBlockage -box 0 0 $FP_width [expr 2*$cell_height]
createPlaceBlockage -box 0 [expr $FP_height-2*$cell_height] $FP_width $FP_height

createPlaceBlockage -box 0 0 $blockage_width  $FP_height
createPlaceBlockage -box $FP_width 0 [expr $FP_width-$blockage_width] $FP_height

## boundary cell 
addEndCap


## welltap
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $blockage_width+$DB_width] -cellInterval $FP_width -prefix WELLTAP 
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $routing_width_edge-$blockage_width-$DB_width-$welltap_width] -cellInterval $FP_width -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($blockage_width+$DB_width)-$welltap_width] -cellInterval $FP_width -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($routing_width_edge-$blockage_width-$DB_width)-$welltap_width] -cellInterval $FP_width -prefix WELLTAP

addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width+$DB_width] -cellInterval $FP_width -prefix WELLTAP 
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin2_x-2*$blockage_width-$DB_width-$welltap_width] -cellInterval $FP_width -prefix WELLTAP 

addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width+$DB_width)-$welltap_width] -cellInterval $FP_width -prefix WELLTAP 
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin2_x-2*$blockage_width-$DB_width-$welltap_width)-$welltap_width] -cellInterval $FP_width -prefix WELLTAP 

addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width/2-$welltap_width/2] -cellInterval $FP_width -prefix WELLTAP 

addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin2_x+$phase_interpolator_width+$DB_width+0.9] -cellInterval $FP_width -prefix WELLTAP 
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin2_x+$phase_interpolator_width+$DB_width+0.9)-$welltap_width] -cellInterval $FP_width -prefix WELLTAP 


#################################################################################################################
###################  Power Connects  ############################################################################
#################################################################################################################

# [M1]

# (DVDD)
globalNetConnect DVDD -type pgpin -pin VDD -inst * -override
globalNetConnect DVSS -type pgpin -pin VSS -inst * -override
globalNetConnect DVDD -type pgpin -pin VPP -inst * -override
globalNetConnect DVSS -type pgpin -pin VBB -inst * -override
globalNetConnect DVDD -type pgpin -pin DVDD -inst {iADC*} -override
globalNetConnect DVSS -type pgpin -pin DVSS -inst {iADC*} -override

createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width] 0  [expr $FP_width-($origin1_x+$stochastic_adc_PR_width)] $FP_height -name DVDD_M1_blk -layer 1

addStripe -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -master "*"   \
  -merge_stripes_value 0.045   \
  -create_pins 1 \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -extend_to design_boundary \
  -nets {DVDD DVSS} \

deleteRouteBlk -name *

# (AVDD)
globalNetConnect AVDD -type pgpin -pin VDD -inst * -override
globalNetConnect AVSS -type pgpin -pin VSS -inst * -override
globalNetConnect AVDD -type pgpin -pin VPP -inst * -override
globalNetConnect AVSS -type pgpin -pin VBB -inst * -override
globalNetConnect AVDD -type pgpin -pin AVDD -inst {iADC*} -override
globalNetConnect AVSS -type pgpin -pin AVSS -inst (iADC*} -override
globalNetConnect AVDD -type pgpin -pin VDD -inst {iBG*} -override
globalNetConnect AVSS -type pgpin -pin VSS -inst (iBG*} -override

createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width] 0  [expr $FP_width-($origin1_x+$stochastic_adc_PR_width)] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height+7*$cell_height] -name AVDD_M1_blk -layer 1

addStripe -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -master "*"   \
  -merge_stripes_value 0.045  \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -extend_to design_boundary \
  -nets {AVDD AVSS}  

deleteRouteBlk -name *


# (CVDD)
globalNetConnect CVDD -type pgpin -pin VDD -inst * -override
globalNetConnect CVSS -type pgpin -pin VSS -inst * -override
globalNetConnect CVDD -type pgpin -pin VPP -inst * -override
globalNetConnect CVSS -type pgpin -pin VBB -inst * -override

globalNetConnect CVDD -type pgpin -pin VDD -inst {*iPI*} -override
globalNetConnect CVSS -type pgpin -pin VSS -inst {*iPI*} -override
globalNetConnect CVDD -type pgpin -pin VDD -inst {*iinbuf*} -override
globalNetConnect CVSS -type pgpin -pin VSS -inst {*iinbuf*} -override
globalNetConnect CVDD -type pgpin -pin VDD -inst {*iSnH/ISW*} -override
globalNetConnect CVSS -type pgpin -pin VSS -inst {*iSnH/ISW*} -override

createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width] $FP_height  [expr $FP_width-($origin1_x+$stochastic_adc_PR_width)] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height+$cell_height] -name CVDD_M1_blk_center -layer 1

createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width] $FP_height [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] 0 -name CVDD_M1_blk_side1 -layer 1
createRouteBlk -box [expr $FP_width-($origin1_x+$stochastic_adc_PR_width)] $FP_height [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width)] 0 -name CVDD_M1_blk_side2 -layer 1



addStripe -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -master "*"   \
  -merge_stripes_value 0.045  \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -extend_to design_boundary \
  -nets {CVDD CVSS}  

deleteRouteBlk -name *

########################################################
# power [M7], [M8], [M9]
########################################################


globalNetConnect CVDD -type pgpin -pin VDD -inst * -override
globalNetConnect CVSS -type pgpin -pin VSS -inst * -override
globalNetConnect CVDD -type pgpin -pin VPP -inst * -override
globalNetConnect CVSS -type pgpin -pin VBB -inst * -override
globalNetConnect AVDD -type pgpin -pin VDD -inst {iBG*} -override
globalNetConnect AVSS -type pgpin -pin VSS -inst {iBG*} -override

#### (DVDD) ####

#M7
addStripe -nets {DVDD DVSS} \
  -layer M7 -direction vertical -width $AVDD_M7_width -spacing $AVDD_M7_space -start_offset [expr $routing_width_edge/2-($AVDD_M7_width+$AVDD_M7_space/2)] -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
addStripe -nets {DVDD DVSS} \
  -layer M7 -direction vertical -width $AVDD_M7_width -spacing $AVDD_M7_space -start_offset [expr $routing_width_edge/2-($AVDD_M7_width+$AVDD_M7_space/2)] -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary

#M8
#addStripe -nets {DVDD DVSS DVDD DVSS DVDD } \
#  -layer M8 -direction horizontal -width $DVDD_M8_width -spacing $DVDD_M8_space -start_offset [expr $biasgen_height+$boundary_height+2] -set_to_set_distance $stochastic_adc_PR_height -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary 

#addStripe -nets {DVDD DVSS DVDD DVSS DVDD } \
#  -layer M8 -direction horizontal -width $DVDD_M8_width -spacing $DVDD_M8_space -start_offset [expr $biasgen_height+$boundary_height+25] -set_to_set_distance $stochastic_adc_PR_height -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary 

createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width-$V2T_width] 0 [expr $FP_width-($origin1_x+$stochastic_adc_PR_width-$V2T_width)] $FP_height -name DVDD_M8_blk1 -layer {8 9}
createRouteBlk -box 0 0 $FP_width [expr $biasgen_height+$boundary_height] -name DVDD_M8_blk2 -layer 8
createRouteBlk -box 0 $FP_height $FP_width [expr $FP_height-$biasgen_height-$boundary_height] -name DVDD_M8_blk3 -layer 8

sroute -connect { blockPin } -layerChangeRange { M8 M8 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M8 M7 } -nets { DVDD DVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M7 } 


#M9

#createRouteBlk -box 0 0 $FP_width $FP_height -name DVDD_M7_blk3 -layer 7
#addStripe -nets {DVDD DVSS } \
#  -layer M9 -direction vertical -width 4 -spacing 2 -start_offset 15.7 -stop_offset [expr $FP_width/2] -set_to_set_distance 20.16 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary 

#addStripe -nets {DVSS DVDD } \
#  -layer M9 -direction vertical -width 4 -spacing 2 -start_offset 12.19 -stop_offset [expr $FP_width/2] -set_to_set_distance 20.16 -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary 
#deleteRouteBlk -name *

sroute -connect { blockPin } -layerChangeRange { M9 M9 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M9 M8 } -nets { DVDD DVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M9 M8 } 


##### (CVDD) #####

createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height] [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width)] 0 -name CVDD_M3_blk1 -layer 3
createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] [expr $FP_height] [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width)]  [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height] -name CVDD_M3_blk2 -layer 3

addStripe -nets {CVDD} \
  -layer M3 -direction vertical -width [expr $welltap_width+$DB_width] -spacing $FP_width -start_offset [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M3 -block_ring_top_layer_limit M3 -block_ring_bottom_layer_limit M3 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
addStripe -nets {CVSS} \
  -layer M3 -direction vertical -width [expr $welltap_width+$DB_width] -spacing $FP_width -start_offset [expr $origin2_x-2*$blockage_width-$welltap_width-$DB_width] -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M3 -block_ring_top_layer_limit M3 -block_ring_bottom_layer_limit M3 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary

addStripe -nets {CVDD} \
  -layer M3 -direction vertical -width [expr $welltap_width+$DB_width] -spacing $FP_width -start_offset [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M3 -block_ring_top_layer_limit M3 -block_ring_bottom_layer_limit M3 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
addStripe -nets {CVSS} \
  -layer M3 -direction vertical -width [expr $welltap_width+$DB_width]  -spacing $FP_width -start_offset [expr $origin2_x-2*$blockage_width-$welltap_width-$DB_width] -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M3 -block_ring_top_layer_limit M3 -block_ring_bottom_layer_limit M3 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary


deleteRouteBlk -name *



createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] [expr $origin1_y+6.5*$stochastic_adc_PR_height] [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width)] $FP_height -name CVDD_M7_blk -layer 7

#sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { blockPin } -deleteExistingRoutes -allowJogging 1 -crossoverViaLayerRange { M7 M7 } -nets { CVDD CVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M1 }

sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M7 M1 } -nets { CVDD CVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M7 M1 } 

addStripe -nets {CVDD CVSS} \
  -layer M7 -direction vertical -width $DVDD_M7_width -spacing [expr 2*$DVDD_M7_space] -start_offset [expr $origin2_x+$phase_interpolator_width+$DVDD_M7_space] -stop_offset [expr ($origin2_x+$phase_interpolator_width+$DVDD_M7_space)] -set_to_set_distance [expr 2*($DVDD_M7_width+2*$DVDD_M7_space)] -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary

#sroute -connect { blockPin } -layerChangeRange { M8 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M8 M7 } -nets { CVDD CVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M7 } 

#M8

createRouteBlk -box 0 0 [expr $origin2_x] $FP_height -name CVDD_M8_side1 -layer {8 9}
createRouteBlk -box $FP_width 0 [expr $FP_width-($origin2_x)] $FP_height -name CVDD_M8_blk_side2 -layer {8 9}

addStripe -nets {CVDD CVSS} \
  -layer M8 -direction horizontal -width $AVDD_M7_width -spacing $AVDD_M7_space -start_offset [expr $origin1_y+3.525] -stop_offset [expr $FP_height-($origin1_y+$input_buffer_height)] -set_to_set_distance 6.951 -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} 

deleteRouteBlk -all


sroute -connect { blockPin } -layerChangeRange { M9 M9 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M9 M1 } -nets { AVDD AVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M9 M1 } 


if 0 {


createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] [expr $origin1_y+3*$stochastic_adc_PR_height-$routing_height_center] [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width)] $FP_height -name CVDD_M8_blk_center -layer {8 9}
createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] 0 [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width)] [expr $origin1_y+$input_buffer_height] -name CVDD_M8_blk_center -layer {8 9}

createRouteBlk -box 0 0 [expr $origin2_x+10] $FP_height -name CVDD_M9_blk_left -layer {9}
createRouteBlk -box $FP_width 0 [expr $FP_width-($origin2_x+10)] $FP_height -name CVDD_M9_blk_right -layer {9}

addStripe -nets {CVDD CVSS} \
  -layer M8 -direction horizontal -width 2 -spacing 1 -start_offset [expr 20*$cell_height+$input_buffer_height]  -set_to_set_distance 6 -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} 



createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] 0 [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width)] $FP_height -name CVDD_M7_blk_center -layer {7}


addStripe -nets {CVSS CVDD} \
  -layer M9 -direction vertical -width 8 -spacing 4 -start_offset [expr $origin2_x+3.5]  -set_to_set_distance 24 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} 


addStripe -nets {CVDD CVSS} \
  -layer M10 -direction horizontal -width 20 -spacing 10 -start_offset [expr $origin1_y+55]  -set_to_set_distance $FP_width -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary -create_pins 1 


deleteRouteBlk -name *

selectVia 207.6100 121.8560 208.6100 125.1360 9 CVDD
deleteSelectedFromFPlan
selectVia 151.8400 121.8560 152.8400 125.1360 9 CVDD
deleteSelectedFromFPlan
selectVia 170.2500 155.7340 172.2500 158.8340 9 CVSS
deleteSelectedFromFPlan
selectVia 194.2500 155.7340 196.2500 158.8340 9 CVSS
deleteSelectedFromFPlan
selectWire 136.9800 131.4960 138.5300 133.4960 8 CVSS
deleteSelectedFromFPlan
selectWire 221.9200 131.4960 223.4700 133.4960 8 CVSS
deleteSelectedFromFPlan
selectWire 159.2000 135.2840 201.2500 137.2840 8 CVDD
deleteSelectedFromFPlan
selectVia 222.9200 134.7840 223.5600 135.7840 8 CVDD
deleteSelectedFromFPlan
selectVia 136.8900 134.7840 137.5300 135.7840 8 CVDD
deleteSelectedFromFPlan
  

            

# (Vcm) #
setEdit -layer_minimum M1
setEdit -layer_maximum AP
setEdit -force_regular 1
getEdit -snap_to_track_regular
getEdit -snap_to_pin
viewLast
setEdit -force_special 1
getEdit -snap_to_track
getEdit -snap_special_wire
getEdit -align_wire_at_pin
getEdit -snap_to_row
getEdit -snap_to_pin
setViaGenMode -ignore_DRC false
setViaGenMode -use_fgc 1
setViaGenMode -use_cce false

setEdit -layer_vertical M9
setEdit -width_vertical 9.6


setEdit -nets Vcm
editAddRoute [expr $FP_width/2-0.225]  [expr $FP_height]
editCommitRoute [expr $FP_width/2-0.225]  [expr $FP_height-140*$cell_height+$termination_height-2*$cell_height]


addStripe -nets {Vcal} \
  -layer M7 -direction vertical -width 1.6 -spacing 0.5 -start_offset [expr $origin1_x+64.530] -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
addStripe -nets {Vcal} \
  -layer M7 -direction vertical -width 1.6 -spacing 0.5 -start_offset [expr ($origin1_x+64.530)] -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary




# (AVDD) #

globalNetConnect AVDD -type pgpin -pin VDD -inst iBG_1__iBG	-override
globalNetConnect AVDD -type pgpin -pin VDD -inst iBG_2__iBG	-override
globalNetConnect AVSS -type pgpin -pin VSS -inst iBG_1__iBG	-override
globalNetConnect AVSS -type pgpin -pin VSS -inst iBG_2__iBG	-override
globalNetConnect Vcal -type pgpin -pin Vbias -inst iBG_1__iBG	-override
globalNetConnect Vcal -type pgpin -pin Vbias -inst iBG_2__iBG	-override



# (Vcal) #
setEdit -layer_horizontal M8
setEdit -width_horizontal 2
setEdit -nets Vcal
editAddRoute [expr $origin1_x+$stochastic_adc_PR_width-1] [expr $FP_height-6.452]
editCommitRoute [expr $FP_width-($origin1_x+$stochastic_adc_PR_width-1)] [expr $FP_height-6.452]


createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height+$blockage_height] [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width)] 0 -name AVDD_M7_blk_center -layer {7 8 9}
createRouteBlk -box [expr $FP_width/2-$termination_width/2-2] [expr $FP_height-140*$cell_height-20*$cell_height] [expr $FP_width/2+$termination_width/2+2] [expr $FP_height-140*$cell_height+$termination_height] -name Vcm_via_blk -layer {7 8 9}

sroute -connect { blockPin } -layerChangeRange { M8 M7 } -blockPinTarget { blockPin } -deleteExistingRoutes -allowJogging 1 -crossoverViaLayerRange { M8 M1 } -nets { AVDD AVSS Vcal} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M1 }


setEdit -layer_vertical M9
setEdit -width_vertical 10
setEdit -nets Vcal
editAddRoute 234 [expr $FP_height]
editCommitRoute 234 [expr $FP_height-20]




globalNetConnect AVDD -type pgpin -pin AVDD -inst iADC*	-override
globalNetConnect AVSS -type pgpin -pin AVSS -inst iADC*	-override

addStripe -nets {AVDD AVSS} \
  -layer M9 -direction vertical -width 4 -spacing 2 -start_offset [expr $origin1_x+54.05]  -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary 
addStripe -nets {AVDD} \
  -layer M9 -direction vertical -width 4 -spacing 2 -start_offset [expr $origin1_x+66.329]  -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary 
addStripe -nets {AVSS} \
  -layer M9 -direction vertical -width 4 -spacing 2 -start_offset [expr $origin1_x+78.45]  -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary 

addStripe -nets {AVDD AVSS} \
  -layer M9 -direction vertical -width 4 -spacing 2 -start_offset [expr $origin1_x+54.05]  -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary 
addStripe -nets {AVDD} \
  -layer M9 -direction vertical -width 4 -spacing 2 -start_offset [expr $origin1_x+66.329]  -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary 
addStripe -nets {AVSS} \
  -layer M9 -direction vertical -width 4 -spacing 2 -start_offset [expr $origin1_x+78.45]  -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary 



gui_select -rect {103.338 21.102 107.299 6.924}
gui_select -toggle -rect {257.404 20.425 253.240 5.128}
gui_select -toggle -rect {103.123 402.660 106.856 389.762}
gui_select -toggle -rect {256.824 402.754 253.399 389.221}
deleteSelectedFromFPlan



createRouteBlk -box 0 0 [expr $origin2_x-1] $FP_height -name AVDD_M7_side1 -layer {7 8}
createRouteBlk -box $FP_width 0 [expr $FP_width-($origin2_x-1)] $FP_height -name AVDD_M7_blk_side2 -layer {7 8}

createRouteBlk -box 0 0 [expr $origin2_x+5] $FP_height -name AVDD_M9_side1 -layer 9
createRouteBlk -box $FP_width 0 [expr $FP_width-($origin2_x+5)] $FP_height -name AVDD_M9_blk_side2 -layer 9

addStripe -nets {AVDD AVSS} \
  -layer M7 -direction vertical -width 2 -spacing 2 -start_offset [expr $origin2_x+0.7]  -set_to_set_distance 8 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape}

addStripe -nets {AVSS AVDD} \
  -layer M8 -direction horizontal -width 2 -spacing 1 -start_offset $biasgen_height  -set_to_set_distance 6 -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} 


createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height] [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width)] $FP_height -name CVDD_M7_blk -layer 7

addStripe -nets {AVDD AVSS} \
  -layer M9 -direction vertical -width 8 -spacing 4 -start_offset [expr $FP_width/2+6.5]  -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary -create_pins 1 
addStripe -nets {AVSS AVDD} \
  -layer M9 -direction vertical -width 8 -spacing 4 -start_offset [expr $FP_width/2-26.5]  -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape}  -extend_to design_boundary -create_pins 1 

deleteRouteBlk -name *

createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] $FP_height  [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width+40 ] [expr $FP_height-140*$cell_height] -name AVDD_M10_blk_side1 -layer {9}
createRouteBlk -box [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width)] $FP_height  [expr  $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width+40)] [expr $FP_height-140*$cell_height] -name AVDD_M10_blk_side2 -layer {9}

addStripe -nets {AVDD AVSS} \
  -layer M10 -direction horizontal -width 20 -spacing 10 -start_offset [expr $biasgen_height-20*$cell_height]  -set_to_set_distance $FP_width -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit M9 -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary -create_pins 1 

deleteRouteBlk -name *

}





#-----------------------------------------------
# Assign IO pins
# ---------------------------------------------

## ADC pins
assignIoPins -align -pin {clk_adc adder_out* sign_out* *ctl_v2t* *init* *ALWS_ON* *sel_pm_sign[* *sel_pm_sign_rep[*  *sel_pm_in[* *sel_pm_in_rep[*  *sel_clk_TDC* *em_pm[* *ctl_dcdl_early* *ctl_dcdl_late* *ctl_dcdl_TDC* *sel_del_out *del_out[* *del_out_rep[* *pm_out[* *pm_out_rep[* *en_pm[* *en_pm_rep[* *en_slice*}
#assignIoPins -pin { *ctl_biasgen* *en_biasgen*} 


## Other pins
set pin_list {clk_async ctl_pi* *en_arb_pi* *en_delay_pi* *en_pm_pi* *en_cal_pi* *Qperi* *sel_pm_sign_pi* *del_inc* *ctl_dcdl_slice* *ctl_dcdl_sw* *disable_state* *bypass_inbuf_div* *biasgen* *en_clk_sw* *en_meas_pi* *sel_meas_pi* *inbuf_ndiv* *pm_out_pi* ext_clk_aux *cal_out_pi* *max_sel_mux* *pi_out_meas* *inbuf_out_meas *del_out_pi ext_clk_test* clk_cdr *rstb *en_v2t *en_gf *en_inbuf *sel_inbuf_in *bypass_inbuf_duv *en_inbuf_meas *pfd_in* }
setPinAssignMode -pinEditInBatch true
assignIoPins -pin $pin_list
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -spreadDirection counterclockwise -edge 3 -layer 3  -spreadType range -offsetStart [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width] -offsetEnd [expr ($origin1_x+$stochastic_adc_PR_width+$blockage_width)]  -pin $pin_list 


#######
# NDR #
#######
#add_ndr -name NDR_analog -spacing {M9 1.0 M8 1.0} -width {M9 $rx_in_width M8 2.0}
#setAttribute -net rx_inp -non_default_rule NDR_analog
#setAttribute -net rx_inn -non_default_rule NDR_analog
#setAttribute -net Vcm -non_default_rule NDR_analog

#add_ndr -name NDR_WIDE -spacing {M1:M2 0.2 M3 0.2 M4:M7 0.2 M8 0.2} -width {M1:M2 1 M3 1 M4:M7 1 M8 1.17} 
#foreach_in_collection i [get_nets *in*] {
#        setAttribute -net [get_object_name $i] -non_default_rule NDR_5W2S
#}

assignIoPin -align -pin {rx_inp rx_inn Vcm} 
editPin -pinWidth $rx_in_width -pinDepth [expr $boundary_height+$biasgen_height+$stochastic_adc_PR_height] -fixOverlap 1 -layer 9 -pin {Vcm}
editPin -pinWidth $rx_in_width -pinDepth [expr $boundary_height+$biasgen_height+1.5*$stochastic_adc_PR_height+$rx_in_width/2] -fixOverlap 1 -layer 9 -pin {rx_inn rx_inp}


createRouteBlk -box 0 0 $FP_width [expr $boundary_height+$biasgen_height] -layer 8
sroute -connect { blockPin } -layerChangeRange { M8 M7 } -blockPinTarget { blockPin } -deleteExistingRoutes -allowJogging 1 -crossoverViaLayerRange { M8 M7 } -nets { Vcal } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M1 }
deleteRouteBlk -all
editPin -pinWidth $rx_in_width -pinDepth [expr $boundary_height+$biasgen_height] -fixOverlap 1  -spreadDirection counterclockwise -edge 1 -layer 9 -spreadType start -offsetStart [expr $origin2_x] -pin {Vcal}


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

setEdit -layer_vertical M9
setEdit -width_vertical $rx_in_width
setEdit -layer_horizontal M8
setEdit -width_horizontal $SW_pin_length

set Vcal_M9_offset [get_property [get_ports Vcal] x_coordinate]
set ext_clk_width 1.5

setEdit -nets Vcal
editAddRoute [expr $Vcal_M9_offset]  [expr $FP_height]
editCommitRoute [expr $Vcal_M9_offset]  [expr $FP_height-($boundary_height+$biasgen_height)]

assignIoPin -align -pin {ext_clkp ext_clkn}
editPin -pinWidth $ext_clk_width -pinDepth [expr $origin1_y] -fixOverlap 1 -layer 9 -pin {ext_clkp ext_clkn}

set rx_inp_test_M8_offset [get_property [get_pins iADCrep0/VinP] y_coordinate]
set rx_inn_test_M8_offset [get_property [get_pins iADCrep0/VinN] y_coordinate]
set rx_in_test_space 40

setEdit -nets rx_inp_test
editAddRoute [expr $origin1_x+$stochastic_adc_PR_width]  $rx_inp_test_M8_offset
editCommitRoute [expr $FP_width-($origin1_x+$stochastic_adc_PR_width)] $rx_inp_test_M8_offset
setEdit -nets rx_inn_test
editAddRoute [expr $origin1_x+$stochastic_adc_PR_width]  $rx_inn_test_M8_offset
editCommitRoute [expr $FP_width-($origin1_x+$stochastic_adc_PR_width)] $rx_inn_test_M8_offset



editPin -pinWidth $rx_in_width -pinDepth [expr $origin1_y] -fixOverlap 0  -spreadDirection counterclockwise -edge 3 -layer 9 -spreadType start -offsetStart [expr $FP_width/2-$rx_in_test_space/2] -pin {rx_inp_test}
editPin -pinWidth $rx_in_width -pinDepth [expr $origin1_y] -fixOverlap 0  -spreadDirection counterclockwise -edge 3 -layer 9 -spreadType start -offsetStart [expr $FP_width/2+$rx_in_test_space/2] -pin {rx_inn_test}


set rx_inp_test_M9_offset [get_property [get_ports rx_inp_test] x_coordinate]
set rx_inn_test_M9_offset [get_property [get_ports rx_inn_test] x_coordinate]


setEdit -nets rx_inp_test
editAddRoute [expr $rx_inp_test_M9_offset]  0
editCommitRoute [expr $rx_inp_test_M9_offset] $origin1_y
setEdit -nets rx_inn_test
editAddRoute [expr $rx_inn_test_M9_offset]  0
editCommitRoute [expr $rx_inn_test_M9_offset] $origin1_y




######################################
#source $scrDir/pre_routing.tcl
######################################

#createRouteBlk -box [expr $origin1_x] [expr 2*$cell_height] [expr $origin1_x+$stochastic_adc_PR_width] [expr $FP_height-2*$cell_height] -name ADC_M7_blk1 -layer {7 8 9}
#createRouteBlk -box [expr $FP_width-$origin1_x] [expr 2*$cell_height] [expr $FP_width-($origin1_x+$stochastic_adc_PR_width)] [expr $FP_height-2*$cell_height] -name ADC_M7_blk2 -layer {7 8 9}


#globalNetConnect CVDD -type pgpin -pin VDD -inst * -override
#globalNetConnect CVSS -type pgpin -pin VSS -inst * -override
#globalNetConnect CVDD -type pgpin -pin VPP -inst * -override
#globalNetConnect CVSS -type pgpin -pin VBB -inst * -override






## place manual drivers
if 0 {


## Inputs ##
placeInstance Ibuf_clk_in_pi_1 [expr $FP_width/2+$welltap_width/2] [expr 136*$cell_height]
placeInstance Ibuf_clk_in_pi_2 [expr $FP_width/2+$welltap_width/2] [expr $FP_height/2-50*$cell_height]
placeInstance Ibuf_clk_in_pi_3_0_ [expr $origin2_x+ceil($phase_interpolator_width/2/$cell_grid)*$cell_grid] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center+2*$cell_height]
placeInstance Ibuf_clk_in_pi_3_1_ [expr $origin2_x+ceil($phase_interpolator_width/2/$cell_grid)*$cell_grid] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center-3*$cell_height]
placeInstance Ibuf_clk_in_pi_3_2_ [expr $FP_width-($origin2_x+ceil($phase_interpolator_width/2/$cell_grid)*$cell_grid)] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center-3*$cell_height]
placeInstance Ibuf_clk_in_pi_3_3_ [expr $FP_width-($origin2_x+ceil($phase_interpolator_width/2/$cell_grid)*$cell_grid)] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center+2*$cell_height]

placeInstance Ibuf_clk_in_rep_0_ [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width+$DB_width+$welltap_width] [expr $origin1_y-$stochastic_adc_PR_height/2] MY
placeInstance Ibuf_clk_in_rep_1_ [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width+$DB_width+$welltap_width)-0.72] [expr $origin1_y-$stochastic_adc_PR_height/2]


placeInstance Ibuf_clk_async_1 [expr $origin2_x+$DB_width+9] [expr 15*$cell_height]
for { set k 0} {$k < 8} {incr k} {
		set x_cor [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width+$DB_width+$welltap_width]
		set y_cor [expr $origin1_y+($k)*$stochastic_adc_PR_height+39*$cell_height]
        	placeInstance Ibuf_clk_async_adc_2_$k\_ $x_cor $y_cor MY
}
set y_cor [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height-2*$cell_height]
placeInstance Ibuf_clk_async_adc_2_6_ $x_cor $y_cor R180
placeInstance Ibuf_clk_async_adc_2_7_ [expr $x_cor+4.5] $y_cor R180

for { set k 8} {$k < 16} {incr k} {
		set x_cor [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width+$DB_width+$welltap_width)-0.72]
		set y_cor [expr $origin1_y+(15-$k)*$stochastic_adc_PR_height+39*$cell_height]
        	placeInstance Ibuf_clk_async_adc_2_$k\_ $x_cor $y_cor 
}
set y_cor [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height-2*$cell_height]
placeInstance Ibuf_clk_async_adc_2_9_ $x_cor $y_cor R180
placeInstance Ibuf_clk_async_adc_2_8_ [expr $x_cor-4.5] $y_cor R180


placeInstance Ibuf_clk_async_rep_2_0_ [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width+$DB_width+$welltap_width]  [expr $origin1_y-$stochastic_adc_PR_height+39*$cell_height]
placeInstance Ibuf_clk_async_rep_2_1_ [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$blockage_width+$DB_width+$welltap_width)-0.72]  [expr $origin1_y-$stochastic_adc_PR_height+39*$cell_height] 


placeInstance Ibuf_clk_async_pi_2_0_ [expr $origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height-2*$cell_height] MY 
placeInstance Ibuf_clk_async_pi_2_1_ [expr $origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height-2*$cell_height] R180 
placeInstance Ibuf_clk_async_pi_2_2_ [expr $FP_width-($origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width)-0.72] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height-2*$cell_height] MX 
placeInstance Ibuf_clk_async_pi_2_3_ [expr $FP_width-($origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width)-0.72] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height-2*$cell_height]  


placeInstance Ibuf_clk_cdr_1 [expr $origin1_x+$stochastic_adc_PR_width+$blockage_width+9] [expr 15*$cell_height]

placeInstance Ibuf_clk_cdr_2_0_ [expr $origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height/2-13*$cell_height] MY 
placeInstance Ibuf_clk_cdr_2_1_ [expr $origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height/2+12*$cell_height] R180 
placeInstance Ibuf_clk_cdr_2_2_ [expr $FP_width-($origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width)-0.72] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height/2+12*$cell_height] MX 
placeInstance Ibuf_clk_cdr_2_3_ [expr $FP_width-($origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width)-0.72] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height/2-13*$cell_height]  


placeInstance Ibuf_ext_clk_aux_1 210.6 [expr 15*$cell_height] MY
placeInstance Ibuf_ext_clk_aux_2 190.98 [expr 123*$cell_height] MY

## outputs ##

#placeInstance Ibuf_inbuf_out_meas_1 169.11 [expr 127*$cell_height] MY
placeInstance Ibuf_inbuf_out_meas_1 172.8 [expr 7*$cell_height] 


#placeInstance Ibuf_pi_out_meas_1_0_ [expr $origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height+4*$cell_height] MY 
#placeInstance Ibuf_pi_out_meas_1_1_ [expr $origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height-6*$cell_height] R180 
#placeInstance Ibuf_pi_out_meas_1_2_ [expr $FP_width-($origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width)-0.72] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height-6*$cell_height] MX 
#placeInstance Ibuf_pi_out_meas_1_3_ [expr $FP_width-($origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width)-0.72] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height+4*$cell_height]  

placeInstance Ibuf_pi_out_meas_1_3_ [expr 163.98] [expr 5*$cell_height]
placeInstance Ibuf_pi_out_meas_1_2_ [expr 163.98+0.72] [expr 5*$cell_height]
placeInstance Ibuf_pi_out_meas_1_1_ [expr 163.98+2*0.72] [expr 5*$cell_height]
placeInstance Ibuf_pi_out_meas_1_0_ [expr 163.98+3*0.72] [expr 5*$cell_height]


placeInstance IMUX_del_out_pi [expr $origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height/2-9*$cell_height]  
placeInstance IAN_del_out_pi [expr $origin2_x+$phase_interpolator_width+0.9+$DB_width+$welltap_width+0.99] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height/2-9*$cell_height]  
placeInstance Ibuf_del_out_pi 180.54 [expr 5*$cell_height]

}






##-----------------------
# analog routes
##-----------------------
#createRouteBlk -box 0 0 [expr $origin2_x] $FP_height -layer 9
#createRouteBlk -box $FP_width 0 [expr $FP_width-($origin2_x)] $FP_height -layer 9
#routeMixedSignal -constraintFile ${scrDir}/floorplan/${DesignName}_MS_routes.tcl -deleteExistingRoutes
source ${scrDir}/floorplan/${DesignName}_pre_routing.tcl

#------------------------------------------------------
set RUN_LAYOUT_ONLY 0
##------------------------------------------------------

##------------------------------------------------------
## pnr variable file-out ##
##------------------------------------------------------
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "${DesignName}_width:$FP_width\n"
puts -nonewline $fid "${DesignName}_height:$FP_height\n"
close $fid

createPlaceBlockage -box 0 0 $origin1_x $FP_height -name blk_left_edge
createPlaceBlockage -box $FP_width 0 [expr $FP_width-$origin1_x] $FP_height -name blk_right_edge



















