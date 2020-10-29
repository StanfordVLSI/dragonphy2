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

    set sram_FP_adjust [snap_to_grid 350 $horiz_pitch]
    set tx_FP_adjust [snap_to_grid 250 $horiz_pitch]
    set bottom_y [snap_to_grid 100 $vert_pitch]

    set output_buffer_width [dbGet [dbGet -p top.insts.name *out_buff_i*].cell.size_x]
    set output_buffer_height [dbGet [dbGet -p top.insts.name *out_buff_i*].cell.size_y]
    
    set acore_width [dbGet [dbGet -p top.insts.name *iacore*].cell.size_x]
    set acore_height [dbGet [dbGet -p top.insts.name *iacore*].cell.size_y]

    set pi_width [dbGet [lindex [dbGet -p top.insts.name *iPI*] 0].cell.size_x]
    set pi_height [dbGet [lindex [dbGet -p top.insts.name *iPI*] 0].cell.size_y]

    set indiv_width [dbGet [dbGet -p top.insts.name *indiv*].cell.size_x]
    set indiv_height [dbGet [dbGet -p top.insts.name *indiv*].cell.size_y]
    
    set mdll_width [dbGet [dbGet -p top.insts.name *imdll*].cell.size_x]
    set mdll_height [dbGet [dbGet -p top.insts.name *imdll*].cell.size_y]

    set small_sram_height [dbGet [lindex [dbGet -p top.insts.name *hist_sram_inst_memory*] 0].cell.size_y] 
    set small_sram_width  [dbGet [lindex [dbGet -p top.insts.name *hist_sram_inst_memory*] 0].cell.size_x] 

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


    set FP_width [snap_to_grid [expr 800 + $tx_FP_adjust + $sram_FP_adjust] $horiz_pitch ]
    set FP_height [snap_to_grid 700 $vert_pitch ]
    

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
    #set origin_acore_x    [snap_to_grid [expr $FP_width/2 - $acore_width/2] $horiz_pitch ]
    #set origin_acore_y    [expr $sram_height + $sram_to_acore_spacing_y ]

    set origin_acore_x    [expr 199.98 + $tx_FP_adjust]
    set origin_acore_y    [expr 399.744 - $bottom_y]
   
    set origin_txindiv_x [expr [snap_to_grid 300 $horiz_pitch] + $tx_FP_adjust]
    set origin_txindiv_y [expr [snap_to_grid 200 $vert_pitch]]
 
    set origin_sram_ffe_x [expr $origin_acore_x + $acore_width + 100 + 15*$blockage_width  + $core_margin_l]
    set origin_sram_ffe_y [expr 6*$blockage_height + $core_margin_b]
   
    set origin_sram_ffe_y2 [expr $FP_height - 6*$blockage_height - $core_margin_t -$sram_height ]
 
    #set origin_sram_adc_x [expr $origin_sram_ffe_x + $sram_pair_spacing]
    set origin_sram_adc_x [expr $origin_sram_ffe_x]
    set origin_sram_adc_y [expr 6*$blockage_height + $core_margin_b] 
    set origin_sram_adc_y2 [expr $FP_height - 6*$blockage_height - $core_margin_t -$sram_height]

    #set origin_async_x [expr 3*$blockage_width  + $core_margin_l]
    #set origin_async_y [expr $origin_sram_ffe_y + $sram_height +  $sram_to_buff_spacing_y]
    
    set origin_async_x [expr 43.56 + $tx_FP_adjust]
    set origin_async_y [expr 312.192 -$bottom_y]
    #set origin_out_x [expr $FP_width - 6*$blockage_width - $output_buffer_width - $core_margin_l]
    #set origin_out_y [expr $origin_sram_adc_y + $sram_height + $sram_to_acore_spacing_y - 4 * $vert_pitch]
    
    set origin_out_x [expr 555.3 + $tx_FP_adjust]
    set origin_out_y [expr 139.968 -$bottom_y]
    #set origin_main_x [expr $origin_acore_x + [snap_to_grid [expr $acore_width/2] $horiz_pitch]]
    #set origin_main_y [expr [snap_to_grid [expr $sram_height / 2.0] $vert_pitch] + $origin_sram_adc_y]

    set origin_main_x [expr 373.77 + $tx_FP_adjust]
    set origin_main_y [expr 312.192 -$bottom_y]
    #set origin_mdll_x [expr $origin_out_x - $mdll_width - [snap_to_grid 60 $horiz_pitch]]
    #set origin_mdll_y [expr $origin_acore_y + [snap_to_grid [expr $acore_height/4] $vert_pitch ]  ]   
 
    set origin_mdll_x [expr 462.51 + $tx_FP_adjust]
    set origin_mdll_y [expr 301.824 - $bottom_y]
    
    set origin_mon_x [expr 566.82 + $tx_FP_adjust]
    set origin_mon_y [expr 184.32 - $bottom_y]

    set origin_ref_x [expr 504.09 + $tx_FP_adjust]
    set origin_ref_y [expr 184.32 - $bottom_y]

    set origin_txpi_x  [snap_to_grid 100 $horiz_pitch]
    set txpi_x_spacing [snap_to_grid [expr $pi_width + 30] $horiz_pitch]
    set origin_txpi_y  [snap_to_grid 250 $vert_pitch]
    set txpi_y_spacing [snap_to_grid [expr $pi_height + 30] $vert_pitch]

    #set origin_ref_x [expr $FP_width - 6*$blockage_width - $input_buffer_width - $core_margin_l]
    #set origin_ref_y [expr $origin_out_y + $output_buffer_height + $blockage_height + 10*$vert_pitch]
        

