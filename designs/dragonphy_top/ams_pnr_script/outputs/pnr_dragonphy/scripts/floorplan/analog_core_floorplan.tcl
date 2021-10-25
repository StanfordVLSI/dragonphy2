
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

set domain_blockage_width [expr ceil(5.0/$cell_grid)*$cell_grid]
set domain_blockage_height [expr ceil($domain_blockage_width/$cell_height)*$cell_height]

set block_blockage_width [expr ceil(0.5/$cell_grid)*$cell_grid]
set block_blockage_height $cell_height

set boundary_width $block_blockage_width
set boundary_height [expr 2*$cell_height]

set routing_height_center [expr 16*$cell_height]
set routing_width_center [expr ceil(40/$cell_grid)*$cell_grid]
set routing_width_side [expr 2*($DB_width+$welltap_width+$domain_blockage_width)+floor(12/$cell_grid)*$cell_grid]
#set routing_width_edge [expr 2*($DB_width)+4*$DCAP64_width]
set routing_width_edge $boundary_width

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


set origin3_x [expr $FP_width/2-$input_divider_width/2+$cell_grid/2]
set origin3_y [expr $origin1_y]
set iterm_x [expr $FP_width/2-$termination_width/2]
set iterm_y [expr $FP_height-$boundary_height-$biasgen_height-$stochastic_adc_PR_height]

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
## [PIs]
placeInstance iPI_0__iPI [expr $origin2_x] [expr $origin2_y] R180
placeInstance iPI_1__iPI [expr $origin2_x] [expr $origin2_y+$phase_interpolator_height+2*$routing_height_center] MY 
placeInstance iPI_2__iPI [expr $FP_width-( $origin2_x)-$phase_interpolator_width] [expr $origin2_y+$phase_interpolator_height+2*$routing_height_center]
placeInstance iPI_3__iPI [expr $FP_width-( $origin2_x)-$phase_interpolator_width] [expr $origin2_y] MX


createPlaceBlockage -box [expr $origin2_x-$block_blockage_width] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height-$cell_height] [expr $origin2_x+$phase_interpolator_width+$block_blockage_width] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center+$cell_height]
createPlaceBlockage -box [expr $origin2_x-$block_blockage_width] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center-$cell_height] [expr $origin2_x+$phase_interpolator_width+$block_blockage_width] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height+$cell_height] 
createPlaceBlockage -box [expr $FP_width-($origin2_x)-$phase_interpolator_width-$block_blockage_width] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center-$cell_height] [expr $FP_width-($origin2_x)+$block_blockage_width] [expr $origin1_y+4*$stochastic_adc_PR_height+$routing_height_center+$phase_interpolator_height+$cell_height]
createPlaceBlockage -box [expr $FP_width-($origin2_x)-$phase_interpolator_width-$block_blockage_width] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center-$phase_interpolator_height-$cell_height] [expr $FP_width-($origin2_x)+$block_blockage_width] [expr $origin1_y+4*$stochastic_adc_PR_height-$routing_height_center+$cell_height]

## [ADCs]
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

## [biasgens]
placeInstance iBG_0__iBG [expr $origin1_x] [expr $origin1_y+(-1)*$stochastic_adc_PR_height-$biasgen_height] MY
placeInstance iBG_1__iBG [expr $origin1_x] [expr $origin1_y+(8)*$stochastic_adc_PR_height] MY
placeInstance iBG_2__iBG [expr $FP_width-$origin1_x-$stochastic_adc_PR_width] [expr $origin1_y+(8)*$stochastic_adc_PR_height]
placeInstance iBG_3__iBG [expr $FP_width-$origin1_x-$stochastic_adc_PR_width] [expr $origin1_y+(-1)*$stochastic_adc_PR_height-$biasgen_height]


