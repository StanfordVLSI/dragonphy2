
#################################################
set STAGE       "cts"
set vars(db_name) 03_native_cts
set start_time [clock seconds]
##################################################

if { ${RUN_LAYOUT_ONLY} == 0 } {
  
  ## update sdc ##
  if { ${ILM_MODE} == 1 }  {
    update_constraint_mode -name func -ilm_sdc_files $sdc(postcts)
  } else {
    update_constraint_mode -name func -sdc_files $sdc(postcts)
  }
  
  ################
  set_interactive_constraint_modes [all_constraint_modes -active]
  
  ## data is 1/3 of clock period 0.6
  ## clcok is 1/6 of clock priod 0.6
  #set_max_transition ${max_tran} [get_design [dbget top.name]]
  
  ### load always tcl
  source ${scrDir}/edi_setting.tcl
  ### update RC Factor
  source ${scrDir}/updateRCFactor.tcl
  
  ####################################################
  ## Delay Cal  mode                                ##
  ####################################################
  setDelayCalMode -reset
  #BCLIM: complain -useECSMInPreRoute is invalid opt
  #setDelayCalMode -engine Aae -SIAware false -signOff true -useECSMInPreRoute true
  setDelayCalMode -engine Aae -SIAware false -signOff true 
  setDelayCalMode -equivalent_waveform_model propagation 
  setDelayCalMode -siMode signoff
  setDelayCalMode -reset -siMode ; # BCLIM
  
  setAnalysisMode -reset
  setAnalysisMode -analysisType onChipVariation -cppr both
  
  cleanupSpecifyClockTree
  
  ###################CTS/CCOPT Mode #################
  set_ccopt_mode -reset
  setCTSMode -reset
  
  ### Native CCOpt ####
  set_ccopt_mode -integration native
  
  set_ccopt_mode -cts_buffer_cells       {CKBD*LVT}
  set_ccopt_mode -cts_inverter_cells     {CKND*LVT}
  set_ccopt_mode -cts_clock_gating_cells {CKLNQD*LVT}



  set_ccopt_mode -cts_target_skew 0.01
  set_ccopt_mode -cts_target_slew 0.1
  set_ccopt_mode -cts_target_nonleaf_slew 0.1
  set_ccopt_mode -cts_use_inverters true
  set_ccopt_mode -ccopt_auto_limit_insertion_delay_factor 1.2
  set_ccopt_mode -cts_opt_priority insertion_delay 	 
  #set_ccopt_mode -cts_opt_priority power 	 
  
  #set_clock_latency -max 0.02 [get_pins */CPN]
  #set_ccopt_property insertion_delay -max -pin iadder/*CP
  #set_ccopt_property insertion_delay -max -pin count_reg_0_/CPN 0.05
  #set_ccopt_property insertion_delay -max -pin count_reg_1_/CPN 0.05
  #set_ccopt_property insertion_delay -max -pin en_sync_sampled_reg/CPN 0.05
  #set_ccopt_property insertion_delay -max -pin en_sync_out_reg/CP 0.05
  #set_ccopt_property insertion_delay -max -pin iearly_late_gen_dont_touch/iff1_dont_touch/Q_reg/CP 0.05
  #set_ccopt_property insertion_delay -max -pin iearly_late_gen_dont_touch/iff2_dont_touch/Q_reg/CP 0.05
  #set_ccopt_property insertion_delay -max -pin iearly_late_gen_dont_touch/iff3_dont_touch/Q_reg/CP 0.05


  #Force ccopt use multi thread when route clock nets
  set_ccopt_property force_nanoroute_single_threaded false
  
  ### for CELL Pin desity ##
  set_ccopt_property cell_density 1
  set_ccopt_property call_cong_repair_during_final_implementation true
  
  
  setCTSMode -routeClkNet true
    
  
  #### Top-net ##
  ## Shield nets using ccopt top rules
  set_ccopt_mode -route_top_top_preferred_layer ${maxLayer}
  set_ccopt_mode -route_top_bottom_preferred_layer [expr ${maxLayer}-1]
  set_ccopt_mode -route_top_preferred_extra_space 0
  set_ccopt_mode -route_top_shielding_net $gnd_name ; # BCLIM
  set_ccopt_property routing_top_min_fanout 2500
  
  ## Trunk nets ##
  setCTSMode -routeTopPreferredLayer ${maxLayer}
  setCTSMode -routeBottomPreferredLayer [expr ${maxLayer}-2]
  setCTSMode -routePreferredExtraSpace 0
  
  ## Leaf nets ##
  setCTSMode -routeLeafTopPreferredLayer ${maxLayer}
  setCTSMode -routeLeafBottomPreferredLayer [expr ${maxLayer}-2]
  setCTSMode -routeLeafPreferredExtraSpace 0
  
  ## Apply NDR ## BCLIM
  #set_ccopt_property route_type -net_type trunk cts_trunk
  #set_ccopt_property route_type -net_type leaf cts_leaf
  
  ##########
  delete_ccopt_clock_tree_spec
  #create_ccopt_clock_tree_spec -immediate
  create_ccopt_clock_tree_spec -file ./CTS.spec 
  source ./acore_CTS.spec 
 
  #set_ccopt_property inverter_cells -clock_tree clk_in [ list CKND*LVT]
  #set_ccopt_property buffer_cells -clock_tree clk_in [ list CKBD*LVT ]
  #set_ccopt_property -skew_group clk_out/func -max_buffer_depth 3

  #set_ccopt_property -pin iADC_*/iV2T_clock_gen/*/CPN sink_type stop 
  #set_ccopt_property -pin iADCrep*/iV2T_clock_gen/*/CPN sink_type ignore
  #set_ccopt_property -pin iADC*/ipm_mux0_dont_touch/IMUX2/I0 sink_type ignore
  #set_ccopt_property -pin iPI_*/ia_nd_clk_in/U1/I sink_type stop 
  #set_ccopt_property -pin */iPM/*/CP sink_type ignore 
 
  #create_ccopt_skew_group -name pi_clk_0/merged -balance_skew_group {clk_slice_0/func clk_sw_0/func} -target_skew 0.005 
  #create_ccopt_skew_group -name pi_clk_1/merged -balance_skew_group {clk_slice_1/func clk_sw_1/func} -target_skew 0.005 
  #create_ccopt_skew_group -name pi_clk_2/merged -balance_skew_group {clk_slice_2/func clk_sw_2/func} -target_skew 0.005 
  #create_ccopt_skew_group -name pi_clk_3/merged -balance_skew_group {clk_slice_3/func clk_sw_3/func} -target_skew 0.005 

  source ${scrDir}/path_groups.tcl
 
  #source ${scrDir}/floorplan/clk_tree_acore.tcl 
  ccopt_design 
  
  saveDesign ${saveDir}/${vars(db_name)}.enc
  timeDesign -postCTS -expandedViews -numPaths 500 -outDir RPT/${vars(db_name)}
  
####################################################
## Run time                                       ##
####################################################
set stop_time [clock seconds]
set elapsedTime [clock format [expr $stop_time - $start_time] -format %H:%M:%S -gmt true]
puts "=============================================="
puts "         Completed step : $STAGE"
puts "        Elapsed runtime : $STAGE: $elapsedTime"
puts "=============================================="
exec /bin/date > ${STAGE}.time
exec echo "Elapsed runtime : $STAGE: $elapsedTime" >> ${STAGE}.time
###################################################
}





