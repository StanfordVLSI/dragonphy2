
# load library
source $SYNTH_HOME/scripts/load_tsmc16.tcl

# Load dc files names
source $SYNTH_HOME/scripts/dc_setup_filenames.tcl

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