## [switches]
placeInstance iSnH/ISWp0 [expr $origin2_x-$SW_width-$SW_offset] [expr $origin1_y+2*$stochastic_adc_PR_height+$cell_height] R180
placeInstance iSnH/ISWn0 [expr $origin2_x-$SW_width-$SW_offset] [expr $origin1_y+2*$stochastic_adc_PR_height-$SW_height-$cell_height] MY
placeInstance iSnH/ISWp1 [expr $origin2_x-$SW_width-$SW_offset] [expr $origin1_y+6*$stochastic_adc_PR_height+$cell_height] R180
placeInstance iSnH/ISWn1 [expr $origin2_x-$SW_width-$SW_offset] [expr $origin1_y+6*$stochastic_adc_PR_height-$SW_height-$cell_height] MY
placeInstance iSnH/ISWp2 [expr $FP_width-($origin2_x-$SW_width-$SW_offset)-$SW_width] [expr $origin1_y+6*$stochastic_adc_PR_height+$cell_height] MX
placeInstance iSnH/ISWn2 [expr $FP_width-($origin2_x-$SW_width-$SW_offset)-$SW_width] [expr $origin1_y+6*$stochastic_adc_PR_height-$SW_height-$cell_height]
placeInstance iSnH/ISWp3 [expr $FP_width-($origin2_x-$SW_width-$SW_offset)-$SW_width] [expr $origin1_y+2*$stochastic_adc_PR_height+$cell_height] MX
placeInstance iSnH/ISWn3 [expr $FP_width-($origin2_x-$SW_width-$SW_offset)-$SW_width] [expr $origin1_y+2*$stochastic_adc_PR_height-$SW_height-$cell_height]

createPlaceBlockage -box [expr $origin2_x-$SW_width-$SW_offset-$block_blockage_width] [expr $origin1_y+2*$stochastic_adc_PR_height+$SW_height+$cell_height+$block_blockage_height] [expr $origin2_x-$SW_offset+$block_blockage_width] [expr $origin1_y+2*$stochastic_adc_PR_height-$SW_height-$cell_height-$block_blockage_height] 
createPlaceBlockage -box [expr $origin2_x-$SW_width-$SW_offset-$block_blockage_width] [expr $origin1_y+6*$stochastic_adc_PR_height+$SW_height+$cell_height+$block_blockage_height] [expr $origin2_x-$SW_offset+$block_blockage_width] [expr $origin1_y+6*$stochastic_adc_PR_height-$SW_height-$cell_height-$block_blockage_height] 
createPlaceBlockage -box [expr $FP_width-($origin2_x-$SW_width-$SW_offset)-$SW_width-$block_blockage_width] [expr $origin1_y+6*$stochastic_adc_PR_height+$SW_height+$cell_height+$block_blockage_height] [expr $FP_width-($origin2_x-$SW_width-$SW_offset)+$block_blockage_width] [expr $origin1_y+6*$stochastic_adc_PR_height-$SW_height-$cell_height-$block_blockage_height] 
createPlaceBlockage -box [expr $FP_width-($origin2_x-$SW_width-$SW_offset)-$SW_width-$block_blockage_width] [expr $origin1_y+2*$stochastic_adc_PR_height+$SW_height+$cell_height+$block_blockage_height] [expr $FP_width-($origin2_x-$SW_width-$SW_offset)+$block_blockage_width] [expr $origin1_y+2*$stochastic_adc_PR_height-$SW_height-$cell_height-$block_blockage_height] 


## [termination]
placeInstance iterm $iterm_x $iterm_y 


## [power domain blockages]
createPlaceBlockage -box 0 [expr $boundary_height] [expr $origin1_x+$stochastic_adc_PR_width+$domain_blockage_width] [expr $FP_height-$boundary_height]
createPlaceBlockage -box $FP_width [expr $boundary_height] [expr $FP_width-($origin1_x+$stochastic_adc_PR_width)-$domain_blockage_width] [expr $FP_height-$boundary_height]

createPlaceBlockage -box [expr $origin2_x-2*$DB_width-$welltap_width-$block_blockage_width-$domain_blockage_width] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height] [expr $origin2_x-2*$DB_width-$welltap_width-$block_blockage_width] [expr $FP_height]
createPlaceBlockage -box [expr $FP_width-($origin2_x-2*$DB_width-$welltap_width-$block_blockage_width-$domain_blockage_width)] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height] [expr $FP_width-($origin2_x-2*$DB_width-$welltap_width-$block_blockage_width)] [expr $FP_height]

createPlaceBlockage -box [expr $origin2_x-2*$DB_width-$welltap_width-$block_blockage_width] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height] [expr $FP_width-($origin2_x-2*$DB_width-$welltap_width-$block_blockage_width)] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height+$domain_blockage_height]
createPlaceBlockage -box [expr $origin2_x-2*$DB_width-$welltap_width-$block_blockage_width] [expr $FP_height-$boundary_height-$biasgen_height] [expr $FP_width-($origin2_x-2*$DB_width-$welltap_width-$block_blockage_width)] [expr $FP_height-$boundary_height-$biasgen_height-$domain_blockage_height]

