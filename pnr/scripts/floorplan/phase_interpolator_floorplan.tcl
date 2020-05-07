
set delay_Nunit 32
set blender_Nunit 16

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

#---------------------------------------------------------
# calculate cell widths
#---------------------------------------------------------
set mux_blender_area [get_property [get_cells iphase_blender_dont_touch/imux_bld_dont_touch_0_/U1] area]
set mux_blender_width [expr round($mux_blender_area/$cell_height/$cell_grid)*$cell_grid]

set inbuf1_area [get_property [get_cells iphase_blender_dont_touch/iin_buf_odd1_dont_touch/U1] area]
set inbuf1_width [expr round($inbuf1_area/$cell_height/$cell_grid)*$cell_grid]
set inbuf2_area [get_property [get_cells iphase_blender_dont_touch/iin_buf_odd2_dont_touch/U1] area]
set inbuf2_width [expr round($inbuf2_area/$cell_height/$cell_grid)*$cell_grid]
set outbuf1_area [get_property [get_cells iphase_blender_dont_touch/iout_buf1_dont_touch/U1] area]
set outbuf1_width [expr round($outbuf1_area/$cell_height/$cell_grid)*$cell_grid]
set outbuf2_area [get_property [get_cells iphase_blender_dont_touch/iout_buf2_dont_touch/U1] area]
set outbuf2_width [expr round($outbuf2_area/$cell_height/$cell_grid)*$cell_grid]

set ff_pm_area [get_property [get_cells iPM/iPM_sub/ff_ref_reg] area]
set ff_pm_width [expr round($ff_pm_area/$cell_height/$cell_grid)*$cell_grid]

set xor_pm_area [get_property [get_cells iPM/iPM_sub/uXOR1/U1] area]
set xor_pm_width [expr round($xor_pm_area/$cell_height/$cell_grid)*$cell_grid]


#---------------------------------------------------------
# space for routing
#---------------------------------------------------------
set boundary_width [expr $DB_width+$welltap_width]
set boundary_height [expr $cell_height]

set routing_space0 [expr ceil((8)/$cell_grid)*$cell_grid]
set routing_space1 [expr ceil((2)/$cell_grid)*$cell_grid]
set routing_space2 [expr ceil((2)/$cell_grid)*$cell_grid]
set routing_space1_1 [expr $routing_space1-$welltap_width]
set routing_space2_1 [expr $routing_space2-$welltap_width]


##---------------------------------------------------------
## set FloorPlan
##---------------------------------------------------------
floorPlan -site core -r 1 0.4 0 0 0 0
set raw_area [dbGet top.fPlan.area]

set FP_width [expr 2*$boundary_width+$routing_space0+$routing_space1+$routing_space2+$PI_delay_unit_width+2*$mux4_gf_width+$inbuf1_width+$inbuf2_width+$mux_blender_width+3*$welltap_width]
set FP_height [expr ceil($raw_area/$FP_width/$cell_height/2)*2*$cell_height]
#set FP_height [expr ceil((40)/$cell_height/2)*2*$cell_height]

floorPlan -site core -s $FP_width $FP_height 0 0 0 0



set origin1_x [expr $boundary_width+$routing_space0]
set origin1_y [expr $boundary_height+3*$cell_height]


##---------------------------------------------------------
## welltap / boundary cell settings
##---------------------------------------------------------
set FP_WTAP_S $FP_width  ;  # well tap spacing
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
  -rule ${FP_WTAP_S} \
  -bottom_tap_cell BOUNDARY_NTAPBWP16P90 \
  -top_tap_cell    BOUNDARY_PTAPBWP16P90 \
  -block_boundary_only true \
  -cell TAPCELLBWP16P90


addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width/2]  -cellInterval $FP_width -prefix WELLTAP

##---------------------------------------------------------
## M1 PG connect
##---------------------------------------------------------
globalNetConnect VDD -type tiehi -override
globalNetConnect VSS -type tielo -override
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override
globalNetConnect VDD -type pgpin -pin VPP -inst * -override
globalNetConnect VSS -type pgpin -pin VBB -inst * -override

addStripe -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -master "*"   \
  -merge_stripes_value 0.045   \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -extend_to design_boundary \
  -nets [list VDD VSS] 

deleteInst WELL* 
addEndCap 

addWellTap -cell TAPCELLBWP16P90 -inRowOffset 0 -cellInterval $FP_width -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-$boundary_width-$welltap_width] -cellInterval $FP_width -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-$boundary_width-2*$welltap_width] -cellInterval $FP_width -prefix WELLTAP
addWellTap -cell TAPCELLBWP16P90 -inRowOffset [expr $FP_width-$boundary_width-3*$welltap_width] -cellInterval $FP_width -prefix WELLTAP


