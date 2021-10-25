
############ CS array info
set Ncs 32
set CS_array_width 8 
set CS_array_height 4

set blockage_width 0.45
set sw_routing_space 0.5
#set margin_width 10

set skewed_inv_area [get_property [get_cells iinv_skewed] area]
set skewed_inv_width [expr round($skewed_inv_area/$cell_height/$cell_grid)*$cell_grid]

set boundary_width [expr $DB_width+$welltap_width]
set boundary_height 2*$cell_height

set origin1_x [expr $boundary_width+$DB_width+$blockage_width+$CS_cell_dmm_width]
set origin1_y [expr $cell_height]

set origin2_x [expr $origin1_x+$sw_routing_space]

set group1_width [expr $CS_array_width*$CS_cell_width] 
set group1_height [expr $CS_array_height*$CS_cell_height] 
set group2_width [expr 3*$SW_width+$MOMcap_width] 
set group2_height [expr $SW_height] 
set group3_width [expr 2*$SW_width+$MOMcap_width] 
set group3_height [expr $SW_height] 



##############
# Floor Plan #
##############
set FP_height [expr 2*$SW_height+$CS_array_height*$CS_cell_height+2*$boundary_height+2*$cell_height]
set FP_width [expr ceil([expr ($origin2_x+$group3_width+7*$M9_width+6*$M9_space+$DB_width)/$cell_grid])*$cell_grid ]

floorPlan -site core -s $FP_width $FP_height 0 0 0 0 

#################
# pre placement #
#################

############# CS cells
for { set k 0} {$k < 2*$CS_array_height} {incr k} {
	set x_cor [expr $origin1_x-$CS_cell_dmm_width+floor(double($k)/$CS_array_height)*(($CS_array_width*$CS_cell_width)+$CS_cell_dmm_width)]
	set y_cor [expr {$origin1_y+($k%$CS_array_height)*$CS_cell_height}] 
	placeInstance ICSdmm_dont_touch_$k\_ $x_cor $y_cor
	if { $k>[expr $CS_array_height-1]} {
		dbSet [dbGet top.insts.name -p ICSdmm_dont_touch_$k\_].orient MY
	}
}

for { set k 0} {$k < $Ncs} {incr k} {
	set x_cor [expr {$origin1_x+($k%int($CS_array_width))*$CS_cell_width}] 
	set y [expr {double($k)/$CS_array_width}]
	set y_cor [expr $origin1_y+floor($y)*$CS_cell_height]
	placeInstance ICS_dont_touch_$k\_ $x_cor $y_cor
#	if { [expr int(floor($y))%2] ==1 } {
#		dbSet [dbGet top.insts.name -p I107_$k].orient MX
#	}
}


########## SW and MOMcap
set origin2_y [expr $y_cor+$CS_cell_height+$cell_height] 

placeInstance ISW1 [expr {$origin2_x}] [expr $origin2_y]
placeInstance ISW2 [expr {$origin2_x}]  [expr $origin2_y+$SW_height]

placeInstance IMOM [expr {$origin2_x+$SW_width}] [expr $origin2_y]

placeInstance ISW3 [expr {$origin2_x+$SW_width+$MOMcap_width}]  [expr $origin2_y] 
placeInstance ISW4 [expr {$origin2_x+2*$SW_width+$MOMcap_width}]  [expr $origin2_y] 

placeInstance ISW5 [expr {$origin2_x+$SW_width+$MOMcap_width}]  [expr $origin2_y+$SW_height] 

dbSet [dbGet top.insts.name -p ISW2].orient MX
dbSet [dbGet top.insts.name -p ISW4].orient MY
dbSet [dbGet top.insts.name -p ISW5].orient MX





######################
# placement blockage #
######################