createPlaceBlockage -box 0 0 $FP_width [expr 2*$cell_height]
createPlaceBlockage -box 0 [expr $FP_height-2*$cell_height] $FP_width $FP_height

createPlaceBlockage -box 0 0 $domain_blockage_width  $FP_height
createPlaceBlockage -box $FP_width 0 [expr $FP_width-$domain_blockage_width] $FP_height

## [boundary cells] 
addEndCap

## [input divider]
placeInstance iindiv $origin3_x $origin3_y
#createPlaceBlockage -box [expr $origin3_x-$block_blockage_width] [expr $origin3_y-$cell_height] [expr $origin3_x+$input_divider_width+$block_blockage_width] [expr $origin3_y+$input_divider_height+$cell_height]

## placement groups ------------------------------------------------------------------------------------------
createInstGroup grp0 -region [expr $origin2_x-$SW_width-$SW_offset] [expr $origin1_y+2*$stochastic_adc_PR_height+$cell_height-$SW_height-4*$cell_height] [expr $origin2_x] [expr $origin2_y] 
createInstGroup grp1 -region [expr $origin2_x-$SW_width-$SW_offset] [expr $origin1_y+6*$stochastic_adc_PR_height+$cell_height+$SW_height+2*$cell_height] [expr $origin2_x] [expr $origin2_y+2*$phase_interpolator_height+2*$routing_height_center]
createInstGroup grp2 -region [expr $FP_width-($origin2_x-$SW_width-$SW_offset)] [expr $origin1_y+6*$stochastic_adc_PR_height+$cell_height+$SW_height+2*$cell_height] [expr $FP_width-$origin2_x] [expr $origin2_y+2*$phase_interpolator_height+2*$routing_height_center] 
createInstGroup grp3 -region [expr $FP_width-($origin2_x-$SW_width-$SW_offset)] [expr $origin1_y+2*$stochastic_adc_PR_height+$cell_height-$SW_height-4*$cell_height] [expr $FP_width-$origin2_x] [expr $origin2_y] 

addInstToInstGroup grp0 {isw_s2d_0_}
addInstToInstGroup grp1 {isw_s2d_1_}
addInstToInstGroup grp2 {isw_s2d_2_}
addInstToInstGroup grp3 {isw_s2d_3_}
#--------------------------------------------------------------------------------------------------------------

#createRouteBlk -box [expr $origin2_x-$SW_width-$SW_offset] [expr $origin1_y+2*$stochastic_adc_PR_height+$cell_height-$SW_height-4*$cell_height] [expr $origin2_x] [expr $origin2_y] -layer 4
#createRouteBlk -box [expr $origin2_x-$SW_width-$SW_offset] [expr $origin1_y+6*$stochastic_adc_PR_height+$cell_height+$SW_height+2*$cell_height] [expr $origin2_x] [expr $origin2_y+2*$phase_interpolator_height+2*$routing_height_center] -layer 4
#createRouteBlk -box [expr $FP_width-($origin2_x-$SW_width-$SW_offset)] [expr $origin1_y+6*$stochastic_adc_PR_height+$cell_height+$SW_height+2*$cell_height] [expr $FP_width-$origin2_x] [expr $origin2_y+2*$phase_interpolator_height+2*$routing_height_center] -layer 4
#createRouteBlk -box [expr $FP_width-($origin2_x-$SW_width-$SW_offset)] [expr $origin1_y+2*$stochastic_adc_PR_height+$cell_height-$SW_height-4*$cell_height] [expr $FP_width-$origin2_x] [expr $origin2_y] -layer 4

## [welltaps]
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin1_x+$stochastic_adc_PR_width+$domain_blockage_width+$DB_width] -cellInterval $FP_width -prefix WELLTAP 
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin2_x-$block_blockage_width-$domain_blockage_width-3*$DB_width-2*$welltap_width] -cellInterval $FP_width -prefix WELLTAP 
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin2_x-$block_blockage_width-$DB_width-$welltap_width] -cellInterval $FP_width -prefix WELLTAP 
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $origin2_x+$phase_interpolator_width+$block_blockage_width+$DB_width] -cellInterval $FP_width -prefix WELLTAP 

addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width/2] -cellInterval $FP_width -prefix WELLTAP 

addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$domain_blockage_width+$DB_width)-$welltap_width] -cellInterval $FP_width -prefix WELLTAP 
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin2_x-$block_blockage_width-$domain_blockage_width-3*$DB_width-2*$welltap_width)-$welltap_width] -cellInterval $FP_width -prefix WELLTAP 
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin2_x-$block_blockage_width-$DB_width-$welltap_width)-$welltap_width] -cellInterval $FP_width -prefix WELLTAP 
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-($origin2_x+$phase_interpolator_width+$block_blockage_width+$DB_width)-$welltap_width] -cellInterval $FP_width -prefix WELLTAP 


### [IO pins]

#(Primary Inout  clocks)
#assignIoPins -align -pin {ext_clk mdll_clk}


#(ADC control pins)
assignIoPins -align -pin {adder_out* sign_out* *ctl_v2t* *init* *ALWS_ON* *ctl_dcdl_early* *ctl_dcdl_late* *ctl_dcdl_TDC* *del_out[* *del_out_rep[* *en_slice* *ctrl* *PFD*}

#(Other control pins)
set pin_list {clk_adc clk_async ctl_pi* *en_arb_pi* *en_delay_pi* *en_pm_pi* *en_cal_pi* *Qperi* *sel_pm_sign_pi* *del_inc* ext_clk *ctl_dcdl_slice* mdll_clk *disable_ibuf_mdll* *sel_del_out* *ctl_dcdl_sw* *ctl_dcdl_clk_encoder* *ctl_valid* *disable_state* *bypass_inbuf_div* *en_TDC_phase_reverse* *biasgen* *en_clk_sw* *en_meas_pi* *sel_meas_pi* *inbuf_ndiv* *pm_out_pi* *cal_out_pi* *max_sel_mux* *pi_out_meas* *inbuf_out_meas *del_out_pi ext_clk_test* *rstb *en_v2t *en_gf *en_inbuf *sel_clk_source *bypass_inbuf_div *bypass_inbuf_div2 *en_inbuf_meas *enb_unit*}
setPinAssignMode -pinEditInBatch true
assignIoPins -pin $pin_list
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -spreadDirection counterclockwise -edge 3 -layer 3  -spreadType range -offsetStart [expr $origin1_x+$stochastic_adc_PR_width+$domain_blockage_width+2*$welltap_width] -offsetEnd [expr ($origin1_x+$stochastic_adc_PR_width+$domain_blockage_width+2*$welltap_width)]  -pin $pin_list 

#(Vcm)
assignIoPin -align -pin {Vcm} 
editPin -pinWidth $rx_in_width -pinDepth [expr $FP_height-$iterm_y] -fixOverlap 0 -spreadDirection clockwise -edge 1 -layer 9  -spreadType start -offsetStart [expr $FP_width/2] -pin {Vcm}
editPin -pinWidth $rx_in_width -pinDepth [expr $boundary_height+$biasgen_height+1.5*$stochastic_adc_PR_height+$rx_in_width/2] -fixOverlap 0 -layer 9 -pin {rx_inn rx_inp}



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



#(test analog inputs)
set rx_inp_test_M8_offset [get_property [get_pins iADCrep0/VinP] y_coordinate]
set rx_inn_test_M8_offset [get_property [get_pins iADCrep0/VinN] y_coordinate]
set rx_in_test_space 40

setEdit -nets rx_inp_test
editAddRoute [expr $origin1_x+$stochastic_adc_PR_width]  $rx_inp_test_M8_offset
editCommitRoute [expr $FP_width-($origin1_x+$stochastic_adc_PR_width)] $rx_inp_test_M8_offset
setEdit -nets rx_inn_test
editAddRoute [expr $origin1_x+$stochastic_adc_PR_width]  $rx_inn_test_M8_offset
editCommitRoute [expr $FP_width-($origin1_x+$stochastic_adc_PR_width)] $rx_inn_test_M8_offset

#editPin -pinWidth $rx_in_width -pinDepth [expr $origin1_y] -fixOverlap 0  -spreadDirection counterclockwise -edge 3 -layer 9 -spreadType start -offsetStart [expr $FP_width/2-$rx_in_test_space/2] -pin {rx_inp_test}
#editPin -pinWidth $rx_in_width -pinDepth [expr $origin1_y] -fixOverlap 0  -spreadDirection counterclockwise -edge 3 -layer 9 -spreadType start -offsetStart [expr $FP_width/2+$rx_in_test_space/2] -pin {rx_inn_test}

createPhysicalPin rx_inp_test -net rx_inp_test -layer 9 -rect [expr ($FP_width/2-$rx_in_width/2)-$rx_in_test_space/2] 0 [expr ($FP_width/2+$rx_in_width/2)-$rx_in_test_space/2]  $rx_in_width 
createPhysicalPin rx_inn_test -net rx_inp_test -layer 9 -rect [expr ($FP_width/2-$rx_in_width/2)+$rx_in_test_space/2] 0 [expr ($FP_width/2+$rx_in_width/2)+$rx_in_test_space/2]  $rx_in_width 


set rx_inp_test_M9_offset [get_property [get_ports rx_inp_test] x_coordinate]
set rx_inn_test_M9_offset [get_property [get_ports rx_inn_test] x_coordinate]

setEdit -nets rx_inp_test
editAddRoute [expr $rx_inp_test_M9_offset]  0
editCommitRoute [expr $rx_inp_test_M9_offset] [expr $origin1_y-4*$cell_height]
setEdit -nets rx_inn_test
editAddRoute [expr $rx_inn_test_M9_offset]  0
editCommitRoute [expr $rx_inn_test_M9_offset] [expr $origin1_y-4*$cell_height]



##########################
####  Power Connects  ####
##########################

##### [AVDD] 
globalNetConnect AVDD -type pgpin -pin VDD -inst * -override
globalNetConnect AVSS -type pgpin -pin VSS -inst * -override
globalNetConnect AVDD -type pgpin -pin VPP -inst * -override
globalNetConnect AVSS -type pgpin -pin VBB -inst * -override
globalNetConnect AVDD -type pgpin -pin AVDD -inst *iADC* -override
globalNetConnect AVSS -type pgpin -pin AVSS -inst *iADC* -override
globalNetConnect AVDD -type pgpin -pin VDD -inst *iBG* -override
globalNetConnect AVSS -type pgpin -pin VSS -inst *iBG* -override

createRouteBlk -box 0 [expr $boundary_height+$biasgen_height] $FP_width [expr $FP_height-($boundary_height+$biasgen_height)] -layer 8 -name Vcal_M8_blk

#(Vcal)
#createRouteBlk -box 0 0 $FP_width [expr $boundary_height+$biasgen_height] -layer 8
sroute -connect { blockPin } -layerChangeRange { M8 M7 } -blockPinTarget { blockPin } -deleteExistingRoutes -allowJogging 1 -crossoverViaLayerRange { M8 M7 } -nets { Vcal AVDD AVSS} -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M1 }
deleteRouteBlk -all





# (ADC/BG M9) 
sroute -connect { blockPin } -layerChangeRange { M9 M9 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M9 M1 } -nets { AVDD AVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M9 M1 } 


createRouteBlk -box 0 0 [expr $origin2_x-$block_blockage_width-2*$DB_width-$welltap_width] $FP_height -name AVDD__blk_left -layer {1 7 8 9}
createRouteBlk -box $FP_width 0 [expr $FP_width-($origin2_x-$block_blockage_width-2*$DB_width-$welltap_width)] $FP_height -name AVDD_blk_right -layer {1 7 8 9}
createRouteBlk -box [expr $origin2_x-$block_blockage_width-2*$DB_width-$welltap_width] $FP_height [expr $FP_width-($origin2_x-$block_blockage_width-2*$DB_width-$welltap_width)] [expr $FP_height-$boundary_height-$biasgen_height-$domain_blockage_height+$cell_height] -name AVDD_blk_top -layer {1 7 8 9}
createRouteBlk -box 0 0 $FP_width [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height+$domain_blockage_height-$cell_height] -name AVDD_blk_bottom -layer {1 7 8 9}

# (M1)
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

createRouteBlk -box [expr $iterm_x-$block_blockage_width] [expr $iterm_y-$block_blockage_height] [expr $iterm_x+$termination_width+$block_blockage_width] [expr $iterm_y+$termination_height+$block_blockage_height] -name iterm_M78_blk -layer {7 8}
createRouteBlk -box [expr $iterm_x-$block_blockage_width] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height] [expr $iterm_x+$termination_width+$block_blockage_width] [expr $iterm_y+$termination_height+$block_blockage_height] -name iterm_M9_blk -layer {9}


