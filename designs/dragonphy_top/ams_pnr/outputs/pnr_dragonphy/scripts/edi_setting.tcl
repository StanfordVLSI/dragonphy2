set_global report_timing_format {instance arc cell delay incr_delay arrival slew fanout load instance_location user_derate aocv_derate phase}
set_table_style -name report_timing -no_frame

setDistributeHost -local
setMultiCpuUsage -localCpu 5

#BCLIM: original flowEffort value was wrong
#setDesignMode -process 16 -flowEffort high
setDesignMode -process 5 -flowEffort standard

setTieHiLoMode -reset
setPlaceMode -reset
setTrialRouteMode -reset
setOptMode -reset
setNanoRouteMode -reset


## PlaceMode ##
setPlaceMode -adaptive true
setPlaceMode -checkPinLayerForAccess {1 2} 
setPlaceMode -dptFlow true 
setPlaceMode -colorAwareLegal true
setPlaceMode -RTCSpread true
setPlaceMode -coreEffort high
setPlaceMode -checkCutSpacing true
setPlaceMode -congEffort high
#setPlaceMode -congRepairEffort high ; # Obsolete
setPlaceMode -placeIoPins false

setPlaceMode -allowUseFiller1 true
setPlaceMode -checkImplantWidth true 
setPlaceMode -checkImplantMinArea true
setPlaceMode -checkDiffusionWidth true
setPlaceMode -checkUTLshapeOD true
setPlaceMode -honor_implant_Jog_exception true
setPlaceMode -honorImplantJog true
setPlaceMode -honorImplantSpacing true





## TrialRoute Mode ##
setTrialRouteMode -useM1 false
set trialRoutePrivate::dontUseM1WireStrictly 1
setTrialRouteMode -maxRouteLayer $maxLayer
setTrialRouteMode -minRouteLayer 2 
setTrialRouteMode -routeObs false 

## OptMode ##
setOptMode -fixFanoutLoad true
setOptMode -clkGateAware false
setOptMode -reclaimArea true
setOptMode -postRouteAreaReclaim setupAware
setOptMode -fixSIAttacker true

## NanoRoute  mode ##
setNanoRouteMode -drouteOnGridOnly {wire 4:7 via 3:6}
setNanoRouteMode -routeWithViaInPin {1:1}
setNanoRouteMode -routeTopRoutingLayer $maxLayer
setNanoRouteMode -routeBottomRoutingLayer 2
setNanoRouteMode -droutePostRouteSpreadWire false
setNanoRouteMode -dbViaWeight {*_P* -1}
setNanoRouteMode -routeExpAdvancedTechnology true
setNanoRouteMode -routeReserveSpaceForMultiCut false
setNanoRouteMode -routeWithSiDriven false
setNanoRouteMode -routeWithTimingDriven false
setNanoRouteMode -routeAutoPinAccessForBlockPin true
setNanoRouteMode -routeConcurrentMinimizeViaCountEffort high
setNanoRouteMode -droutePostRouteSwapVia false
setNanoRouteMode -routeExpUseAutoVia true
setNanoRouteMode -drouteExpAdvancedMarFix true



## SIMode ##
setSIMode -analysisType AAE
setSIMode -separate_delta_delay_on_data true -delta_delay_annotation_mode lumpedOnNet
setSIMode -individual_attacker_simulation_filtering true