createPlaceBlockage -box [expr $origin1_x-$CS_cell_dmm_width-$blockage_width] [expr $origin1_y-$cell_height] [expr $origin1_x+$group1_width+$CS_cell_dmm_width+$blockage_width] [expr $origin1_y+$group1_height+$cell_height] -type hard
createPlaceBlockage -box [expr $origin2_x-$blockage_width] [expr $origin2_y-$cell_height] [expr $origin2_x+$group2_width+$blockage_width] [expr $origin2_y+$group2_height+$cell_height] -type hard
createPlaceBlockage -box [expr $origin2_x-$blockage_width] [expr $origin2_y+$SW_height] [expr $origin2_x+$group3_width+$blockage_width] [expr $origin2_y+$group2_height+$group3_height+$cell_height] -type hard


####################
## welltap settings# 
####################
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

############## M1 power for Vcal
globalNetConnect Vcal -type pgpin -pin VDD -inst * -override
globalNetConnect Vcal -type pgpin -pin VPP -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * 
globalNetConnect VSS -type pgpin -pin VBB -inst *





createPlaceBlockage -box 0 [expr $origin2_y-$cell_height] $FP_width $FP_height -type hard -name Vcal_place_blk1
createPlaceBlockage -box 0 0 $origin1_x $FP_height -type hard -name Vcal_place_blk2
createPlaceBlockage -box 0 0 $FP_width $cell_height -type hard -name Vcal_place_blk3
createRouteBlk -box 0 [expr $origin2_y] $FP_width $FP_height -layer M1 -name Vcal_route_blk1
createRouteBlk -box 0 0 [expr $origin1_x]  $FP_height -layer M1 -name Vcal_route_blk2




addWellTap -cell TAPCELLBWP16P90 -inRowOffset $FP_width -cellInterval $FP_width -prefix WELLTAP

addStripe -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -master "TAPCELL*"   \
  -merge_stripes_value 0.045   \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -nets {Vcal VSS} 

deleteInst WELL*
deleteRouteBlk -name Vcal*
deletePlaceBlockage Vcal*


############## M1 power for VDD
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VDD -type pgpin -pin VPP -inst * -override
globalNetConnect cs_drn -type pgpin -pin cs_drn -inst ICS* -override
globalNetConnect Vcal -type pgpin -pin Vbias -inst ICS* -override

addWellTap -cell TAPCELLBWP16P90 -cellInterval $FP_width -prefix WELLTAP


addStripe -pin_layer M1   \
  -over_pins 1   \
  -block_ring_top_layer_limit M1   \
  -max_same_layer_jog_length 3.6   \
  -padcore_ring_bottom_layer_limit M1   \
  -padcore_ring_top_layer_limit M1   \
  -spacing 1.8   \
  -master "TAPCELL* BOUNDARY*"   \
  -merge_stripes_value 0.045   \
  -extend_to design_boundary \
  -direction horizontal   \
  -layer M1   \
  -block_ring_bottom_layer_limit M1   \
  -width pin_width   \
  -nets {VSS VDD}

deleteInst WELL*

addEndCap
gui_select -rect [expr $FP_width -5] 0 [expr $FP_width] 5
deleteSelectedFromFPlan
addEndCap

addWellTap -cell TAPCELLBWP16P90 -cellInterval $FP_width -prefix WELLTAP
createPlaceBlockage -box 0 [expr $FP_height-2*$cell_height] $FP_width 0 -name welltap_blk
addWellTap -cell TAPCELLBWP16P90 -cellInterval $welltap_width -prefix WELLTAP 
deletePlaceBlockage welltap_blk

#globalNetConnect Vcal -type pgpin -pin VDD -inst IDCAP_Vcal* -override
#globalNetConnect Vcal -type pgpin -pin VPP -inst IDCAP_Vcal* -override


#set DCAP16_width 1.44
#for { set k 0} {$k < 8} {incr k} {
#	set x_cor [expr $FP_width-$DB_width-$welltap_width-7*$DCAP16_width]
#	set y_cor [expr $origin1_y+($k)*$cell_height] 
#	placeInstance IDCAP_Vcal0_$k\_ $x_cor $y_cor
#	if { $k%2 ==1} {
#		dbSet [dbGet top.insts.name -p IDCAP_Vcal0_$k\_].orient MX
#	}
#}

