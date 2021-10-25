
#############################
## routing tree generation ##
#############################

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

set rx_in_RDL_width 10.0

set rx_in_width 5.0
set rx_in_tap1_width 2.0
set rx_in_tap2_width 1.0
set rx_in_tap3_width 1.0

set rx_in_space 10.0
set rx_in_tap1_space 2.0
set rx_in_tap2_space 1.0
set rx_in_tap3_space 1.0

set clk_width_0 1.0
set clk_width_1 0.4
set clk_width_2 0.4
set clk_width_3 0.12

set clk_space_1 0.2
set clk_space_2 0.1

set x_center [expr $FP_width/2]
set y_center [expr $origin1_y+4*$stochastic_adc_PR_height]

set x1p [expr $x_center-$routing_width_center/2-$phase_interpolator_width-2*$rx_in_tap1_width-$rx_in_tap1_space+$rx_in_tap1_width/2]
set x3p [expr $origin1_x+$stochastic_adc_PR_width+3]
set x2p [expr $x3p+$rx_in_tap3_width/2+$rx_in_tap3_space+$rx_in_tap3_width+$rx_in_tap2_space+$rx_in_tap2_width/2+3]

set x1n [expr $x1p+$rx_in_tap1_width+$rx_in_tap1_space]
set x3n [expr $x3p+$rx_in_tap3_width+$rx_in_tap3_space]
set x2n [expr $x2p+$rx_in_tap2_width+$rx_in_tap2_space]

set routing_extend [expr 4*$cell_height] 

#set VinP_M8_offset 7.99
#set VinN_M8_offset 31.03
set V2T_clk_offset [expr $stochastic_adc_PR_height/2]
set PI_clk_offset 9.62
set term_input_offset 15.82


#################### Signal Tree ####################
## (main strip from termination)

setEdit -layer_horizontal M9
setEdit -layer_vertical M9
setEdit -width_vertical $rx_in_width
setEdit -width_horizontal $rx_in_width

setEdit -nets rx_inp

editAddRoute [expr $x_center-$term_input_offset-$rx_in_width/2] [expr $FP_height-$boundary_height-$biasgen_height-$stochastic_adc_PR_height]
editCommitRoute [expr $x_center-$term_input_offset-$rx_in_width/2] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height]
editAddRoute [expr $x_center-$rx_in_space/2] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height]
editCommitRoute [expr $x_center-$term_input_offset-$rx_in_width/2] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height]
editAddRoute [expr $x_center-$rx_in_space/2] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height] 
editCommitRoute [expr $x_center-$rx_in_space/2]  [expr $origin2_y+$phase_interpolator_height]


setEdit -nets rx_inn
editAddRoute [expr $x_center+$term_input_offset+$rx_in_width/2] [expr $FP_height-$boundary_height-$biasgen_height-$stochastic_adc_PR_height]
editCommitRoute [expr $x_center+$term_input_offset+$rx_in_width/2] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height]
editAddRoute [expr $x_center+$rx_in_space/2] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height]
editCommitRoute [expr $x_center+$term_input_offset+$rx_in_width/2] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height]
editAddRoute [expr $x_center+$rx_in_space/2] [expr $FP_height-$boundary_height-$biasgen_height-1.5*$stochastic_adc_PR_height] 
editCommitRoute [expr $x_center+$rx_in_space/2]  [expr $origin2_y+$phase_interpolator_height]

setEdit -layer_horizontal M8
setEdit -nets rx_inp
editAddRoute [expr $x1p-$rx_in_tap1_width/2] [expr $y_center+2*$routing_extend]
editCommitRoute [expr $FP_width-$x1p+$rx_in_tap1_width/2] [expr $y_center+2*$routing_extend]
setEdit -nets rx_inn
editAddRoute [expr $x1p-$rx_in_tap1_width/2] [expr $y_center-2*$routing_extend]
editCommitRoute [expr $FP_width-$x1p+$rx_in_tap1_width/2] [expr $y_center-2*$routing_extend]



# (1st tapered distribution : before SnH)#
setEdit -width_vertical $rx_in_tap1_width
setEdit -width_horizontal $SW_pin_length

setEdit -nets rx_inp
editAddRoute [expr $x1p] [expr $y_center+(2*$stochastic_adc_PR_height+2*$routing_extend)]
editCommitRoute [expr $x1p] [expr $y_center-(2*$stochastic_adc_PR_height+2*$routing_extend)]
editAddRoute [expr $FP_width-($x1p)] [expr $y_center+(2*$stochastic_adc_PR_height+2*$routing_extend)]
editCommitRoute [expr $FP_width-($x1p)] [expr $y_center-(2*$stochastic_adc_PR_height+2*$routing_extend)]