#(M7)
addStripe -nets {AVDD AVSS} \
  -layer M7 -direction vertical -width $DVDD_M7_width -spacing $DVDD_M7_space -start_offset 0 -set_to_set_distance [expr 2*($DVDD_M7_width+$DVDD_M7_space)]  -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape}


#(M8)
addStripe -nets {AVDD AVSS} \
  -layer M8 -direction horizontal -width $DVDD_M8_width -spacing $DVDD_M8_space -start_offset 0 -set_to_set_distance [expr 2*($DVDD_M8_width+$DVDD_M8_space)]  -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape}

createRouteBlk -box 0 0 $FP_width $FP_height -layer {M7 VIA6} -name VIA_blk_all

#(M9)
addStripe -nets {AVDD AVSS} \
  -layer M9 -direction vertical -width $M9_width -spacing $M9_space -start_offset 0 -set_to_set_distance [expr 2*($M9_width+$M9_space)]  -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape}

deleteRouteBlk -name VIA_blk_all 
deleteRouteBlk -name AVDD_blk_top 

#(M10)
#addStripe -nets {AVDD AVSS} \
#  -layer M10 -direction horizontal -width 20 -spacing 10 -start_offset [expr $biasgen_height-20*$cell_height]  -set_to_set_distance $FP_width -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit M9 -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary -create_pins 1 