#---------------------------------------------------------
# NDR settings
#---------------------------------------------------------
#add_ndr -name NDR_2W1S -spacing {M1:M2 0.05 M3 0.05 M4:M7 0.05} -width {M1:M2 0.64 M3 0.76 M4:M7 0.08} 
#add_ndr -name NDR_3W1S -spacing {M1:M2 0.05 M3 0.05 M4:M7 0.05} -width {M1:M2 0.12 M3 0.12 M4:M7 0.12} 
#add_ndr -name NDR_5W2S -spacing {M1:M2 0.05 M3 0.05 M4:M7 0.05} -width {M1:M2 0.18 M3 0.18 M4:M7 0.2} 
#add_ndr -name NDR_WIDE -spacing {M1:M2 0.2 M3 0.2 M4:M7 0.2 M9 0.2} -width {M1:M2 1 M3 1 M4:M7 1.2 M8 1.3} 

#setAttribute -net pfd_out -non_default_rule NDR_WIDE

#foreach_in_collection i [get_nets *CLK*] {
#        setAttribute -net [get_object_name $i] -non_default_rule NDR_3W1S
#}


#---------------------------------------------------------
# pre-placement
#---------------------------------------------------------
#[delay_chain]
for { set k 0} {$k < $delay_Nunit} {incr k} {
	placeInstance iPI_delay_chain_dont_touch/iPI_delay_unit_dont_touch_$k\_ [expr $origin1_x] [expr $origin1_y+$k*$PI_delay_unit_height]
}
createPlaceBlockage -box [expr $origin1_x] [expr $origin1_y] [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$mux4_gf_width+$routing_space2] [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height] -type hard

#[mux_network_dont_touch]
#(mux 1st stage)
for { set k 0} {$k < [expr $delay_Nunit/8]} {incr k} {
	placeInstance imux_network_dont_touch/imux4_gf_1st_$k\__even_dont_touch [expr $origin1_x+$PI_delay_unit_width+$routing_space1] [expr $origin1_y+($k*16)*$cell_height+2*$cell_height]
#	createPlaceBlockage -box  [expr $origin1_x+$PI_delay_unit_width+$routing_space1-$DB_width] [expr $origin1_y+($k*16)*$cell_height+2*$cell_height-$cell_height] [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$mux4_gf_width+$DB_width] [expr $origin1_y+($k*16)*$cell_height+2*$cell_height+$mux4_gf_height+$cell_height] -type hard
	
	placeInstance imux_network_dont_touch/imux4_gf_1st_$k\__odd_dont_touch [expr $origin1_x+$PI_delay_unit_width+$routing_space1] [expr $origin1_y+($k*16)*$cell_height+10*$cell_height]
#	createPlaceBlockage -box  [expr $origin1_x+$PI_delay_unit_width+$routing_space1-$DB_width] [expr $origin1_y+($k*16)*$cell_height+10*$cell_height-$cell_height] [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$mux4_gf_width+$DB_width] [expr $origin1_y+($k*16)*$cell_height+10*$cell_height+$mux4_gf_height+$cell_height] -type hard
}
#(mux 2nd stage)
placeInstance imux_network_dont_touch/imux4_gf_2nd_even_dont_touch [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$mux4_gf_width+$routing_space2-$DB_width] [expr $origin1_y+26*$cell_height]
createPlaceBlockage -box [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$mux4_gf_width+$routing_space2-$DB_width-$DB_width] [expr $origin1_y+26*$cell_height-$cell_height] [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$mux4_gf_width+$routing_space2-$DB_width+$mux4_gf_width+$DB_width] [expr $origin1_y+26*$cell_height+$mux4_gf_height+$cell_height] -type hard  

placeInstance imux_network_dont_touch/imux4_gf_2nd_odd_dont_touch [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$mux4_gf_width+$routing_space2-$DB_width] [expr $origin1_y+34*$cell_height]
createPlaceBlockage -box [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$mux4_gf_width+$routing_space2-$DB_width-$DB_width] [expr $origin1_y+34*$cell_height-$cell_height] [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$mux4_gf_width+$routing_space2-$DB_width+$mux4_gf_width+$DB_width] [expr $origin1_y+34*$cell_height+$mux4_gf_height+$cell_height] -type hard 


#[phase_blender]
#(blender_inbuf)
placeInstance iphase_blender_dont_touch/iin_buf_odd1_dont_touch/U1  [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$routing_space2+2*$mux4_gf_width] [expr $origin1_y+$PI_delay_unit_height*$delay_Nunit/2-($blender_Nunit/4+1)*$cell_height]
placeInstance iphase_blender_dont_touch/iin_buf_odd2_dont_touch/U1 [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$routing_space2+2*$mux4_gf_width+$inbuf1_width] [expr $origin1_y+$PI_delay_unit_height*$delay_Nunit/2-($blender_Nunit/4+1)*$cell_height]