setEdit -nets rx_inn
editAddRoute [expr $x1n] [expr $y_center+(2*$stochastic_adc_PR_height+2*$routing_extend)]
editCommitRoute [expr $x1n] [expr $y_center-(2*$stochastic_adc_PR_height+2*$routing_extend)]
editAddRoute [expr $FP_width-($x1n)] [expr $y_center+(2*$stochastic_adc_PR_height+2*$routing_extend)]
editCommitRoute [expr $FP_width-($x1n)] [expr $y_center-(2*$stochastic_adc_PR_height+2*$routing_extend)]


setEdit -nets rx_inp
for { set k 0} {$k < $Nti/4} {incr k} {
	 if {$k < [expr $Nti/8]} {
		set x_cor [expr $x1n+$rx_in_tap1_width/2]
		set y_cor [expr $origin1_y+(4*$k+2)*$stochastic_adc_PR_height+$SW_height/2+$cell_height]
		editAddRoute [expr $x_cor] $y_cor
		editCommitRoute [expr $x_cor-2*$rx_in_tap1_width-$rx_in_tap1_space-1] $y_cor
	} else {
		set x_cor [expr $FP_width-($x1n+$rx_in_tap1_width/2)]
		set y_cor [expr $origin1_y+($Nti-4*($k+1)+2)*$stochastic_adc_PR_height+$SW_height/2+$cell_height]
		editAddRoute [expr $x_cor] $y_cor
		editCommitRoute [expr $x_cor+2*$rx_in_tap1_width+$rx_in_tap1_space+1] $y_cor
	}
}
setEdit -nets rx_inn
for { set k 0} {$k < $Nti/4} {incr k} {
	 if {$k < [expr $Nti/8]} {
		set x_cor [expr $x1n+$rx_in_tap1_width/2]
		set y_cor [expr $origin1_y+(4*$k+2)*$stochastic_adc_PR_height-$SW_height/2-$cell_height]
		editAddRoute [expr $x_cor] $y_cor
		editCommitRoute [expr $x_cor-2*$rx_in_tap1_width-$rx_in_tap1_space-1] $y_cor
	} else {
		set x_cor [expr $FP_width-($x1n+$rx_in_tap1_width/2)]
		set y_cor [expr $origin1_y+($Nti-4*($k+1)+2)*$stochastic_adc_PR_height-$SW_height/2-$cell_height]
		editAddRoute [expr $x_cor] $y_cor
		editCommitRoute [expr $x_cor+2*$rx_in_tap1_width+$rx_in_tap1_space+1] $y_cor
	}
}

# (2nd signal distribution : after SnH)#
for { set k 0} {$k < $Nti/4} {incr k} {
setEdit -nets vinp_slice[$k]
	 if {$k < [expr $Nti/8]} {
		set x_cor [expr $x2p-$rx_in_tap2_width/2]
		set y_cor [expr $origin1_y+(4*$k+2)*$stochastic_adc_PR_height+$SW_height/2+$cell_height]
		editAddRoute [expr $x_cor] $y_cor
		editCommitRoute [expr $x_cor+2*$rx_in_tap2_width+$rx_in_tap2_space+3.3] $y_cor
	} else {
		set x_cor [expr $FP_width-($x2p-$rx_in_tap2_width/2)]
		set y_cor [expr $origin1_y+($Nti-4*($k+1)+2)*$stochastic_adc_PR_height+$SW_height/2+$cell_height]
		editAddRoute [expr $x_cor] $y_cor
		editCommitRoute [expr $x_cor-(2*$rx_in_tap2_width+$rx_in_tap2_space+3.3)] $y_cor
	}
}


for { set k 0} {$k < $Nti/4} {incr k} {
setEdit -nets vinn_slice[$k]
	 if {$k < [expr $Nti/8]} {
		set x_cor [expr $x2p-$rx_in_tap2_width/2]
		set y_cor [expr $origin1_y+(4*$k+2)*$stochastic_adc_PR_height-$SW_height/2-$cell_height]
		editAddRoute [expr $x_cor] $y_cor
		editCommitRoute [expr $x_cor+2*$rx_in_tap2_width+$rx_in_tap2_space+3.3] $y_cor
	} else {
		set x_cor [expr $FP_width-($x2p-$rx_in_tap2_width/2)]
		set y_cor [expr $origin1_y+($Nti-4*($k+1)+2)*$stochastic_adc_PR_height-$SW_height/2-$cell_height]
		editAddRoute [expr $x_cor] $y_cor
		editCommitRoute [expr $x_cor-(2*$rx_in_tap2_width+$rx_in_tap2_space+3.3)] $y_cor
	}
}


setEdit -width_horizontal $rx_in_tap2_width
setEdit -width_vertical $rx_in_tap2_width