##### [Vcal] 

globalNetConnect Vcal -type pgpin -pin VDD -inst * -override
globalNetConnect AVSS -type pgpin -pin VSS -inst * -override
globalNetConnect Vcal -type pgpin -pin VPP -inst * -override
globalNetConnect AVSS -type pgpin -pin VBB -inst * -override

createRouteBlk -box [expr $origin2_x-$block_blockage_width-2*$DB_width-$welltap_width] [expr $FP_height-$boundary_height-$biasgen_height-$cell_height] [expr $FP_width-($origin2_x-$block_blockage_width-2*$DB_width-$welltap_width)] 0 -name Vcal_M1_blk -layer {1}



#(M1)
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
  -nets {Vcal AVSS}  

#(M7)
addStripe -nets {Vcal AVSS} \
  -layer M7 -direction vertical -width $DVDD_M7_width -spacing $DVDD_M7_space -start_offset 0 -set_to_set_distance [expr 2*($DVDD_M7_width+$DVDD_M7_space)]  -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape}


createRouteBlk -box 0 0 $FP_width $FP_height -layer {M7 VIA6} -name VIA_blk_all

#(M9)
addStripe -nets {Vcal AVSS} \
  -layer M9 -direction vertical -width $M9_width -spacing $M9_space -start_offset 0 -set_to_set_distance [expr 2*($M9_width+$M9_space)]  -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape}


deleteRouteBlk -all

#editPin -pinWidth $rx_in_width -pinDepth [expr $boundary_height+$biasgen_height] -fixOverlap 1  -spreadDirection counterclockwise -edge 1 -layer 9 -spreadType start -offsetStart [expr ($origin2_x-$origin1_x+$stochastic_adc_PR_width)/2] -pin {Vcal}
createPhysicalPin Vcal -net Vcal -layer 9 -rect [expr $FP_width-($origin2_x-$origin1_x+$stochastic_adc_PR_width)/2-5] $FP_height [expr $FP_width-($origin2_x-$origin1_x+$stochastic_adc_PR_width)/2] [expr $FP_height-5]

createRouteBlk -box 0 0 $FP_width $FP_height -layer {M7 VIA6} -name VIA_blk_all

set Vcal_M9_offset [get_property [get_ports Vcal] x_coordinate]
setEdit -nets Vcal
editAddRoute [expr $Vcal_M9_offset]  [expr $FP_height]
editCommitRoute [expr $Vcal_M9_offset]  [expr $FP_height-($boundary_height+$biasgen_height)]

deleteRouteBlk -all




#### [DVDD]
globalNetConnect DVDD -type pgpin -pin DVDD -inst *iADC* -override
globalNetConnect DVSS -type pgpin -pin DVSS -inst *iADC* -override

#(M8)
createRouteBlk -box [expr $origin1_x+$stochastic_adc_PR_width-$V2T_width] 0 [expr $FP_width-($origin1_x+$stochastic_adc_PR_width-$V2T_width)] $FP_height -name DVDD_M8_blk1 -layer {8 9}
sroute -connect { blockPin } -layerChangeRange { M8 M8 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M8 M7 } -nets { DVDD DVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M7 } 

#(M9)
sroute -connect { blockPin } -layerChangeRange { M9 M9 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M9 M8 } -nets { DVDD DVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M9 M8 } 

deleteRouteBlk -all

### [pre_route] RX analog inputs
source ${scrDir}/floorplan/${DesignName}_pre_routing.tcl



