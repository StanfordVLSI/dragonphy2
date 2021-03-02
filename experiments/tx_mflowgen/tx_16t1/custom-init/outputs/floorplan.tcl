    #=========================================================================
    # floorplan.tcl
    #=========================================================================
    # Author : Christopher Torng
    # Date   : March 26, 2018

    #-------------------------------------------------------------------------
    # Floorplan variables
    #-------------------------------------------------------------------------

    proc snap_to_grid {input granularity} {
       set new_value [expr ceil($input / $granularity) * $granularity]
       return $new_value
    }

    # Set the floorplan to target a reasonable placement density with a good
    # aspect ratio (height:width). An aspect ratio of 2.0 here will make a
    # rectangular chip with a height that is twice the width.

    set core_aspect_ratio   1.00; # Aspect ratio 1.0 for a square chip
    set core_density_target 0.70; # Placement density of 70% is reasonable

    set vert_pitch  [dbGet top.fPlan.coreSite.size_y]
    set horiz_pitch [dbGet top.fPlan.coreSite.size_x]

    set bottom_y [snap_to_grid 100 $vert_pitch]

    set pi_width [dbGet [lindex [dbGet -p top.insts.name *iPI*] 0].cell.size_x]
    set pi_height [dbGet [lindex [dbGet -p top.insts.name *iPI*] 0].cell.size_y]

    set indiv_width [dbGet [dbGet -p top.insts.name *indiv*].cell.size_x]
    set indiv_height [dbGet [dbGet -p top.insts.name *indiv*].cell.size_y]
    
    set tri_height [dbGet [dbGet -p top.insts.name *iBUF_0__i_tri_buf_p*].cell.size_y]
    set tri_width [dbGet [dbGet -p top.insts.name *iBUF_0__i_tri_buf_p*].cell.size_x]
    
    set term_height [dbGet [lindex [dbGet -p top.insts.name buf1/i_term_p] 0].cell.size_y]
    # set term_height [dbGet [lindex [dbGet -p top.insts.name itx/buf1/i_term_p] 0].cell.size_y]
    set term_width [dbGet [lindex [dbGet -p top.insts.name buf1/i_term_p] 0].cell.size_x]

    # Make room in the floorplan for the core power ring


    set_db [get_db nets ext_clk_async*] .skip_routing true
    set_db [get_db nets ext_mdll_clk_mon*] .skip_routing true
    set pwr_net_list  {CVDD CVSS AVDD AVSS DVDD DVSS}; # List of power nets in the core power ring

    set M1_min_width   [dbGet [dbGetLayerByZ 1].minWidth]
    set M1_min_spacing [dbGet [dbGetLayerByZ 1].minSpacing]

    set savedvars(p_ring_width)   [expr 48 * $M1_min_width];   # Arbitrary!
    set savedvars(p_ring_spacing) [expr 24 * $M1_min_spacing]; # Arbitrary!

    # Core bounding box margins
    # Set in Geom-Vars File
    set core_margin_t 0;#$vert_pitch
    set core_margin_b 0;#$vert_pitch 
    set core_margin_r 0;#[expr 5 * $horiz_pitch]
    set core_margin_l 0;#[expr 5 * $horiz_pitch]


    #-------------------------------------------------------------------------
    # Floorplan
    #-------------------------------------------------------------------------

    # Calling floorPlan with the "-r" flag sizes the floorplan according to
    # the core aspect ratio and a density target (70% is a reasonable
    # density).
    #

    #floorPlan -r $core_aspect_ratio $core_density_target \
    #             $core_margin_l $core_margin_b $core_margin_r $core_margin_t


    set FP_width [snap_to_grid [expr 400 + $sram_FP_adjust] $horiz_pitch ]
    set FP_height [snap_to_grid 350 $vert_pitch ]
    

    #floorPlan -site core -s $FP_width $FP_height \
                            $core_margin_l $core_margin_b $core_margin_r $core_margin_t
    floorPlan -site core -s $FP_width $FP_height 0 0 0 0

    setFlipping s

    set sram_to_acore_spacing_x [snap_to_grid 40 $horiz_pitch]
    set sram_to_acore_spacing_y [snap_to_grid 40 $vert_pitch]
    
    set sram_to_buff_spacing_y [snap_to_grid 30 $vert_pitch]

    set sram_to_sram_spacing  [snap_to_grid 30 $horiz_pitch]
    set sram_neighbor_spacing [expr $sram_width + $sram_to_sram_spacing]
    set sram_pair_spacing [expr 2*$sram_width + $sram_to_sram_spacing]
    set sram_vert_spacing [snap_to_grid 200 $vert_pitch]

    set pi_to_pi_spacing    [snap_to_grid 25 $horiz_pitch]
    set pi_neighbor_spacing [expr $pi_width + $pi_to_pi_spacing]
    set pi_neighbor_spacing_vertical [expr $pi_height + $pi_to_pi_spacing]
    #set origin_acore_x    [snap_to_grid [expr $FP_width/2 - $acore_width/2] $horiz_pitch ]
    #set origin_acore_y    [expr $sram_height + $sram_to_acore_spacing_y ]

    


    set origin_acore_x    [expr 199.98]
    set origin_acore_y    [expr 399.744 - $bottom_y]
   
    set origin_txindiv_x [expr [snap_to_grid 300 $horiz_pitch]]
    set origin_txindiv_y [expr [snap_to_grid 200 $vert_pitch]]
 
