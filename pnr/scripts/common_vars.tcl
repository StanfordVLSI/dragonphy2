
setMultiCpuUsage -localCpu 5

#-----------------------------------------------------------------------
# paths
#-----------------------------------------------------------------------
set pnrDir ${aprDir}/pnr_dragonphy
set procDir ${pnrDir}/data/process
set verilogDir ${pnrDir}/data/mapped_verilog
set sdcDir ${pnrDir}/data/sdc
set ioDir ${pnrDir}/data/io_files
set scrDir  ${pnrDir}/scripts
set macroDir ${pnrDir}/data/analog_macros
set lefDir ${pnrDir}/data/lef
set gdsDir ${pnrDir}/data/gds
set libDir ${pnrDir}/data/lib
set ilmDir ${pnrDir}/data/ilm
set saveDir ./DBS
set resDir  ./results


#-----------------------------------------------------------------------
# process settings
#-----------------------------------------------------------------------
set tlef ${procDir}/N16_Encounter_9M_2Xa1Xd3Xe2Z_UTRDL_9T_PODE_1.2a.tlef
set lef [list ${procDir}/tcbn16ffcllbwp16p90.lef ${procDir}/tcbn16ffcllbwp16p90lvt.lef ${procDir}/tcbn16ffcllbwp16p90ulvt.lef]

set wc_lib [list ${procDir}/tcbn16ffcllbwp16p90ssgnp0p72v125c_ecsm.lib ${procDir}/tcbn16ffcllbwp16p90lvtssgnp0p72v125c_ecsm.lib ${procDir}/tcbn16ffcllbwp16p90ulvtssgnp0p72v125c_ecsm.lib ${libDir}/PI_delay_unit.lib ${libDir}/V2T.lib ${libDir}/SW.lib ${libDir}/input_buffer.lib ${libDir}/biasgen.lib ]
set bc_lib [list ${procDir}/tcbn16ffcllbwp16p90ffgnp0p88v0c_ecsm.lib ${procDir}/tcbn16ffcllbwp16p90lvtffgnp0p88v0c_ecsm.lib ${procDir}/tcbn16ffcllbwp16p90ulvtffgnp0p88v0c_ecsm.lib ${libDir}/PI_delay_unit.lib ${libDir}/V2T.lib ${libDir}/SW.lib ${libDir}/input_buffer.lib ${libDir}/biasgen.lib]
set qrc_cworst_CC ${procDir}/qrcTechFile_cworst_CC
set qrc_rcworst_CC ${procDir}/qrcTechFile_rcworst_CC
set qrc_cbest_CC ${procDir}/qrcTechFile_cbest_CC
set qrc_rcbest_CC ${procDir}/qrcTechFile_rcbest_CC
set gds_files [list ${procDir}/tcbn16ffcllbwp16p90.gds ${procDir}/tcbn16ffcllbwp16p90lvt.gds ${procDir}/tcbn16ffcllbwp16p90ulvt.gds ]

#-----------------------------------------------------------------------
# library variables
#-----------------------------------------------------------------------
set maxLayer 8 ; # this needs to be event number
set cell_height 0.576
set cell_grid 0.09
set welltap_width 0.72
set DB_width 0.36
set pin_width 0.038
set pin_depth 0.194
set metal_space 0.08
set V2T_MS_net_width 0.16
set PI_MS_net_width 0.064

#-----------------------------------------------------------------------
# add macro lef/gds
#-----------------------------------------------------------------------
if {[info exists ip_lef]} {
	foreach l $ip_lef {
		lappend lef $l
	}
}
if {[info exists ip_gds]} {
	foreach l $ip_gds {
		lappend gds_files $l
	}
}
#-----------------------------------------------------------------------
# analog macro variables
#-----------------------------------------------------------------------
set SW_width 2.494
set SW_height 2.88
set SW_pin_depth 0.6
set SW_pin_width 0.36
set SW_pin_length 1.3
set MOMcap_width 5.13
set MOMcap_height 5.76
set MOMcap_pin_depth 0.3
set MOMcap_pin_width 0.2

set CS_cell_width 1.876
set CS_cell_height 1.152
set CS_cell_dmm_width 0.413
set CS_cell_dmm_height $CS_cell_height

set termination_width 67.23
set termination_height 5.76

set diff_amp_width 10.8
set diff_amp_height [expr 12*$cell_height]

set input_buffer_width 18.0
set input_buffer_height [expr 26*$cell_height]

#-----------------------------------------------------------------------
# design variables
#-----------------------------------------------------------------------
set topCell      ${DesignName}
set floorplan    ${pnrDir}/data/${DesignName}.def
set sdc(prects)  ${sdcDir}/${DesignName}.mapped.sdc
set sdc(postcts) ${sdcDir}/${DesignName}.mapped.sdc
set iofile       ${ioDir}/${DesignName}.io
set netlist 	 ${verilogDir}/${DesignName}.mapped.v

#-----------------------------------------------------------------------
# other variables
#-----------------------------------------------------------------------
set max_tran 0.05
set utill 0.7

set AVDD_M7_width 1.6
set AVDD_M7_space 0.5
set DVDD_M7_width 0.6
set DVDD_M7_space 1.0

set AVDD_M8_width 1.6
set AVDD_M8_space 0.5
set DVDD_M8_width 2.0
set DVDD_M8_space 1.0

set M9_width 4.0
set M9_space 2.0