for { set k 0} {$k < $Nti/4} {incr k} {
	setEdit -nets vinp_slice[$k]
	 if {$k < [expr $Nti/8]} {
		set x_cor [expr $x2p]
		set y_cor [expr $origin1_y+(4*$k+1)*$stochastic_adc_PR_height-4*$cell_height]
		editAddRoute [expr $x_cor] $y_cor
		editCommitRoute [expr $x_cor] [expr $y_cor+2*$stochastic_adc_PR_height+8*$cell_height]
	} else {
		set x_cor [expr $FP_width-($x2p)]
		set y_cor [expr $origin1_y+($Nti-4*$k-1)*$stochastic_adc_PR_height+4*$cell_height]
		editAddRoute $x_cor $y_cor
		editCommitRoute [expr $x_cor] [expr $y_cor-2*$stochastic_adc_PR_height-8*$cell_height]
	}
}
for { set k 0} {$k < $Nti/4} {incr k} {
	setEdit -nets vinn_slice[$k]
	 if {$k < [expr $Nti/8]} {
		set x_cor [expr $x2n]
		set y_cor [expr $origin1_y+(4*$k+1)*$stochastic_adc_PR_height-4*$cell_height]
		editAddRoute [expr $x_cor] $y_cor
		editCommitRoute [expr $x_cor] [expr $y_cor+2*$stochastic_adc_PR_height+8*$cell_height]
	} else {
		set x_cor [expr $FP_width-($x2n)]
		set y_cor [expr $origin1_y+($Nti-4*$k-1)*$stochastic_adc_PR_height+4*$cell_height]
		editAddRoute $x_cor $y_cor
		editCommitRoute [expr $x_cor] [expr $y_cor-2*$stochastic_adc_PR_height-8*$cell_height]
	}
}


for { set k 0} {$k < $Nti/2} {incr k} {
	setEdit -nets vinp_slice[[expr int(floor(double($k)/2))]]
	 if {$k < [expr $Nti/4]} {
		set x_cor [expr $x3p]
		set y_cor [expr $origin1_y+(2*$k+1)*$stochastic_adc_PR_height+2*$cell_height]
		editAddRoute [expr $x_cor] $y_cor
		editCommitRoute [expr $x2n+$rx_in_tap2_width/2] $y_cor
	} else {
		set x_cor [expr $FP_width-($x3p)]
		set y_cor [expr $origin1_y+($Nti-2*$k-1)*$stochastic_adc_PR_height+2*$cell_height]
		editAddRoute $x_cor $y_cor
		editCommitRoute [expr $FP_width-($x2n+$rx_in_tap2_width)] $y_cor
	}
}

for { set k 0} {$k < $Nti/2} {incr k} {
	setEdit -nets vinn_slice[[expr int(floor(double($k)/2))]]
	 if {$k < [expr $Nti/4]} {
		set x_cor [expr $x3p]
		set y_cor [expr $origin1_y+(2*$k+1)*$stochastic_adc_PR_height-2*$cell_height]
		editAddRoute [expr $x_cor] $y_cor
		editCommitRoute [expr $x2n+$rx_in_tap2_width/2] $y_cor
	} else {
		set x_cor [expr $FP_width-($x3p)]
		set y_cor [expr $origin1_y+($Nti-2*$k-1)*$stochastic_adc_PR_height-2*$cell_height]
		editAddRoute $x_cor $y_cor
		editCommitRoute [expr $FP_width-($x2n+$rx_in_tap2_width)] $y_cor
	}
}

# (3rd signal distribution : after SnH)#
setEdit -width_vertical $rx_in_tap3_width
setEdit -width_horizontal $SW_pin_length


for { set k 0} {$k < $Nti/2} {incr k} {
	setEdit -nets vinp_slice[[expr int(floor(double($k)/2))]]
	 if {$k < [expr $Nti/4]} {
		set x_cor [expr $x3p+$rx_in_tap3_width/2]
		set y_cor [expr $origin1_y+(2*$k)*$stochastic_adc_PR_height+$VinP_M8_offset-$SW_pin_length]
		editAddRoute $x_cor $y_cor
		editCommitRoute $x_cor [expr $origin1_y+(2*$k+1)*$stochastic_adc_PR_height+$VinN_M8_offset+$SW_pin_length]
	} else {
		set x_cor [expr $FP_width-($x3p+$rx_in_tap3_width/2)]
		set y_cor [expr $origin1_y+($Nti-2*$k-1)*$stochastic_adc_PR_height+$VinN_M8_offset+$SW_pin_length]
		editAddRoute $x_cor $y_cor
		editCommitRoute $x_cor [expr $origin1_y+($Nti-2*$k-2)*$stochastic_adc_PR_height+$VinP_M8_offset-$SW_pin_length]
	}
}