#for { set k 0} {$k < 8} {incr k} {
#	set x_cor [expr $FP_width-$DB_width-$welltap_width-6*$DCAP16_width]
#	set y_cor [expr $origin1_y+($k)*$cell_height] 
#	placeInstance IDCAP_Vcal1_$k\_ $x_cor $y_cor
#	if { $k%2 ==1} {
#		dbSet [dbGet top.insts.name -p IDCAP_Vcal1_$k\_].orient MX
#	}
#}

#for { set k 0} {$k < 8} {incr k} {
#	set x_cor [expr $FP_width-$DB_width-$welltap_width-4*$DCAP16_width]
#	set y_cor [expr $origin1_y+($k)*$cell_height] 
#	placeInstance IDCAP_Vcal2_$k\_ $x_cor $y_cor
#	if { $k%2 ==1} {
#		dbSet [dbGet top.insts.name -p IDCAP_Vcal2_$k\_].orient MX
#	}
#}
#########################
# place Analog Boundary #
#########################

#set NabY_CS  [expr $CS_array_height*$CS_cell_height/$cell_height]
#set NabY_SW  [expr 2*$SW_height/$cell_height]
#set NabY  [expr 3+$NabY_CS+$NabY_SW]
#set NabX  [expr floor(($FP_width-2*$boundary_width)/$AB_width)]

#set idx_AB 0
#set idx_DB 0

#for { set k 0} {$k < $NabY } {incr k} {
#	if { $k == 0 || $k == [expr $NabY_CS +1] || $k == [expr $NabY - 1] } {
#		placeInstance IdbR$idx_DB [expr $origin1_x-$AB_width-$DB_width ] [expr $origin1_y+($k-1)*$cell_height]
#		for { set j 0} {$j < [expr $NabX-2] } {incr j} {
#			placeInstance Iab$idx_AB [expr $origin1_x-$AB_width+$j*$AB_width ] [expr $origin1_y+($k-1)*$cell_height]
#		#	if { [expr $k%2] ==1 } {
#		#		dbSet [dbGet top.insts.name -p Iab$idx_AB].orient MX
#		#	}
#			set idx_AB [expr $idx_AB+1]
#		}
#		placeInstance IdbL$idx_DB [expr $origin1_x-$AB_width+($j)*$AB_width] [expr $origin1_y+($k-1)*$cell_height]
#		set idx_DB [expr $idx_DB+1]
#	} elseif { $k <= $NabY_CS } {
#		placeInstance IdbR$idx_DB [expr $origin1_x-$AB_width-$DB_width] [expr $origin1_y+($k-1)*$cell_height]
#		placeInstance Iab$idx_AB [expr $origin1_x-$AB_width] [expr $origin1_y+($k-1)*$cell_height]
#		#if { [expr $k%2] ==1 } {
#		#	dbSet [dbGet top.insts.name -p Iab$idx_AB].orient MX
#		#}
#		set idx_AB [expr $idx_AB+1]
#		placeInstance Iab$idx_AB [expr $origin1_x+($CS_array_width)*$CS_cell_width] [expr $origin1_y+($k-1)*$cell_height]
#		#if { [expr $k%2] ==1 } {
#		#dbSet [dbGet top.insts.name -p Iab$idx_AB].orient MX
#		#}
#		set idx_AB [expr $idx_AB+1]
#		placeInstance IdbL$idx_DB [expr $origin1_x+($CS_array_width)*$CS_cell_width+$AB_width] [expr $origin1_y+($k-1)*$cell_height]
#		set idx_DB [expr $idx_DB+1]
#	} else {
#		placeInstance IdbR$idx_DB [expr $origin2_x-$AB_width-$DB_width] [expr $origin1_y+($k-1)*$cell_height]
#		placeInstance Iab$idx_AB [expr $origin2_x-$AB_width] [expr $origin1_y+($k-1)*$cell_height]
#		#if { [expr $k%2] ==1 } {
#		#	dbSet [dbGet top.insts.name -p Iab$idx_AB].orient MX
#		#}
#		set idx_AB [expr $idx_AB+1]
#		placeInstance Iab$idx_AB [expr $origin2_x+3*$SW_width+$MOMcap_width] [expr $origin1_y+($k-1)*$cell_height]
#		#if { [expr $k%2] ==1 } {
#		#dbSet [dbGet top.insts.name -p Iab$idx_AB].orient MX
#		#}
#		set idx_AB [expr $idx_AB+1]
#		placeInstance IdbL$idx_DB [expr $origin2_x+3*$SW_width+$MOMcap_width+$AB_width] [expr $origin1_y+($k-1)*$cell_height]
#		set idx_DB [expr $idx_DB+1]
#	}
#}


