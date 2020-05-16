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

    set output_buffer_width [dbGet [dbGet -p top.insts.name *out_buff_i*].cell.size_x]
    set output_buffer_height [dbGet [dbGet -p top.insts.name *out_buff_i*].cell.size_y]
    
    set acore_width [dbGet [dbGet -p top.insts.name *iacore*].cell.size_x]
    set acore_height [dbGet [dbGet -p top.insts.name *iacore*].cell.size_y]


    set mdll_width [dbGet [dbGet -p top.insts.name *imdll*].cell.size_x]
    set mdll_height [dbGet [dbGet -p top.insts.name *imdll*].cell.size_y]

    # Make room in the floorplan for the core power ring

    set pwr_net_list {VDD VSS}; # List of power nets in the core power ring

    set M1_min_width   [dbGet [dbGetLayerByZ 1].minWidth]
    set M1_min_spacing [dbGet [dbGetLayerByZ 1].minSpacing]

    set savedvars(p_ring_width)   [expr 48 * $M1_min_width];   # Arbitrary!
    set savedvars(p_ring_spacing) [expr 24 * $M1_min_spacing]; # Arbitrary!

    # Core bounding box margins
    # Set in Geom-Vars File
    set core_margin_t $vert_pitch
    set core_margin_b $vert_pitch 
    set core_margin_r [expr 5 * $horiz_pitch]
    set core_margin_l [expr 5 * $horiz_pitch]


    #-------------------------------------------------------------------------
    # Floorplan
    #-------------------------------------------------------------------------

    # Calling floorPlan with the "-r" flag sizes the floorplan according to
    # the core aspect ratio and a density target (70% is a reasonable
    # density).
    #

    #floorPlan -r $core_aspect_ratio $core_density_target \
    #             $core_margin_l $core_margin_b $core_margin_r $core_margin_t

    set sram_FP_adjust 200

    set FP_width [snap_to_grid [expr 800 + $sram_FP_adjust] $horiz_pitch ]
    set FP_height [snap_to_grid 800 $vert_pitch ]
    

    floorPlan -site core -s $FP_width $FP_height \
                            $core_margin_l $core_margin_b $core_margin_r $core_margin_t

    setFlipping s

    set sram_to_acore_spacing_x [snap_to_grid 40 $horiz_pitch]
    set sram_to_acore_spacing_y [snap_to_grid 40 $vert_pitch]
    
    set sram_to_buff_spacing_y [snap_to_grid 30 $vert_pitch]

    set sram_to_sram_spacing  [snap_to_grid 15 $horiz_pitch]
    set sram_neighbor_spacing [expr $sram_width + $sram_to_sram_spacing]
    set sram_pair_spacing [expr 2*$sram_width + $sram_to_sram_spacing]
    set sram_vert_spacing [snap_to_grid 200 $vert_pitch]

    #set origin_acore_x    [snap_to_grid [expr $FP_width/2 - $acore_width/2] $horiz_pitch ]
    #set origin_acore_y    [expr $sram_height + $sram_to_acore_spacing_y ]

    set origin_acore_x    [expr 199.98 + $sram_FP_adjust]
    set origin_acore_y    399.744
    
    set origin_sram_ffe_x [expr 9*$blockage_width  + $core_margin_l]
    set origin_sram_ffe_y [expr 9*$blockage_height + $core_margin_b]
    
    set origin_sram_adc_x [expr $origin_sram_ffe_x + 2*$sram_pair_spacing]
    set origin_sram_adc_y [expr 9*$blockage_height + $core_margin_b]

    #set origin_async_x [expr 3*$blockage_width  + $core_margin_l]
    #set origin_async_y [expr $origin_sram_ffe_y + $sram_height +  $sram_to_buff_spacing_y]
    
    set origin_async_x [expr 109.98 + $sram_FP_adjust]
    set origin_async_y 323.712
    #set origin_out_x [expr $FP_width - 6*$blockage_width - $output_buffer_width - $core_margin_l]
    #set origin_out_y [expr $origin_sram_adc_y + $sram_height + $sram_to_acore_spacing_y - 4 * $vert_pitch]
    
    set origin_out_x [expr 738.00 + $sram_FP_adjust]
    set origin_out_y 170.496 
    #set origin_main_x [expr $origin_acore_x + [snap_to_grid [expr $acore_width/2] $horiz_pitch]]
    #set origin_main_y [expr [snap_to_grid [expr $sram_height / 2.0] $vert_pitch] + $origin_sram_adc_y]

    set origin_main_x [expr 373.77 + $sram_FP_adjust]
    set origin_main_y 323.712
    #set origin_mdll_x [expr $origin_out_x - $mdll_width - [snap_to_grid 60 $horiz_pitch]]
    #set origin_mdll_y [expr $origin_acore_y + [snap_to_grid [expr $acore_height/4] $vert_pitch ]  ]   
 
    set origin_mdll_x [expr 540.00 + $sram_FP_adjust]
    set origin_mdll_y 312.192   
    
    set origin_mon_x [expr 722.74 + $sram_FP_adjust]
    set origin_mon_y 293.76

    set origin_ref_x [expr 722.74 + $sram_FP_adjust]
    set origin_ref_y 353.088

    #set origin_ref_x [expr $FP_width - 6*$blockage_width - $input_buffer_width - $core_margin_l]
    #set origin_ref_y [expr $origin_out_y + $output_buffer_height + $blockage_height + 10*$vert_pitch]
        