for { set k 0} {$k < $Nti/2} {incr k} {
	setEdit -nets vinn_slice[[expr int(floor(double($k)/2))]]
	 if {$k < [expr $Nti/4]} {
		set x_cor [expr $x3n]
		set y_cor [expr $origin1_y+(2*$k)*$stochastic_adc_PR_height+$VinP_M8_offset-$SW_pin_length]
		editAddRoute $x_cor $y_cor
		editCommitRoute $x_cor [expr $origin1_y+(2*$k+1)*$stochastic_adc_PR_height+$VinN_M8_offset+$SW_pin_length]
	} else {
		set x_cor [expr $FP_width-($x3n)]
		set y_cor [expr $origin1_y+($Nti-2*$k-1)*$stochastic_adc_PR_height+$VinN_M8_offset+$SW_pin_length]
		editAddRoute $x_cor $y_cor
		editCommitRoute $x_cor [expr $origin1_y+($Nti-2*$k-2)*$stochastic_adc_PR_height+$VinP_M8_offset-$SW_pin_length]
	}
}



for { set k 0} {$k < $Nti} {incr k} {
	setEdit -nets vinp_slice[[expr int(floor(double($k)/4))]]
	 if {$k < [expr $Nti/2]} {
		set x_cor [expr $origin1_x+$stochastic_adc_PR_width-$rx_in_tap3_width]
		set y_cor [expr $origin1_y+($k)*$stochastic_adc_PR_height+$VinP_M8_offset+$SW_pin_length/2]
		editAddRoute $x_cor $y_cor
		editCommitRoute [expr $x3n+$rx_in_tap3_width] $y_cor
	} else {
		set x_cor [expr $FP_width-($origin1_x+$stochastic_adc_PR_width-$rx_in_tap3_width)]
		set y_cor [expr $origin1_y+($Nti-$k-1)*$stochastic_adc_PR_height+$VinP_M8_offset+$SW_pin_length/2]
		editAddRoute $x_cor $y_cor
		editCommitRoute [expr $FP_width-($x3n+$rx_in_tap3_width)] $y_cor
	}
}

for { set k 0} {$k < $Nti} {incr k} {
	setEdit -nets vinn_slice[[expr int(floor(double($k)/4))]]
	 if {$k < [expr $Nti/2]} {
		set x_cor [expr $origin1_x+$stochastic_adc_PR_width-$rx_in_tap3_width]
		set y_cor [expr $origin1_y+($k)*$stochastic_adc_PR_height+$VinN_M8_offset+$rx_in_tap3_width/2]
		editAddRoute $x_cor $y_cor
		editCommitRoute [expr $x3n+$rx_in_tap3_width] $y_cor
	} else {
		set x_cor [expr $FP_width-($origin1_x+$stochastic_adc_PR_width-$rx_in_tap3_width)]
		set y_cor [expr $origin1_y+($Nti-$k-1)*$stochastic_adc_PR_height+$VinN_M8_offset+$rx_in_tap3_width/2]
		editAddRoute $x_cor $y_cor
		editCommitRoute [expr $FP_width-($x3n+$rx_in_tap3_width)] $y_cor
	}
}