#########
# Gourp #
#########
#createInstGroup grp0 
#addInstToInstGroup grp0 [list I24/I2 I24/I3 I23/I2 I23/I3 I42/I2 I42/I3 I117] 
#createFence grp0 2.34 5.48 16.0 11.5
#createInstGroup grp0 -region 5 45 10 20
#addInstToInstGroup grp0 I109
#createInstGroup grp1 -region 5 45 0 10
#addInstToInstGroup grp0 I20

#addInstToInstGroup grp0 [list I0/I137 I0/I119]
#createInstGroup grp1 -region 56 28.5 59 31
#addInstToInstGroup grp1 I0/I147
#createInstGroup grp2 -region 47.5 28 52.5 30
#addInstToInstGroup grp2 [list I0/I134 I0/I135 I0/I136]

#createInstGroup grp3 -region 3 30 6 31
#addInstToInstGroup grp3 I59
#createInstGroup grp4 -region 82 29 83 30
#addInstToInstGroup grp4 I0/I140
#createInstGroup grp5 -region 35 28 37 30
#addInstToInstGroup grp5 [list I0/I128 I0/I130 I0/I131 I0/I132]

################
# NDR settings #
################

add_ndr -name NDR_2W1S -spacing {M1:M2 0.032 M3 0.038 M4:M7 0.04} -width {M1:M2 0.064 M3 0.076 M4:M7 0.08} 
add_ndr -name NDR_3W3S -spacing {M1:M2 0.04 M3 0.12 M4:M7 0.12} -width {M1:M2 0.04 M3 0.12 M4:M7 0.12} 
add_ndr -name NDR_WIDE -spacing {M1:M2 0.2 M1 0.2 M4:M7 0.2 M8 0.2} -width {M1:M2 1 M1 1 M4:M7 1.2 M8 1.3} 

setAttribute -net Vin -non_default_rule NDR_WIDE
setAttribute -net Vcal -non_default_rule NDR_WIDE
setAttribute -net v2t_out -non_default_rule NDR_3W3S

foreach_in_collection i [get_nets *v2t*] {
        setAttribute -net [get_object_name $i] -non_default_rule NDR_3W3S
}


#########################
## Local  power strip #
#########################

addStripe -nets {VSS VDD} \
  -layer M2 -direction vertical -width 0.8 -spacing 0.3 -start_offset 0 -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M2 -block_ring_top_layer_limit M2 -block_ring_bottom_layer_limit M2 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1



#############
# pre route #
#############
uiSetTool addWire
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

setEdit -layer_vertical M3
setEdit -layer_horizontal M4

#setEdit -width_horizontal 1.6 
#editAddRoute 0 [expr 5*$cell_height]
#editCommitRoute [expr $origin1_x+0.1] [expr 5*$cell_height]

set Vcal_decap_power_hor [expr $CS_cell_height/2]
set Vcal_decap_power_ver $CS_cell_height

set Vin_M8_offset [expr $origin2_y+0.5*$SW_height]
#set Vin_M8_offset [get_property [get_pins ISW1/IN] y_coordinate]
set Vcal_M7_offset [expr $origin1_x+$group1_width+$CS_cell_dmm_width+$blockage_width]