# Use automatic floorplan synthesis to pack macros (e.g., SRAMs) together

    ###################
    # Place Instances #
    ###################\

    placeInstance \
        ibuf_async \
        $origin_async_x \
        $origin_async_y \
		MY

    placeInstance \
        imdll \
        $origin_mdll_x \
        $origin_mdll_y 

    placeInstance \
        iacore \
        $origin_acore_x \
        $origin_acore_y
    
    placeInstance \
        ibuf_main \
        $origin_main_x\
        $origin_main_y

    placeInstance \
        ibuf_mdll_mon \
        [expr $origin_mon_x] \
        [expr $origin_mon_y] \
		MY
	
    placeInstance \
        ibuf_mdll_ref \
        [expr $origin_ref_x] \
        [expr $origin_ref_y] 

    placeInstance \
        idcore/out_buff_i \
        $origin_out_x \
        $origin_out_y
 
    #PI Macros
    placeInstance \
    itx/iPI_0__iPI \
        $origin_txpi_x \
        $origin_txpi_y 

    placeInstance \
    itx/iPI_1__iPI \
        [expr $origin_txpi_x + $txpi_x_spacing] \
        $origin_txpi_y MY

    placeInstance \
    itx/iPI_2__iPI \
        $origin_txpi_x \
        [expr $origin_txpi_y + $txpi_y_spacing] MX

    placeInstance \
    itx/iPI_3__iPI \
        [expr $origin_txpi_x + $txpi_x_spacing] \
        [expr $origin_txpi_y + $txpi_y_spacing] R180

    placeInstance \
    itx/indiv \
        $origin_txindiv_x \
        $origin_txindiv_y

    #Memory Macros
    for {set k 0} {$k<4} {incr k} {
        if {[expr $k % 2] == 0} {
            placeInstance \
            idcore/omm_ffe_i_genblk3_$k\__sram_i_memory \
                [expr $origin_sram_ffe_x + $sram_pair_spacing*($k/2)] \
                $origin_sram_ffe_y2

            placeInstance \
            idcore/oneshot_multimemory_i_genblk3_$k\__sram_i_memory \
                [expr $origin_sram_adc_x + $sram_pair_spacing*($k/2)] \
                $origin_sram_adc_y

        } else {
            placeInstance \
            idcore/oneshot_multimemory_i_genblk3_$k\__sram_i_memory \
                [expr $origin_sram_adc_x + $sram_neighbor_spacing +  $sram_pair_spacing*($k/2)] \
                $origin_sram_adc_y MY

            placeInstance \
            idcore/omm_ffe_i_genblk3_$k\__sram_i_memory \
                [expr $origin_sram_ffe_x + $sram_neighbor_spacing +  $sram_pair_spacing*($k/2)] \
                $origin_sram_ffe_y2 MY
        }
    }

    placeInstance \
    idcore/errt_i/errt_i_sram_i_memory \
        [expr $origin_sram_adc_x + 2*$sram_pair_spacing] \
        $origin_sram_adc_y 



    placeInstance \
    idcore/histogram_inst_core_0_hist_sram_inst_memory \
        [expr $origin_sram_ffe_x + 2*$sram_pair_spacing] \
        $origin_sram_ffe_y2

    placeInstance \
    idcore/histogram_inst_core_1_hist_sram_inst_memory \
        [expr $origin_sram_ffe_x  + 2*$sram_pair_spacing] \
        [expr $origin_sram_ffe_y2 + $small_sram_height] 

    ###################
    # Place Blockages #
    ###################
    #createPlaceBlockage -box \
    #    [expr $origin_sram_adc_x + 2*$sram_pair_spacing] \
    #    [expr $origin_sram_adc_y + $sram_height]  \
     #   [expr $origin_acore_x] \
     #   [expr $origin_sram_ffe_y2]
     createPlaceBlockage -box \
        [expr $origin_sram_ffe_x + 2*$sram_pair_spacing] \
        [expr $origin_sram_ffe_y2 - $blockage_height] \
        [expr $origin_sram_ffe_x + 2*$sram_pair_spacing + $small_sram_width + $blockage_width]\
        [expr $origin_sram_ffe_y2 + 2*$small_sram_height + $blockage_height]


    #rotated by 90
    createPlaceBlockage -box  \
        [expr $origin_txindiv_x -$blockage_width] \
        [expr $origin_txindiv_y -$blockage_height] \
        [expr $origin_txindiv_x + $indiv_width + $blockage_width] \
        [expr $origin_txindiv_y + $indiv_height + $blockage_height] 
    #PI Blockages
    createPlaceBlockage -box \
        [expr $origin_txpi_x -$blockage_width] \
        [expr $origin_txpi_y -$blockage_height] \
        [expr $origin_txpi_x + $txpi_x_spacing + $pi_width + $blockage_width] \
        [expr $origin_txpi_y + $txpi_y_spacing + $pi_height + $blockage_height]
    
    #Memory Blockage
    createPlaceBlockage -box \
        [expr $origin_sram_ffe_x - $blockage_width] \
        [expr $origin_sram_ffe_y2 - $blockage_height] \
        [expr $origin_sram_ffe_x + 2*$sram_pair_spacing + $blockage_width] \
        [expr $origin_sram_ffe_y2 + $sram_height       + $blockage_height]

    #createPlaceBlockage -box \
    #    [expr $origin_sram_ffe_x - $blockage_width] \
    #    [expr $origin_sram_ffe_y - $blockage_height] \
    #    [expr $origin_sram_ffe_x + $sram_pair_spacing + $blockage_width] \
    #    [expr $origin_sram_ffe_y + $sram_height       + $blockage_height]
    
    #createPlaceBlockage -box \
    #    [expr $origin_sram_ffe_x - $blockage_width] \
    #    [expr $origin_sram_ffe_y2 - $blockage_height] \
    #    [expr $origin_sram_ffe_x + $sram_pair_spacing + $blockage_width] \
    #    [expr $origin_sram_ffe_y2 + $sram_height       + $blockage_height]


    #createPlaceBlockage -box \
    #    [expr $origin_sram_adc_x - $blockage_width] \
    #    [expr $origin_sram_adc_y - $blockage_height] \
    #    [expr $origin_sram_adc_x + $sram_pair_spacing + $blockage_width] \
    #    [expr $origin_sram_adc_y + $sram_height       + $blockage_height]
    
    #createPlaceBlockage -box \
    #    [expr $origin_sram_adc_x - $blockage_width] \
    #    [expr $origin_sram_adc_y2 - $blockage_height] \
    #    [expr $origin_sram_adc_x + $sram_pair_spacing + $blockage_width] \
    #    [expr $origin_sram_adc_y2 + $sram_height       + $blockage_height]
    #createPlaceBlockage -box \
    #    [expr $origin_sram_ffe_x - $blockage_width] \
    #    [expr $origin_sram_ffe_y + $sram_vert_spacing + $sram_height - $blockage_height] \
    #    [expr $origin_sram_ffe_x + $sram_pair_spacing + $blockage_width] \
    #    [expr $origin_sram_ffe_y + $sram_vert_spacing + 2*$sram_height + $blockage_height]

    createPlaceBlockage -box \
        [expr $origin_sram_adc_x - $blockage_width] \
        [expr $origin_sram_adc_y - $blockage_height] \
        [expr $origin_sram_adc_x + 2*$sram_pair_spacing + $sram_width + $blockage_width] \
        [expr $origin_sram_adc_y + $sram_height         + $blockage_height]

    #createPlaceBlockage -box \
    #    [expr $origin_sram_adc_x - $blockage_width] \
    #    [expr $origin_sram_adc_y - $blockage_height] \
    #    [expr $origin_sram_adc_x + 2*$sram_pair_spacing + $blockage_width] \
    #    [expr $origin_sram_adc_y + $sram_height         + $blockage_height]

    #Try to reduce congestion at this corner
    createPlaceBlockage -type soft -density 25 -box \
        [expr $origin_acore_x - 5*$blockage_width] \
        [expr $origin_acore_y - 3*$blockage_height] \
        [expr $origin_acore_x + 3*$blockage_width] \
        [expr $origin_acore_y + 3* $blockage_height ]
    
    createPlaceBlockage -box \
        [expr $origin_acore_x - $blockage_width] \
        [expr $origin_acore_y - 1*$blockage_height] \
        [expr $origin_acore_x + $acore_width  + $blockage_width] \
        [expr $FP_height]

    createPlaceBlockage -box \
        [expr $origin_async_x - $blockage_width] \
        [expr $origin_async_y - $blockage_height] \
        [expr $origin_async_x + $input_buffer_width  + $blockage_width] \
        [expr $origin_async_y + $input_buffer_height + $blockage_height]
    
    createPlaceBlockage -box \
        [expr $origin_ref_x - $blockage_width] \
        [expr $origin_ref_y - $blockage_height] \
        [expr $origin_ref_x + $input_buffer_width  +  $blockage_width] \
        [expr $origin_ref_y + $input_buffer_height +  $blockage_height]
    
    createPlaceBlockage -box \
        [expr $origin_mon_x - $blockage_width] \
        [expr $origin_mon_y - $blockage_height] \
        [expr $origin_mon_x + $input_buffer_width  +  $blockage_width] \
        [expr $origin_mon_y + $input_buffer_height +  $blockage_height]

    createPlaceBlockage -box \
        [expr $origin_main_x - $blockage_width] \
        [expr $origin_main_y - $blockage_height] \
        [expr $origin_main_x + $input_buffer_width  + $blockage_width] \
        [expr $origin_main_y + $input_buffer_height + $blockage_height]
    
   createPlaceBlockage -box \
        [expr $origin_out_x - $blockage_width] \
        [expr $origin_out_y - $blockage_height] \
        [expr $origin_out_x + $output_buffer_width  + $blockage_width] \
        [expr $origin_out_y + $output_buffer_height + $blockage_height]
   
    createPlaceBlockage -box \
        [expr $origin_mdll_x - $blockage_width] \
        [expr $origin_mdll_y - $blockage_height] \
        [expr $origin_mdll_x + $mdll_width  + $blockage_width] \
        [expr $origin_mdll_y + $mdll_height + $blockage_height]
 
    #oneshot_multimemory_N_mem_tiles4_0 ffe
    #   sram_ADR_BITS10_DAT_BITS144_3 genblk3_0__sram_i 
    #   sram_ADR_BITS10_DAT_BITS144_2 genblk3_1__sram_i 
    #   sram_ADR_BITS10_DAT_BITS144_1 genblk3_2__sram_i 
    #   sram_ADR_BITS10_DAT_BITS144_0 genblk3_3__sram_i 

    #oneshot_multimemory_N_mem_tiles4_1 adc
    #   sram_ADR_BITS10_DAT_BITS144_7 genblk3_0__sram_i
    #   sram_ADR_BITS10_DAT_BITS144_6 genblk3_1__sram_i
    #   sram_ADR_BITS10_DAT_BITS144_5 genblk3_2__sram_i
    #   sram_ADR_BITS10_DAT_BITS144_4 genblk3_3__sram_i
    