# Use automatic floorplan synthesis to pack macros (e.g., SRAMs) together

    ###################
    # Place Instances #
    ###################\

    placeInstance \
        ibuf_async \
        $origin_async_x \
        $origin_async_y

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
        MX

    placeInstance \
        ibuf_mdll_ref \
        [expr $origin_ref_x] \
        [expr $origin_ref_y] \
        

    placeInstance \
        idcore/out_buff_i \
        $origin_out_x \
        $origin_out_y
 
    #Memory Macros
    for {set k 0} {$k<4} {incr k} {
        if {[expr $k % 2] == 0} {
            #placeInstance \
            #idcore/omm_ffe_i/genblk3_$k\__sram_i/memory \
            #    $origin_sram_ffe_x \
            #    [expr $origin_sram_ffe_y + ($sram_vert_spacing + $sram_height - $core_margin_t - $core_margin_b)*($k/2)]

            placeInstance \
            idcore/omm_ffe_i/genblk3_$k\__sram_i/memory \
                [expr $origin_sram_ffe_x + $sram_pair_spacing*($k/2)] \
                $origin_sram_ffe_y

            placeInstance \
            idcore/oneshot_multimemory_i/genblk3_$k\__sram_i/memory \
                [expr $origin_sram_adc_x + $sram_pair_spacing*($k/2)] \
                $origin_sram_adc_y

        } else {
            #placeInstance \
            #idcore/omm_ffe_i/genblk3_$k\__sram_i/memory \
            #    [expr $origin_sram_ffe_x + $sram_neighbor_spacing] \
            #    [expr $origin_sram_ffe_y + ($sram_vert_spacing + $sram_height - $core_margin_t - $core_margin_b)*($k/2)] MY

            #placeInstance \
            #idcore/oneshot_multimemory_i/genblk3_$k\__sram_i/memory \
            #    [expr $origin_sram_adc_x + $sram_neighbor_spacing +  $sram_pair_spacing*($k/2)] \
            #    $origin_sram_adc_y MY

            placeInstance \
            idcore/omm_ffe_i/genblk3_$k\__sram_i/memory \
                [expr $origin_sram_ffe_x + $sram_neighbor_spacing +  $sram_pair_spacing*($k/2)] \
                $origin_sram_ffe_y MY


            placeInstance \
            idcore/oneshot_multimemory_i/genblk3_$k\__sram_i/memory \
                [expr $origin_sram_adc_x + $sram_neighbor_spacing +  $sram_pair_spacing*($k/2)] \
                $origin_sram_adc_y MY
        }
    }

    ###################
    # Place Blockages #
    ###################

    createPlaceBlockage -box \
        [expr $origin_sram_ffe_x - $blockage_width] \
        [expr $origin_sram_ffe_y - $blockage_height] \
        [expr $origin_sram_ffe_x + 2*$sram_pair_spacing + $blockage_width] \
        [expr $origin_sram_ffe_y + $sram_height       + $blockage_height]

    #createPlaceBlockage -box \
    #    [expr $origin_sram_ffe_x - $blockage_width] \
    #    [expr $origin_sram_ffe_y - $blockage_height] \
    #    [expr $origin_sram_ffe_x + $sram_pair_spacing + $blockage_width] \
    #    [expr $origin_sram_ffe_y + $sram_height       + $blockage_height]
    #createPlaceBlockage -box \
    #    [expr $origin_sram_ffe_x - $blockage_width] \
    #    [expr $origin_sram_ffe_y + $sram_vert_spacing + $sram_height - $blockage_height] \
    #    [expr $origin_sram_ffe_x + $sram_pair_spacing + $blockage_width] \
    #    [expr $origin_sram_ffe_y + $sram_vert_spacing + 2*$sram_height + $blockage_height]

    createPlaceBlockage -box \
        [expr $origin_sram_adc_x - $blockage_width] \
        [expr $origin_sram_adc_y - $blockage_height] \
        [expr $origin_sram_adc_x + 2*$sram_pair_spacing + $blockage_width] \
        [expr $origin_sram_adc_y + $sram_height         + $blockage_height]

    #createPlaceBlockage -box \
    #    [expr $origin_sram_adc_x - $blockage_width] \
    #    [expr $origin_sram_adc_y - $blockage_height] \
    #    [expr $origin_sram_adc_x + 2*$sram_pair_spacing + $blockage_width] \
    #    [expr $origin_sram_adc_y + $sram_height         + $blockage_height]


    createPlaceBlockage -box \
        [expr $origin_acore_x - $blockage_width] \
        [expr $origin_acore_y - $blockage_height] \
        [expr $origin_acore_x + $acore_width  + $blockage_width] \
        [expr $origin_acore_y + $acore_height + $blockage_height]

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