placeInstance iphase_blender_dont_touch/iin_buf_even1_dont_touch/U1  [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$routing_space2+2*$mux4_gf_width] [expr $origin1_y+$PI_delay_unit_height*$delay_Nunit/2+($blender_Nunit/4)*$cell_height]
placeInstance iphase_blender_dont_touch/iin_buf_even2_dont_touch/U1 [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$routing_space2+2*$mux4_gf_width+$inbuf1_width] [expr $origin1_y+$PI_delay_unit_height*$delay_Nunit/2+($blender_Nunit/4)*$cell_height]
#(blender_mux_array)
for { set k 0} {$k < $blender_Nunit} {incr k} {
	placeInstance iphase_blender_dont_touch/imux_bld_dont_touch_${k}_/U1 [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$routing_space2+2*$mux4_gf_width+$inbuf1_width+$inbuf2_width] [expr $origin1_y+$PI_delay_unit_height*$delay_Nunit/2-$blender_Nunit/2*$cell_height+$k*$cell_height]
}
#(blender_outbuf)
placeInstance iphase_blender_dont_touch/iout_buf1_dont_touch/U1  [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$routing_space2+2*$mux4_gf_width+$inbuf1_width+$inbuf2_width] [expr $origin1_y+$PI_delay_unit_height*$delay_Nunit/2+($blender_Nunit/2)*$cell_height] MY
placeInstance iphase_blender_dont_touch/iout_buf2_dont_touch/U1  [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$routing_space2+2*$mux4_gf_width+$inbuf1_width+$inbuf2_width] [expr $origin1_y+$PI_delay_unit_height*$delay_Nunit/2+($blender_Nunit/2+1)*$cell_height] 



#---------------------------------------------------------
# cell grouping
#---------------------------------------------------------
createInstGroup grp0 -region [expr $origin1_x+$PI_delay_unit_width+$routing_space1+$routing_space2+$mux4_gf_width] [expr $origin1_y+$delay_Nunit/2*$PI_delay_unit_height-4*$cell_height] [expr $FP_width-$boundary_width-$mux_blender_width] [expr $origin1_y+$delay_Nunit/2*$PI_delay_unit_height+4*$cell_height] 
addInstToInstGroup grp0 {iarbiter iinv_chain ia_nd_ph_out}

createInstGroup grp1 -region  [expr $FP_width-$boundary_width-3*$welltap_width-3] [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height-4*$cell_height] [expr $FP_width-$boundary_width-3*$welltap_width]  [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height+4*$cell_height] 
addInstToInstGroup grp1 {idcdl_fine0 idcdl_fine1}

