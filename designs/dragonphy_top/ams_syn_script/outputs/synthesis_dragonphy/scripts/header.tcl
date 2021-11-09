
# load library
source ../../../../inputs/synthesis_dragonphy/scripts/load_tech.tcl

# Load dc files names
source ../../../../inputs/synthesis_dragonphy/scripts/dc_setup_filenames.tcl

# other settings
if {![info exists nCores]} {
  set nCores 2
}
set_host_options -max_cores $nCores

if {![info exists SYNTH_RESULTS]} {
  set SYNTH_RESULTS results
}

if {![info exists SYNTH_REPORTS]} {
  set SYNTH_REPORTS reports
}

if { ! [file exists $SYNTH_RESULTS] } {
  file mkdir $SYNTH_RESULTS
}

if { ! [file exists $SYNTH_REPORTS] } {
  file mkdir $SYNTH_REPORTS
}
