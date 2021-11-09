suppress_message [list PSYN-650 PSYN-651  PARA-047 PSYN-025 PSYN-024]

set aprDir ./

set svt_db $env(TCBN16FFC_SVT_DB)
set lvt_db $env(TCBN16FFC_LVT_DB)
set ulvt_db $env(TCBN16FFC_ULVT_DB) 

set svt [file rootname [file tail $svt_db]]
set lvt [file rootname [file tail $lvt_db]]
set ulvt [file rootname [file tail $ulvt_db]]


if { $env(TSMC_STDLIB_PREFIX) == "tcbn16ffcllbwp16p90" } {
  set svt_cell_suffix BWP16P90 
  set lvt_cell_suffix BWP16P90LVT 
  set ulvt_cell_suffix BWP16P90ULVT 
} elseif  { $env(TSMC_STDLIB_PREFIX) == "tcbn16ffcllbwp16p90cpd" } {
  set svt_cell_suffix BWP16P90CPD
  set lvt_cell_suffix BWP16P90CPDLVT
  set ulvt_cell_suffix BWP16P90CPDULVT
}



# Missing Sampling Switch lib/db file here



set libs_dbs [ list $svt_db $lvt_db $ulvt_db]




# set milkyway reference library database
set mw_ref_lib_dbs [ list \
    $env(TCBN16FFC_SVT_MW) \
    $env(TCBN16FFC_LVT_MW) \
    $env(TCBN16FFC_ULVT_MW) \
]



# set target library
set mvt_target_libs [concat $svt_db $lvt_db $ulvt_db]

# set link library to all the library dbs
set synthetic_library [list dw_foundation.sldb]
set link_libs [concat * $libs_dbs $synthetic_library];

# select libraries
set target_library [set mvt_target_libs]
set link_library [set link_libs]

set min_library             ""  ;#  List of max min library pairs "max1 min1 max2 min2 max3 min3" in ICC ...
foreach wc_lib_db $libs_dbs {
  lappend min_library $wc_lib_db
}

set library_name $svt 
if { $env(TSMC_STDLIB_PREFIX) == "tcbn16ffcllbwp16p90" } {
  set driver_cell "INVD1BWP16P90"
} elseif  { $env(TSMC_STDLIB_PREFIX) == "tcbn16ffcllbwp16p90cpd" } {
  set driver_cell "INVD1BWP16P90CPD"
}



########################
# ICC RELATED PARAMETERS
########################

set icc_tech_file  ./inputs/adk/rtk-tech.tf
set icc_map_file   /tsmc16/pdk/latest/rc/star_rcxt/typical/Reference/bin/TSMC_AUTORUN_CCI_STARRC/starrcxt_mapping ;#  Mapping file for TLUplus
set icc_tluplus_max_file  ./inputs/adk/rtk-max.tluplus ;#  Max TLUplus file
set icc_tluplus_min_file  ./inputs/adk/rtk-min.tluplus ;#  Min TLUplus file
set icc_gds_map_file      ./inputs/adk/rtk-stream-out.map ; # Layer Mapping file from ICC (Astro) to GDS

# metals
set metal_min 1   ;# Min routing metal layer level
set metal_max 6   ;# Max routing metal layer level

set cts_metals "" ;# metal layers for CTS
for {set i 3} { $i <= $metal_max} {incr i} {
  lappend cts_metals $i
}

# metal space and width being referred in routing rules
set minspace_m3 0.032
set minspace_m4 0.040
set minspace_m5 0.040
set minspace_m6 0.040
set minspace_m7 0.040
set minspace_m8 0.360
set minspace_m9 0.360

# cells

# for CTS
set cts_cells []
set cts_cells_buf []
set cts_cells_inv []
set cts_cells_else []
foreach i [list 2 3 4 5 6 8 10 12 14 16 18 20 24] {
  lappend cts_cells_inv $svt/CKND$i$svt_cell_suffix
  lappend cts_cells_inv $lvt/CKND$i$lvt_cell_suffix
  #lappend cts_cells_inv $ulvt_slow/CKND$i$ulvt_cell_suffix
}
foreach i [list 2 3 4 5 6 8 10 12 14 16 18 20 24] {
  lappend cts_cells_buf $svt/CKBD$i$svt_cell_suffix
  lappend cts_cells_buf $lvt/CKBD$i$lvt_cell_suffix
  #lappend cts_cells_buf $ulvt_slow/CKBD$i$ulvt_cell_suffix
}
foreach i [list 1 2 4 8] {
  lappend cts_cells_else $svt/CKAN2D$i$svt_cell_suffix
  lappend cts_cells_else $lvt/CKAN2D$i$lvt_cell_suffix
  #lappend cts_cells_else $ulvt_slow/CKAN2D$i$ulvt_cell_suffix
  lappend cts_cells_else $svt/CKND2D$i$svt_cell_suffix
  lappend cts_cells_else $lvt/CKND2D$i$lvt_cell_suffix
  #lappend cts_cells_else $ulvt_slow/CKANDD$i$ulvt_cell_suffix
  lappend cts_cells_else $svt/CKNR2D$i$svt_cell_suffix
  lappend cts_cells_else $lvt/CKNR2D$i$lvt_cell_suffix
  #lappend cts_cells_else $ulvt_slow/CKANRD$i$ulvt_cell_suffix
  lappend cts_cells_else $svt/CKOR2D$i$svt_cell_suffix
  lappend cts_cells_else $lvt/CKOR2D$i$lvt_cell_suffix
  #lappend cts_cells_else $ulvt_slow/CKAORD$i$ulvt_cell_suffix
  lappend cts_cells_else $svt/CKXOR2D$i$svt_cell_suffix
  lappend cts_cells_else $lvt/CKXOR2D$i$lvt_cell_suffix
  #lappend cts_cells_else $ulvt_slow/CKAXORD$i$ulvt_cell_suffix
}

set cts_cells [concat $cts_cells_inv $cts_cells_buf]
set cts_delay_cells $cts_cells_buf
set cts_resizing_cells [concat $cts_cells $cts_cells_else]


set hold_buffer []
foreach i [list 1 2 3 4 5 6 8 10 12 14 16 18] {
  lappend hold_buffer $svt/BUFFD$i$svt_cell_suffix
}


# for ANTENNA FIX
set ant_diode "$svt/ANTENNA$svt_cell_suffix"
set core_filler []
foreach i [list 1 2 3 4 8 16 32 64] {
  lappend core_filler $svt/FILL$i$svt_cell_suffix
}


set bd_nrow []
set bd_prow []
foreach i [list 1 2 3 4] {
  lappend bd_nrow BOUNDARY_NROW$i$svt_cell_suffix
}
foreach i [list 1 2 3 4] {
  lappend bd_prow BOUNDARY_PROW$i$svt_cell_suffix
}
set bd_left BOUNDARY_LEFT$svt_cell_suffix
set bd_right BOUNDARY_RIGHT$svt_cell_suffix
set bd_ncorner BOUNDARY_NCORNER$svt_cell_suffix
set bd_pcorner BOUNDARY_PCORNER$svt_cell_suffix
set bd_ntap BOUNDARY_NTAP$svt_cell_suffix
set bd_ptap BOUNDARY_PTAP$svt_cell_suffix
set bd_in_corner FILL3$svt_cell_suffix 
set bd_rules ""



set bd_tap_distance 10.08 ; # multiples of .63
set bd_min_row_width 1.26 ; 

# PNS

set power_supply_voltage 0.8