createInstGroup grp2 -region [expr $origin1_x+$PI_delay_unit_width] [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height] [expr $FP_width-$boundary_width-3*$welltap_width] [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height+2*$cell_height] 
addInstToInstGroup grp2 {iPM/iPM_sub/*}

createInstGroup grp3 -region [expr $origin1_x] [expr $boundary_height] [expr $origin1_x+$PI_delay_unit_width] [expr $origin1_y] 
addInstToInstGroup grp3 {ia_nd_clk_in iinv_buff*}

#createRouteBlk -box [expr $FP_width-$boundary_width-3*$welltap_width-3] [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height] [expr $FP_width-$boundary_width-3*$welltap_width]  [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height+8*$cell_height] 


##--------------------------------------------
## power routing
##--------------------------------------------

set PI_clk_in_M4_width [expr $AVDD_M7_width/8]
set PI_clk_in_M5_width [expr $AVDD_M7_width/2]
set clk_in_net [get_property [get_nets -of_objects [get_pins iPI_delay_chain_dont_touch/clk_in]] name] 
set PI_clk_in_offset [get_property [get_pins iPI_delay_chain_dont_touch/iPI_delay_unit_dont_touch_0_/arb_in] x_coordinate]
set PI_delay_chain_power_offset [expr $origin1_x+$PI_delay_unit_M7_power_offset] 
set PI_delay_chain_power_space [expr $PI_delay_unit_width-$welltap_width-$AVDD_M7_width] 


addStripe -nets {VDD VSS} \
  -layer M7 -direction vertical -width [expr $AVDD_M7_width/2] -spacing $PI_delay_chain_power_space -start_offset $PI_delay_chain_power_offset -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {VDD VSS} \
  -layer M7 -direction vertical -width $AVDD_M7_width -spacing [expr 2*$AVDD_M7_space] -start_offset $DB_width -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

addStripe -nets {VDD VSS} \
  -layer M7 -direction vertical -width $AVDD_M7_width -spacing [expr 2*$AVDD_M7_space] -start_offset $DB_width -set_to_set_distance $FP_width -start_from right -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


addStripe -nets {VDD VSS} \
  -layer M8 -direction horizontal -width $DVDD_M8_width -spacing $DVDD_M8_space -start_offset $origin1_y -set_to_set_distance [expr 2*($DVDD_M8_width+$DVDD_M8_space)] -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M7 -use_wire_group 0 -snap_wire_center_to_grid None  -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


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

setEdit -layer_horizontal M4
setEdit -width_horizontal $PI_clk_in_M4_width
setEdit -layer_vertical M5
setEdit -width_vertical $PI_clk_in_M5_width

setEdit -nets $clk_in_net
editAddRoute $PI_clk_in_offset [expr $origin1_y-$cell_height]
editCommitRoute $PI_clk_in_offset [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height+2*$cell_height] 

setEdit -nets $clk_in_net
editAddRoute $PI_clk_in_offset [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height+1.5*$cell_height]
editCommitRoute [expr $origin1_x+$PI_delay_unit_width+$ff_pm_width] [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height+1.5*$cell_height] 




##--------------------------------------------
## IO file #
##--------------------------------------------
#loadIoFile ${ioDir}/${DesignName}.io


setPinAssignMode -pinEditInBatch true

editPin -pinWidth [expr 4*$pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 3 -layer 3 -spreadType start -spacing [expr $metal_space] -offsetStart [expr $origin1_x+$PI_delay_unit_width/2] -pin {clk_in}

editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 3 -layer 3 -spreadType start -spacing [expr 16*$metal_space] -offsetStart [expr $origin1_x-3] -pin {clk_cdr en_delay en_arb }

editPin -pinWidth [expr $pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 3 -layer 3 -spreadType start -spacing [expr 16*$metal_space] -offsetStart [expr $origin1_x+$PI_delay_unit_width+3] -pin {en_gf en_cal cal_out cal_out_dmm}


editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 0 -layer 2 -spreadType start -spacing [expr 4*$metal_space] -offsetStart [expr $boundary_height+$cell_height] -pin {pm_out* en_pm sel_pm* clk_async ctl_dcdl* disable_state rstb del_out en_clk_sw} 

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -spreadDirection counterclockwise -edge 0 -layer 2 -spreadType range -offsetEnd [expr $origin1_y] -offsetStart [expr $FP_height-($origin1_y+$delay_Nunit*$PI_delay_unit_height)] -pin {inc_del* } 

editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -spreadDirection counterclockwise -edge 0 -layer 2 -spreadType range -offsetEnd [expr $origin1_y] -offsetStart [expr $FP_height-($origin1_y+$delay_Nunit*$PI_delay_unit_height)] -pin {*Qperi* max_sel_mux* ctl[* } 


editPin -pinWidth [expr 4*$pin_width] -pinDepth $pin_depth -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 4 -spreadType start -spacing [expr 16*$metal_space] -offsetStart [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height] -pin {clk_out_slice clk_out_sw }



saveIoFile -locations ${ioDir}/${DesignName}.io


createRouteBlk -box [expr $origin1_x] [expr $origin1_y] [expr $origin1_x+$PI_delay_unit_width] [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height] -layer {5 7 8}
#createRouteBlk -box [expr $origin1_x] [expr $origin1_y+$cell_height] [expr $origin1_x+$PI_delay_unit_width] [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height-$cell_height] -layer {3 5}

placeInstance iPM/iPM_sub/ff_ref_reg/Q_reg [expr $origin1_x+$PI_delay_unit_width] [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height] R180
placeInstance iPM/iPM_sub/ff_in_reg/Q_reg [expr $origin1_x+$PI_delay_unit_width+$ff_pm_width] [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height] 
placeInstance iPM/iPM_sub/uXOR1/U1 [expr $origin1_x+$PI_delay_unit_width+$ff_pm_width-$xor_pm_width] [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height+$cell_height] 
placeInstance iPM/iPM_sub/uXOR0/U1 [expr $origin1_x+$PI_delay_unit_width+$ff_pm_width] [expr $origin1_y+$delay_Nunit*$PI_delay_unit_height+$cell_height] MY 


##-----------------------
# analog routes
##-----------------------
routeMixedSignal -constraintFile ${scrDir}/floorplan/${DesignName}_MS_routes.tcl -deleteExistingRoutes


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

#saveDesign ${saveDir}/${vars(db_name)}.enc