#################### Clock Tree ####################
if 0 {
## (Clock input from input buffer )
setEdit -layer_horizontal M4
setEdit -layer_vertical M5
#setEdit -width_horizontal $clk_width_0
#setEdit -width_vertical $clk_width_0

#setEdit -nets clk_in_pi
#editAddRoute [expr $x_center] 0
#editCommitRoute [expr $x_center] [expr $origin1_y+4*$stochastic_adc_PR_height+$clk_width_0/2]
#editAddRoute [expr $x1n+$phase_interpolator_width/2] [expr $origin1_y+4*$stochastic_adc_PR_height]
#editCommitRoute [expr $FP_width-($x1n+$phase_interpolator_width/2)] [expr $origin1_y+4*$stochastic_adc_PR_height]

#setEdit -width_vertical 0.6
#editAddRoute [expr $x_center-$routing_width_center/2-$PI_clk_offset-0.66] [expr $y_center-17*$cell_height]
#editCommitRoute [expr $x_center-$routing_width_center/2-$PI_clk_offset-0.66] [expr $y_center+17*$cell_height]

#editAddRoute [expr $FP_width-($x_center-$routing_width_center/2-$PI_clk_offset-0.66)] [expr $y_center-17*$cell_height]
#editCommitRoute [expr $FP_width-($x_center-$routing_width_center/2-$PI_clk_offset-0.66)] [expr $y_center+17*$cell_height]


## (Clock from PIs )
setEdit -width_vertical $clk_width_2
setEdit -width_horizontal $clk_width_3 

for { set k 0} {$k < $Nti} {incr k} {
	setEdit -nets clk_interp_slice[[expr int(floor(double($k)/4))]]
	 if {$k < [expr $Nti/2]} {
		set x_cor [expr $boundary_width+$stochastic_adc_PR_width]
		set y_cor [expr $origin1_y+($k)*$stochastic_adc_PR_height+$V2T_clk_offset+$clk_width_3/2]
		editAddRoute $x_cor $y_cor
		editCommitRoute [expr ($x3p+$x3n)/2+$clk_width_2/3] $y_cor
	} else {
		set x_cor [expr $FP_width-($boundary_width+$stochastic_adc_PR_width)]
		set y_cor [expr $origin1_y+($Nti-$k-1)*$stochastic_adc_PR_height+$V2T_clk_offset+$clk_width_3/2]
		editAddRoute $x_cor $y_cor
		editCommitRoute [expr $FP_width-(($x3p+$x3n)/2+$clk_width_2/3)] $y_cor
	}
}

for { set k 0} {$k < $Nti/2} {incr k} {
	setEdit -nets clk_interp_slice[[expr int(floor(double($k)/2))]]
	 if {$k < [expr $Nti/4]} {
		set x_cor [expr ($x3p+$x3n)/2]
		set y_cor [expr $origin1_y+2*($k)*$stochastic_adc_PR_height+$V2T_clk_offset]
		editAddRoute $x_cor $y_cor
		editCommitRoute $x_cor [expr $y_cor+$stochastic_adc_PR_height+$clk_width_3]
	} else {
		set x_cor [expr $FP_width-($x3p+$x3n)/2]
		set y_cor [expr $origin1_y+($Nti-2*$k-1)*$stochastic_adc_PR_height+$V2T_clk_offset]
		editAddRoute $x_cor $y_cor
		editCommitRoute $x_cor [expr $y_cor-$stochastic_adc_PR_height-$clk_width_3]
	}
}

setEdit -width_vertical $clk_width_1
setEdit -width_horizontal $clk_width_1

for { set k 0} {$k < $Nti/2} {incr k} {
	setEdit -nets clk_interp_slice[[expr int(floor(double($k)/2))]]
	 if {$k < [expr $Nti/4]} {
		set x_cor [expr ($x3p+$x3n)/2-$clk_width_2/2]
		set y_cor [expr $origin1_y+(2*$k+1)*$stochastic_adc_PR_height]
		editAddRoute $x_cor $y_cor
		editCommitRoute [expr ($x2p+$x2n)/2+$clk_width_1/2] $y_cor
	} else {
		set x_cor [expr $FP_width-(($x3p+$x3n)/2-$clk_width_2/2)]
		set y_cor [expr $origin1_y+($Nti-2*$k-1)*$stochastic_adc_PR_height]
		editAddRoute $x_cor $y_cor
		editCommitRoute [expr $FP_width-(($x2p+$x2n)/2+$clk_width_1/2)] $y_cor
	}
}

for { set k 0} {$k < $Nti/4} {incr k} {
	setEdit -nets clk_interp_slice[$k]
	 if {$k < [expr $Nti/8]} {
		set x_cor [expr ($x2p+$x2n)/2]
		set y_cor [expr $origin1_y+(4*$k+1)*$stochastic_adc_PR_height-$clk_width_1/2]
		editAddRoute $x_cor $y_cor
		editCommitRoute $x_cor [expr $y_cor+2*$stochastic_adc_PR_height+$clk_width_1/2]
	} else {
		set x_cor [expr $FP_width-($x2p+$x2n)/2]
		set y_cor [expr $origin1_y+($Nti-4*$k-1)*$stochastic_adc_PR_height+$clk_width_1/2]
		editAddRoute $x_cor $y_cor
		editCommitRoute $x_cor [expr $y_cor-2*$stochastic_adc_PR_height-$clk_width_1/2]
	}
}

for { set k 0} {$k < $Nti/4} {incr k} {
	setEdit -nets clk_interp_slice[$k]
	 if {$k < [expr $Nti/8]} {
		set x_cor [expr $origin1_x+$stochastic_adc_PR_width+$routing_width_side+0.4]
		set y_cor [expr $origin1_y+(4*$k+2)*$stochastic_adc_PR_height]
		editAddRoute $x_cor $y_cor
		editCommitRoute [ expr ($x2p+$x2n)/2-$clk_width_1/2] $y_cor
	} else {
		set x_cor [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+$routing_width_side+0.4)]
		set y_cor [expr $origin1_y+($Nti-4*$k-2)*$stochastic_adc_PR_height]
		editAddRoute $x_cor $y_cor
		editCommitRoute [ expr $FP_width-(($x2p+$x2n)/2-$clk_width_1/2)] $y_cor
	}
}