## power routing for Vcal##
setEdit -nets Vcal
setEdit -width_horizontal $Vcal_decap_power_hor 
for {set k 0} {$k <($CS_array_height)} {incr k} {
	editAddRoute [expr $origin1_x+$group1_width] [expr $origin1_y+$CS_cell_height/2+$CS_cell_height*$k]
	editCommitRoute [expr $FP_width] [expr $origin1_y+$CS_cell_height/2+$CS_cell_height*$k]
}	


setEdit -width_vertical $Vcal_decap_power_ver
set Nstrip [expr floor(($FP_width-$DB_width-($origin1_x+$group1_width+$blockage_width+$CS_cell_dmm_width+$DB_width))/(2*$Vcal_decap_power_ver))] 
for {set k 0} {$k < $Nstrip} {incr k} {
	editAddRoute [expr $origin1_x+$group1_width+$blockage_width+$CS_cell_dmm_width+$DB_width+$Vcal_decap_power_ver/2+2*$Vcal_decap_power_ver*$k] $cell_height
	editCommitRoute [expr $origin1_x+$group1_width+$blockage_width+$CS_cell_dmm_width+$DB_width+$Vcal_decap_power_ver/2+2*$Vcal_decap_power_ver*$k] [expr $origin1_y+$CS_array_height*$CS_cell_height]
}	

## Vcal M7
addStripe -nets {Vcal Vcal Vcal} \
  -layer M7 -direction vertical -width $AVDD_M7_width -spacing $AVDD_M7_space -start_offset $Vcal_M7_offset -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit M7 -padcore_ring_bottom_layer_limit M4 -block_ring_top_layer_limit M1 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


########### skewed inverter
set skewed_inv_x [expr ceil(($Vcal_M7_offset-1)/$cell_grid)*$cell_grid]
set skewed_inv_y [expr $origin2_y+$SW_height]
placeInstance iinv_skewed/U1 $skewed_inv_x $skewed_inv_y



##--------------------------------------------
# power routing
##--------------------------------------------
set AVSS_M7_offset [expr  $Vcal_M7_offset+3*$AVDD_M7_width+3*$AVDD_M7_space+$skewed_inv_width] 

#M7 (VDD)
addStripe -nets {VSS VDD} \
  -layer M7 -direction vertical -width $AVDD_M7_width -spacing $AVDD_M7_space -start_offset $AVSS_M7_offset -set_to_set_distance [expr 2*($AVDD_M7_width+$AVDD_M7_space)] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit M7 -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M1 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


#M8 (VDD)
#createRouteBlk -box 0 0 [expr $origin2_x+$group3_width-$SW_width/2] [expr $origin2_y+2*$SW_height] -layer M8 -name M8_blk1
#createRouteBlk -box 0 [expr $origin2_y+2*$SW_height] $FP_width $FP_height -layer M8 -name M8_blk2
createRouteBlk -box 0 0 [expr $origin2_x+$group3_width-$SW_width/2] $FP_height -layer M8 -name M8_blk1

#set AVDD_M8_offset [expr $FP_height-[get_property [get_pins ISW5/IN] y_coordinate]-$AVDD_M8_width/2]
set AVDD_M8_offset [expr $FP_height-($origin2_y+1.5*$SW_height)-$AVDD_M8_width/2]




createRouteBlk -box [expr $origin2_x+$group3_width-$SW_width/2] 0 $FP_width $FP_height -layer M6  

addStripe -nets {VDD VSS} \
  -layer M8 -direction horizontal -width $AVDD_M8_width -spacing $AVDD_M8_space -start_offset [expr $AVDD_M8_offset] -set_to_set_distance [expr 2*($AVDD_M8_width+$AVDD_M8_space)] -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit M7 -padcore_ring_bottom_layer_limit M7 -block_ring_top_layer_limit M7 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -create_pins 1  -skip_via_on_wire_shape {  noshape }  