#    set origin_sram_ffe_x [expr $origin_acore_x + $acore_width + 100 + 15*$blockage_width  + $core_margin_l]
#    set origin_sram_ffe_y [expr 6*$blockage_height + $core_margin_b]
   
#    set origin_sram_ffe_y2 [expr $FP_height - 6*$blockage_height - $core_margin_t -$sram_height ]
 
    #set origin_sram_adc_x [expr $origin_sram_ffe_x + $sram_pair_spacing]
#    set origin_sram_adc_x [expr $origin_sram_ffe_x]
#    set origin_sram_adc_y [expr 6*$blockage_height + $core_margin_b] 
#    set origin_sram_adc_y2 [expr $FP_height - 6*$blockage_height - $core_margin_t -$sram_height]

    #set origin_async_x [expr 3*$blockage_width  + $core_margin_l]
    #set origin_async_y [expr $origin_sram_ffe_y + $sram_height +  $sram_to_buff_spacing_y]
    
    set origin_async_x [expr 43.56]
    set origin_async_y [expr 312.192 -$bottom_y]
    #set origin_out_x [expr $FP_width - 6*$blockage_width - $output_buffer_width - $core_margin_l]
    #set origin_out_y [expr $origin_sram_adc_y + $sram_height + $sram_to_acore_spacing_y - 4 * $vert_pitch]
    
    set origin_out_x [expr 555.3]
    set origin_out_y [expr 139.968 -$bottom_y]
    #set origin_main_x [expr $origin_acore_x + [snap_to_grid [expr $acore_width/2] $horiz_pitch]]
    #set origin_main_y [expr [snap_to_grid [expr $sram_height / 2.0] $vert_pitch] + $origin_sram_adc_y]

    set origin_main_x [expr 373.77 ]
    set origin_main_y [expr 312.192 -$bottom_y]
    #set origin_mdll_x [expr $origin_out_x - $mdll_width - [snap_to_grid 60 $horiz_pitch]]
    #set origin_mdll_y [expr $origin_acore_y + [snap_to_grid [expr $acore_height/4] $vert_pitch ]  ]   
 
    set origin_mdll_x [expr 462.51]
    set origin_mdll_y [expr 301.824 - $bottom_y]
    
    set origin_mon_x [expr 566.82]
    set origin_mon_y [expr 184.32 - $bottom_y]

    set origin_ref_x [expr 504.09]
    set origin_ref_y [expr 184.32 - $bottom_y]

    set origin_txpi_x  [snap_to_grid 100 $horiz_pitch]
    set txpi_x_spacing [snap_to_grid [expr $pi_width + 30] $horiz_pitch]
    set origin_txpi_y  [snap_to_grid 75 $vert_pitch]
    set txpi_y_spacing [snap_to_grid [expr $pi_height + 30] $vert_pitch]


	set origin_term_n_x [snap_to_grid 15 $horiz_pitch] 
	set origin_term_n_y [snap_to_grid 90 $vert_pitch] 
	set origin_term_p_x [snap_to_grid 15 $horiz_pitch] 
	set origin_term_p_y [snap_to_grid 161 $vert_pitch] 


    #set origin_ref_x [expr $FP_width - 6*$blockage_width - $input_buffer_width - $core_margin_l]
    #set origin_ref_y [expr $origin_out_y + $output_buffer_height + $blockage_height + 10*$vert_pitch]
        