#### ext_clk ####

set inbuf_inp_offset 5.73
set inbuf_inn_offset 10.05

setEdit -layer_vertical M9
setEdit -width_vertical 1.5
setEdit -layer_horizontal M9
setEdit -width_horizontal 4

setEdit -nets ext_clkp
editAddRoute  [expr $FP_width/2-$inbuf_width/2+0.045+$inbuf_inp_offset+0.75]  [expr $inbuf_height+$stochastic_adc_PR_height-2]
editCommitRoute  [expr $FP_width/2-$inbuf_width/2+0.045+$inbuf_inp_offset+0.75]  [expr $origin1_y+0.2]
editAddRoute  [expr $FP_width/2-$inbuf_width/2+0.045+$inbuf_inp_offset+0.75]  [expr $inbuf_height+$stochastic_adc_PR_height]
editCommitRoute  [expr $FP_width/2-25]  [expr $inbuf_height+$stochastic_adc_PR_height]

setEdit -nets ext_clkn
editAddRoute  [expr $FP_width/2-$inbuf_width/2+0.045+$inbuf_inn_offset+0.75]  [expr $inbuf_height+$stochastic_adc_PR_height-2]
editCommitRoute  [expr $FP_width/2-$inbuf_width/2+0.045+$inbuf_inn_offset+0.75]  [expr $origin1_y+0.2]
editAddRoute  [expr $FP_width/2-$inbuf_width/2+0.045+$inbuf_inn_offset+0.75]  [expr $inbuf_height+$stochastic_adc_PR_height]
editCommitRoute  [expr $FP_width/2+25]  [expr $inbuf_height+$stochastic_adc_PR_height]


setEdit -layer_vertical M10
setEdit -width_vertical 4

setEdit -nets ext_clkn
#editAddRoute  [expr $FP_width/2+23]  0
#editCommitRoute  [expr $FP_width/2+23]  [expr $inbuf_height+$stochastic_adc_PR_height+$cell_height]
editAddRoute  201.8  0
editCommitRoute  201.8 [expr $inbuf_height+$stochastic_adc_PR_height+$cell_height]

setEdit -nets ext_clkp
#editAddRoute  [expr $FP_width/2-23]  0
#editCommitRoute  [expr $FP_width/2-23]  [expr $inbuf_height+$stochastic_adc_PR_height+$cell_height]
editAddRoute  158.5  0
editCommitRoute  158.5  [expr $inbuf_height+$stochastic_adc_PR_height+$cell_height]




#### switch connection ##########

set sw_width 0.2
setEdit -layer_horizontal M6
setEdit -layer_vertical M5
setEdit -width_vertical $sw_width
setEdit -width_horizontal $sw_width


setEdit -nets clk_interp_sw[0]
editAddRoute [expr $origin2_x-7] [expr $origin1_y+2*$stochastic_adc_PR_height+$cell_height+$sw_width]
editCommitRoute [expr $origin2_x-7] [expr $origin1_y+2*$stochastic_adc_PR_height-($cell_height+$sw_width)]
editAddRoute [expr $origin2_x-7] [expr $origin1_y+2*$stochastic_adc_PR_height-($cell_height+$sw_width)]
editCommitRoute [expr $origin2_x+0.5] [expr $origin1_y+2*$stochastic_adc_PR_height-($cell_height+$sw_width)]

setEdit -nets clk_interp_swb[0]
editAddRoute [expr $origin2_x-7.6] [expr $origin1_y+2*$stochastic_adc_PR_height+6*$cell_height-$sw_width]
editCommitRoute [expr $origin2_x-7.6] [expr $origin1_y+2*$stochastic_adc_PR_height-(6*$cell_height-$sw_width)]
editAddRoute [expr $origin2_x-7.6] [expr $origin1_y+2*$stochastic_adc_PR_height-(6*$cell_height-$sw_width)]
editCommitRoute [expr $origin2_x+0.5] [expr $origin1_y+2*$stochastic_adc_PR_height-(6*$cell_height-$sw_width)]

setEdit -nets clk_interp_sw[1]
editAddRoute [expr $origin2_x-7] [expr $origin1_y+6*$stochastic_adc_PR_height+$cell_height+$sw_width]
editCommitRoute [expr $origin2_x-7] [expr $origin1_y+6*$stochastic_adc_PR_height-($cell_height+$sw_width)]
editAddRoute [expr $origin2_x-7] [expr $origin1_y+6*$stochastic_adc_PR_height+($cell_height+$sw_width)]
editCommitRoute [expr $origin2_x+0.5] [expr $origin1_y+6*$stochastic_adc_PR_height+($cell_height+$sw_width)]