deleteRouteBlk -name  M8_blk1

addStripe -nets {VDD} \
  -layer M8 -direction horizontal -width $AVDD_M8_width -spacing $AVDD_M8_space -start_offset $cell_height -set_to_set_distance $FP_height -start_from top -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit M8 -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit M1 -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -create_pins 1 -extend_to design_boundary


setEdit -layer_vertical M7
setEdit -width_vertical $SW_pin_width
setEdit -layer_horizontal M8
setEdit -width_horizontal $SW_pin_length


setEdit -nets vch
editAddRoute [expr $origin2_x+$SW_width-($SW_pin_depth-$SW_pin_width/2)] [expr $origin2_y+$SW_height/2]
editCommitRoute [expr $origin2_x+$SW_width-($SW_pin_depth-$SW_pin_width/2)] [expr $origin2_y+3*$SW_height/2]

setEdit -nets vdch
editAddRoute [expr $origin2_x+$SW_width+$MOMcap_width+($SW_pin_depth-$SW_pin_width/2)] [expr $origin2_y+$SW_height/2]
editCommitRoute [expr $origin2_x+$SW_width+$MOMcap_width+($SW_pin_depth-$SW_pin_width/2)] [expr $origin2_y+3*$SW_height/2]

## switch ground
setEdit -nets VSS
editAddRoute 0 [expr $origin2_y+1.5*$SW_height-$SW_pin_width/2]
editCommitRoute [expr $origin2_x+$SW_pin_depth]  [expr $origin2_y+1.5*$SW_height-$SW_pin_width/2]

## Vin
setEdit -nets Vin
editAddRoute 0 $Vin_M8_offset
editCommitRoute [expr $origin2_x+$SW_pin_depth] $Vin_M8_offset



## switch VDD
setEdit -width_vertical [expr 2*$SW_pin_depth]
setEdit -nets VDD
editAddRoute [expr $origin2_x+2*$SW_width+$MOMcap_width-$SW_pin_depth/2] [expr $origin2_y+$SW_height+$cell_height]
editCommitRoute [expr $origin2_x+2*$SW_width+$MOMcap_width-$SW_pin_depth/2] [expr $FP_height-$cell_height]
editAddRoute [expr $origin2_x+$group2_width-$SW_pin_depth+$SW_pin_width/2] [expr $origin2_y+2*$SW_height]
editCommitRoute [expr $origin2_x+$group2_width-$SW_pin_depth+$SW_pin_width/2]  [expr $origin2_y+$cell_height]



deleteRouteBlk -all

## drain node of currnet source
setEdit -nets cs_drn
editAddRoute [expr $origin2_x+2*$SW_width+$MOMcap_width] [expr $origin2_y+$SW_height-$cell_height]
editCommitRoute [expr $origin2_x+2*$SW_width+$MOMcap_width] [expr $boundary_height-$cell_height]



## routing for Vch/Vdch
setEdit -layer_vertical M5
setEdit -width_vertical $MOMcap_pin_width 
setEdit -layer_horizontal M6
setEdit -width_horizontal [expr $MOMcap_pin_width/2]

setEdit -nets vch
editAddRoute [expr $origin2_x+$SW_width-$SW_pin_depth] [expr $origin2_y+$SW_height]
editCommitRoute [expr $origin2_x+$SW_width+$MOMcap_pin_depth] [expr $origin2_y+$SW_height]
setEdit -nets vdch
editAddRoute [expr $origin2_x+$SW_width+$MOMcap_width-$MOMcap_pin_depth] [expr $origin2_y+$SW_height]
editCommitRoute [expr $skewed_inv_x] [expr $origin2_y+$SW_height]








#M9 (VDD)
set AVSS_M9_offset $DB_width
set AVDD_M9_offset [expr $origin2_x+$group3_width]

createRouteBlk -box 0 0 $FP_width $FP_height -layer M7 

addStripe -nets {VSS} \
  -layer M9 -direction vertical -width $M9_width -spacing $M9_space -start_offset $AVSS_M9_offset -set_to_set_distance $FP_width -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1