# Use automatic floorplan synthesis to pack macros (e.g., SRAMs) together

    ###################
    # Place Instances #
    ###################
 
	placeInstance \
        buf1/i_term_n \
        $origin_term_n_x \
        $origin_term_n_y 
    
	placeInstance \
        buf1/i_term_p \
        $origin_term_p_x \
        $origin_term_p_y 

    for {set k 0} {$k<6} {incr k} {
        for {set j 0} {$j<6} {incr j} {
            placeInstance \
                buf1/iBUF_[expr ($j) + ($k)*6]\__i_tri_buf_p/tri_buf \
                [snap_to_grid [expr 39 + ($k) * ($tri_width*3)] $horiz_pitch]\
                [snap_to_grid [expr 134 + ($j) * ($tri_height*3)] $vert_pitch]
        }
    }

    for {set k 0} {$k<6} {incr k} {
        for {set j 0} {$j<6} {incr j} {
            placeInstance \
                buf1/iBUF_[expr ($j) + ($k)*6]\__i_tri_buf_n/tri_buf \
                [snap_to_grid [expr 39 + ($k) * ($tri_width*3)] $horiz_pitch] \
                [snap_to_grid [expr 110 + ($j) * ($tri_height*3)] $vert_pitch]
        }
    }

    #PI Macros
    #
    #
    for {set k 0} {$k<4} {incr k} {
        placeInstance \
        iPI_$k\__iPI \
            $origin_txpi_x  \
            [expr $origin_txpi_y + ($pi_neighbor_spacing)*($k-1)]
    }

    placeInstance \
    indiv \
        [expr $origin_txpi_x + 20] \
        [expr $origin_txpi_y + $pi_to_pi_spacing/2] \
             MX

    ###################
    # Place Blockages #
    ###################

    #rotated by 90
    #createPlaceBlockage -box  \
        [expr $origin_txindiv_x -$blockage_width] \
        [expr $origin_txindiv_y -$blockage_height] \
        [expr $origin_txindiv_x + $indiv_width + $blockage_width] \
        [expr $origin_txindiv_y + $indiv_height + $blockage_height] 
    
	#PI Blockages
    for {set k 0} {$k<4} {incr k} {
    	createPlaceBlockage -box \
        	[expr $origin_txpi_x - $blockage_width]   \
        	[expr $origin_txpi_y - $blockage_height + ($pi_neighbor_spacing)*($k-1)]\
        	[expr $origin_txpi_x + $pi_width + $blockage_width]  \
        	[expr $origin_txpi_y + ($pi_height)*(1) + ($pi_neighbor_spacing)*($k-1) + $blockage_height]
    }

    
   #createPlaceBlockage -box \
        [expr $origin_out_x - $blockage_width] \
        [expr $origin_out_y - $blockage_height] \
        [expr $origin_out_x + $output_buffer_width  + $blockage_width] \
        [expr $origin_out_y + $output_buffer_height + $blockage_height]
   
    