##### [CVDD] 
globalNetConnect CVDD -type pgpin -pin VDD -inst * -override
globalNetConnect CVSS -type pgpin -pin VSS -inst * -override
globalNetConnect CVDD -type pgpin -pin VPP -inst * -override
globalNetConnect CVSS -type pgpin -pin VBB -inst * -override

globalNetConnect AVDD -type pgpin -pin AVDD -inst {*iADC*} -override
globalNetConnect AVSS -type pgpin -pin AVSS -inst {*iADC*} -override

globalNetConnect AVDD -type pgpin -pin VDD -inst {*iBG*} -override
globalNetConnect AVSS -type pgpin -pin VSS -inst {*iBG*} -override

globalNetConnect DVDD -type pgpin -pin DVDD -inst {*iADC*} -override
globalNetConnect DVSS -type pgpin -pin DVSS -inst {*iADC*} -override


createRouteBlk -box [expr $origin2_x-$block_blockage_width-2*$DB_width-$welltap_width-$domain_blockage_width] [expr $FP_height] [expr $FP_width-($origin2_x-$block_blockage_width-2*$DB_width-$welltap_width-$domain_blockage_width)] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height] -name CVDD_M1_blk_top -layer 1
createRouteBlk -box 0 0 [expr $origin1_x+$stochastic_adc_PR_width+$domain_blockage_width] $FP_height -name CVDD_M1_left -layer 1
createRouteBlk -box $FP_width 0 [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$domain_blockage_width)] $FP_height -name CVDD_M1_right -layer 1

#(M1)
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

deleteRouteBlk -all

#(M7)
createRouteBlk -box [expr $origin2_x-$block_blockage_width-2*$DB_width-$welltap_width-$domain_blockage_width] [expr $FP_height] [expr $FP_width-($origin2_x-$block_blockage_width-2*$DB_width-$welltap_width-$domain_blockage_width)] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height] -name CVDD_M7_blk -layer 7


addStripe -nets {CVSS CVDD} \
  -layer M7 -direction vertical -width $input_divider_power_M7_width -spacing $input_divider_power_M7_space -start_offset [expr $origin3_x+$input_divider_power_M7_offset1] -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
addStripe -nets {CVSS CVDD} \
  -layer M7 -direction vertical -width $input_divider_power_M7_width -spacing $input_divider_power_M7_space -start_offset [expr $origin3_x+$input_divider_power_M7_offset2] -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary
addStripe -nets {CVSS CVDD} \
  -layer M7 -direction vertical -width $input_divider_power_M7_width -spacing $input_divider_power_M7_space -start_offset [expr $origin3_x+$input_divider_power_M7_offset3] -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary

createRouteBlk -box [expr $origin3_x] [expr $FP_height] [expr $origin3_x+$input_divider_width] 0 -name CVDD_M7_blk_input_divider -layer 7

addStripe -nets {CVDD CVSS} \
  -layer M7 -direction vertical -width $DVDD_M7_width -spacing [expr 2*$DVDD_M7_space] -start_offset [expr $origin2_x+$phase_interpolator_width+$DVDD_M7_space] -stop_offset [expr ($origin2_x+$phase_interpolator_width+$DVDD_M7_space)] -set_to_set_distance [expr 2*($DVDD_M7_width+2*$DVDD_M7_space)] -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary

addStripe -nets {CVDD CVSS} \
  -layer M7 -direction vertical -width [expr 2*$DVDD_M7_width] -spacing [expr 2*$DVDD_M7_space] -start_offset [expr $origin1_x+$stochastic_adc_PR_width+$domain_blockage_width+$DVDD_M7_space] -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary

addStripe -nets {CVDD CVSS} \
  -layer M7 -direction vertical -width [expr 2*$DVDD_M7_width] -spacing [expr 2*$DVDD_M7_space] -start_offset [expr $origin1_x+$stochastic_adc_PR_width+$domain_blockage_width+$DVDD_M7_space] -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -create_pins 1 -extend_to design_boundary

deleteRouteBlk -name CVDD_M7_blk_input_divider

#(M8)
sroute -connect { blockPin } -layerChangeRange { M8 M7 } -blockPinTarget { blockPin } -deleteExistingRoutes -allowJogging 1 -crossoverViaLayerRange { M8 M7 } -nets { CVDD CVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M7 }
sroute -connect { blockPin } -layerChangeRange { M7 M7 } -blockPinTarget { boundaryWithPin } -allowJogging 0 -crossoverViaLayerRange { M7 M1 } -nets { CVDD CVSS } -allowLayerChange 0 -blockPin useLef -targetViaLayerRange { M8 M1 } 