addStripe -nets {VDD VSS} \
  -layer M9 -direction vertical -width $M9_width -spacing $M9_space -start_offset $AVDD_M9_offset -set_to_set_distance [expr 2*($M9_width+$M9_space)] -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M9 -block_ring_top_layer_limit M9 -block_ring_bottom_layer_limit M9 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {  noshape } -extend_to design_boundary -create_pins 1

deleteRouteBlk -all







##--------------------------------------------
# Load IO file #
##--------------------------------------------
#loadIoFile ${ioDir}/${DesignName}.io

set in_pin_list "ctl[0]"
for { set k 1} {$k < $Ncs} {incr k} {
    lappend in_pin_list "ctl[$k]"
}
setPinAssignMode -pinEditInBatch true
editPin -pinWidth $pin_width -pinDepth $pin_depth -fixOverlap 1 -spreadDirection counterclockwise -edge 2 -layer 2 -spreadType range -offsetEnd [expr $FP_height-($skewed_inv_y-2*$cell_height)] -offsetStart $cell_height -pin $in_pin_list

editPin -pinWidth [expr 3*$pin_width] -pinDepth $welltap_width -fixOverlap 0 -unit MICRON -spreadDirection counterclockwise -edge 2 -layer 4 -spreadType start -spacing $metal_space -offsetStart [expr $skewed_inv_y+$cell_height/2] -pin v2t_out

editPin -pinWidth $SW_pin_length -pinDepth $welltap_width -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 0 -layer 8 -spreadType start -spacing $metal_space -offsetStart [expr $Vin_M8_offset] -pin Vin


set V2T_clk_pin_offset1 [expr $origin2_x-2*$DB_width]
set V2T_clk_pin_offset2 [expr $origin2_x+$MOMcap_width+$SW_width-$DB_width]

editPin -pinWidth [expr 3*$pin_width] -pinDepth [expr 2*$pin_depth] -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 1 -layer 5 -spreadType start -spacing [expr $SW_width/3] -offsetStart $V2T_clk_pin_offset1 -pin {clk_v2tb clk_v2t clk_v2tb_gated clk_v2t_gated}

editPin -pinWidth [expr 3*$pin_width] -pinDepth [expr 2*$pin_depth] -fixOverlap 0 -unit MICRON -spreadDirection clockwise -edge 1 -layer 5 -spreadType start -spacing [expr $SW_width/3] -offsetStart $V2T_clk_pin_offset2 -pin {clk_v2t_eb clk_v2t_e clk_v2t_lb clk_v2t_l}


saveIoFile -locations ${ioDir}/${DesignName}.io


##-----------------------
# analog routes
##-----------------------
routeMixedSignal -constraintFile ${scrDir}/floorplan/${DesignName}_MS_routes.tcl -deleteExistingRoutes



##------------------------------------------------------
set_dont_touch [get_nets {mid* *out* Vdch}]
set RUN_LAYOUT_ONLY 0
##------------------------------------------------------

###########################
## pnr variable file-out ##
###########################
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "${DesignName}_width:$FP_width\n"
puts -nonewline $fid "${DesignName}_height:$FP_height\n"
puts -nonewline $fid "Vin_M8_offset:$Vin_M8_offset\n"
puts -nonewline $fid "Vcal_M7_offset:$Vcal_M7_offset\n"
puts -nonewline $fid "AVSS_M7_offset:$AVSS_M7_offset\n"
puts -nonewline $fid "AVSS_M9_offset:$AVSS_M9_offset\n"
puts -nonewline $fid "AVDD_M9_offset:$AVDD_M9_offset\n"
puts -nonewline $fid "V2T_clk_pin_offset1:$V2T_clk_pin_offset1\n"
puts -nonewline $fid "V2T_clk_pin_offset2:$V2T_clk_pin_offset2\n"
close $fid

saveDesign ${saveDir}/${vars(db_name)}.enc