setEdit -nets clk_interp_swb[1]
editAddRoute [expr $origin2_x-7.6] [expr $origin1_y+6*$stochastic_adc_PR_height+6*$cell_height-$sw_width]
editCommitRoute [expr $origin2_x-7.6] [expr $origin1_y+6*$stochastic_adc_PR_height-(6*$cell_height-$sw_width)]
editAddRoute [expr $origin2_x-7.6] [expr $origin1_y+6*$stochastic_adc_PR_height+(6*$cell_height-$sw_width)]
editCommitRoute [expr $origin2_x+0.5] [expr $origin1_y+6*$stochastic_adc_PR_height+(6*$cell_height-$sw_width)]

setEdit -nets clk_interp_sw[2]
editAddRoute [expr $FP_width-($origin2_x-7)] [expr $origin1_y+6*$stochastic_adc_PR_height+$cell_height+$sw_width]
editCommitRoute [expr $FP_width-($origin2_x-7)] [expr $origin1_y+6*$stochastic_adc_PR_height-($cell_height+$sw_width)]
editAddRoute [expr $FP_width-($origin2_x-7)] [expr $origin1_y+6*$stochastic_adc_PR_height+($cell_height+$sw_width)]
editCommitRoute [expr $FP_width-($origin2_x+0.5)] [expr $origin1_y+6*$stochastic_adc_PR_height+($cell_height+$sw_width)]

setEdit -nets clk_interp_swb[2]
editAddRoute [expr $FP_width-($origin2_x-7.6)] [expr $origin1_y+6*$stochastic_adc_PR_height+6*$cell_height-$sw_width]
editCommitRoute [expr $FP_width-($origin2_x-7.6)] [expr $origin1_y+6*$stochastic_adc_PR_height-(6*$cell_height-$sw_width)]
editAddRoute [expr $FP_width-($origin2_x-7.6)] [expr $origin1_y+6*$stochastic_adc_PR_height+(6*$cell_height-$sw_width)]
editCommitRoute [expr $FP_width-($origin2_x+0.5)] [expr $origin1_y+6*$stochastic_adc_PR_height+(6*$cell_height-$sw_width)]

setEdit -nets clk_interp_sw[3]
editAddRoute [expr $FP_width-($origin2_x-7)] [expr $origin1_y+2*$stochastic_adc_PR_height+$cell_height+$sw_width]
editCommitRoute [expr $FP_width-($origin2_x-7)] [expr $origin1_y+2*$stochastic_adc_PR_height-($cell_height+$sw_width)]
editAddRoute [expr $FP_width-($origin2_x-7)] [expr $origin1_y+2*$stochastic_adc_PR_height-($cell_height+$sw_width)]
editCommitRoute [expr $FP_width-($origin2_x+0.5)] [expr $origin1_y+2*$stochastic_adc_PR_height-($cell_height+$sw_width)]

setEdit -nets clk_interp_swb[3]
editAddRoute [expr $FP_width-($origin2_x-7.6)] [expr $origin1_y+2*$stochastic_adc_PR_height+6*$cell_height-$sw_width]
editCommitRoute [expr $FP_width-($origin2_x-7.6)] [expr $origin1_y+2*$stochastic_adc_PR_height-(6*$cell_height-$sw_width)]
editAddRoute [expr $FP_width-($origin2_x-7.6)] [expr $origin1_y+2*$stochastic_adc_PR_height-(6*$cell_height-$sw_width)]
editCommitRoute [expr $FP_width-($origin2_x+0.5)] [expr $origin1_y+2*$stochastic_adc_PR_height-(6*$cell_height-$sw_width)]



### replica ADCs


set vin_width 1.3
setEdit -layer_horizontal M8
setEdit -width_horizontal $vin_width
setEdit -layer_vertical M9
setEdit -width_vertical 1

setEdit -nets rx_inp_test
editAddRoute [expr $origin1_x+$stochastic_adc_PR_width-0.5] [expr $origin1_y-$stochastic_adc_PR_height+7.99+$vin_width/2]
editCommitRoute [expr $origin1_x+$stochastic_adc_PR_width+6] [expr $origin1_y-$stochastic_adc_PR_height+7.99+$vin_width/2]              
editAddRoute [expr $FP_width-($origin1_x+$stochastic_adc_PR_width-0.5)] [expr $origin1_y-$stochastic_adc_PR_height+7.99+$vin_width/2]
editCommitRoute [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+6)] [expr $origin1_y-$stochastic_adc_PR_height+7.99+$vin_width/2]  