createRouteBlk -box 0 0 [expr $origin2_x] $FP_height -name CVDD_M8_left -layer {8 9}
createRouteBlk -box $FP_width 0 [expr $FP_width-($origin2_x)] $FP_height -name CVDD_M8_blk_right -layer {8 9}

#addStripe -nets {CVDD CVSS} \
#  -layer M8 -direction horizontal -width $AVDD_M7_width -spacing $AVDD_M7_space -start_offset [expr $origin1_y+3.525] -stop_offset [expr $FP_height-($origin1_y+$input_divider_height)] -set_to_set_distance 6.951 -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} 

addStripe -nets {CVSS} \
  -layer M8 -direction horizontal -width $input_divider_power_M8_width -spacing $FP_height -start_offset [expr $origin3_y]  -set_to_set_distance $FP_height -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} 
addStripe -nets {CVDD} \
  -layer M8 -direction horizontal -width $input_divider_power_M8_width -spacing $FP_height -start_offset [expr $origin3_y+$input_divider_height-$input_divider_power_M8_width]  -set_to_set_distance $FP_height -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} 

createRouteBlk -box 0 [expr $origin2_y-$DVDD_M8_width] $FP_width $FP_height -name CVDD_M89_blk_top -layer {8 9}
createRouteBlk -box 0 0 $FP_width [expr $origin3_y+$input_divider_height] -name CVDD_M8_blk_bottom -layer {8}
createRouteBlk -box 0 0 $FP_width [expr $origin3_y-$cell_height] -name CVDD_M9_blk_bottom -layer {9}

addStripe -nets {CVDD CVSS} \
  -layer M8 -direction horizontal -width $DVDD_M8_width -spacing [expr 2*$DVDD_M8_space] -start_offset 0  -set_to_set_distance [expr 2*($DVDD_M8_width+2*$DVDD_M8_space)] -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M8 -block_ring_top_layer_limit M8 -block_ring_bottom_layer_limit M8 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} 

deleteRouteBlk -name CVDD_M8_blk_bottom 

#(M9)
createRouteBlk -box 0 0 $FP_width $FP_height -name CVDD_M7_blk -layer {7}

addStripe -nets {CVSS CVDD} \
  -layer M9 -direction vertical -width $M9_width -spacing $M9_space -start_offset [expr $origin2_x+2*$M9_width] -stop_offset [expr $origin2_x+$M9_space]  -set_to_set_distance [expr 2*($M9_width+$M9_space)] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} 

deleteRouteBlk -all






#(M10 power ports)
set M10_width 20
set M10_space 10
set M10_offset [expr $bump_size/2+$bump_pitch-(2*$M10_width+2*$M10_space)]

createRouteBlk -box 0 0 $FP_width $FP_height -layer 8 -name M10_blk

addStripe -nets {AVSS AVDD} \
  -layer M10 -direction horizontal -width $M10_width -spacing $M10_space -start_offset [expr $y_center+$M10_offset]  -set_to_set_distance $FP_width -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary -create_pins 1 

addStripe -nets {CVDD CVSS} \
  -layer M10 -direction horizontal -width $M10_width -spacing $M10_space -start_offset [expr $y_center-$M10_offset-2*$M10_width-$M10_space]  -set_to_set_distance $FP_width -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape} -extend_to design_boundary -create_pins 1 

deleteRouteBlk -all


### [Mixed signal routing]
#routeMixedSignal -constraintFile ${scrDir}/floorplan/${DesignName}_MS_routes.tcl -deleteExistingRoutes

createRouteBlk -box $origin2_x $origin2_y [expr $FP_width-$origin2_x] [expr $origin2_y+2*$phase_interpolator_height+2*$routing_height_center] -layer 8


## -------------------------------------------------------------------------------------------
## HOT FIX (May 19th 2020)
## -------------------------------------------------------------------------------------------
#createPhysicalPin Vcal -net Vcal -layer 9 -rect 253.82 [expr $FP_height-5] 258.82 $FP_height
#createPhysicalPin rx_inp_test -net rx_inp_test -layer 9 -rect 178.22 0 183.22 5 
#createPhysicalPin rx_inn_test -net rx_inn_test -layer 9 -rect 218.54 0 223.54 5 
## -------------------------------------------------------------------------------------------


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