setEdit -nets rx_inn_test
editAddRoute [expr $origin1_x+$stochastic_adc_PR_width-0.5] [expr $origin1_y-$stochastic_adc_PR_height+31.30+$vin_width/2]
editCommitRoute [expr $origin1_x+$stochastic_adc_PR_width+6] [expr $origin1_y-$stochastic_adc_PR_height+31.30+$vin_width/2]              
editAddRoute [expr $FP_width-($origin1_x+$stochastic_adc_PR_width-0.5)] [expr $origin1_y-$stochastic_adc_PR_height+31.30+$vin_width/2]
editCommitRoute [expr $FP_width-($origin1_x+$stochastic_adc_PR_width+6)] [expr $origin1_y-$stochastic_adc_PR_height+31.30+$vin_width/2]  

setEdit -nets rx_inp_test
editAddRoute [expr $x3p] [expr $origin1_y-$stochastic_adc_PR_height+7.99]
editCommitRoute [expr $x3p]  [expr $origin1_y-$stochastic_adc_PR_height+31.30+$vin_width]
editAddRoute [expr $FP_width-$x3p] [expr $origin1_y-$stochastic_adc_PR_height+7.99]
editCommitRoute [expr $FP_width-$x3p]  [expr $origin1_y-$stochastic_adc_PR_height+31.30+$vin_width]

setEdit -nets rx_inn_test
editAddRoute [expr $x3n] [expr $origin1_y-$stochastic_adc_PR_height+7.99]
editCommitRoute [expr $x3n]  [expr $origin1_y-$stochastic_adc_PR_height+31.30+$vin_width]
editAddRoute [expr $FP_width-$x3n] [expr $origin1_y-$stochastic_adc_PR_height+7.99]
editCommitRoute [expr $FP_width-$x3n]  [expr $origin1_y-$stochastic_adc_PR_height+31.30+$vin_width]


set vin_width 2
setEdit -width_horizontal $vin_width

setEdit -nets rx_inn_test
editAddRoute [expr $x3p] [expr $origin1_y-$stochastic_adc_PR_height/2+$vin_width/2+1]
editCommitRoute [expr $FP_width-$x3p] [expr $origin1_y-$stochastic_adc_PR_height/2+$vin_width/2+1]

setEdit -nets rx_inp_test
editAddRoute [expr $x3p] [expr $origin1_y-$stochastic_adc_PR_height/2-$vin_width/2-1]
editCommitRoute [expr $FP_width-$x3p] [expr $origin1_y-$stochastic_adc_PR_height/2-$vin_width/2-1]


setEdit -layer_vertical M9
setEdit -width_vertical $vin_width
setEdit -nets rx_inn_test
editAddRoute [expr $x_center-3] [expr $origin1_y-$stochastic_adc_PR_height/2+$vin_width/2+1]
editCommitRoute [expr $x_center-3] 3 

setEdit -nets rx_inp_test
editAddRoute [expr $x_center+3] [expr $origin1_y-$stochastic_adc_PR_height/2+$vin_width/2+1]
editCommitRoute [expr $x_center+3] 3




setEdit -layer_horizontal M10
setEdit -width_horizontal 3.6

setEdit -nets rx_inn_test
editAddRoute  [expr $x_center-4] 5
editCommitRoute  [expr $x_center-10] 5

setEdit -nets rx_inp_test
editAddRoute  [expr $x_center+4] 5
editCommitRoute  [expr $x_center+10] 5


}

## RDL to Vin
createRouteBlk -box [expr $origin2_x] [expr $y_center-$routing_height_center] [expr $origin2_x-$routing_width_side] [expr $y_center+$routing_height_center] -name rx_inp_M10_blk -layer RV
createRouteBlk -box [expr $FP_width-$origin2_x] [expr $y_center-$routing_height_center] [expr $FP_width-($origin2_x-$routing_width_side)] [expr $y_center+$routing_height_center] -name rx_inn_M10_blk -layer RV

setEdit -layer_horizontal M10
setEdit -width_horizontal $rx_in_RDL_width

setEdit -nets rx_inp
editAddRoute [expr $x_center-$rx_in_space/2] [expr $y_center]
editCommitRoute [expr $x_center-62] [expr $y_center]

setEdit -nets rx_inn
editAddRoute [expr $x_center+$rx_in_space/2] [expr $y_center]
editCommitRoute [expr $x_center+62] [expr $y_center]

deleteRouteBlk -name *

## AP pin assign for rx_inp/rx_inn

createPhysicalPin rx_inp -net rx_inp -layer 10 -rect [expr $x_center-$rx_in_space/2] [expr $y_center-$rx_in_RDL_width/2] [expr $x_center-62] [expr $y_center+$rx_in_RDL_width/2]
createPhysicalPin rx_inn -net rx_inn -layer 10 -rect [expr $x_center+$rx_in_space/2] [expr $y_center-$rx_in_RDL_width/2] [expr $x_center+62] [expr $y_center+$rx_in_RDL_width/2]




