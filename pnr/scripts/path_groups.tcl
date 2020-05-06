setAnalysisMode -honorClockDomains false
reset_path_group -all
resetPathGroupOptions

####
set regs [filter_collection [all_registers -edge_triggered -latches] "is_integrated_clock_gating_cell != true"]
set clkgates [filter_collection [all_registers -edge_triggered] "is_integrated_clock_gating_cell == true"]

set inputs [all_inputs -no_clocks]
set outputs [all_outputs]

###

if {[llength $inputs] && [llength $outputs]} {
   group_path -name in2out -from $inputs -to $outputs
}

if {[llength $inputs] && [llength $regs]} {
   group_path -name in2reg -from $inputs -to $regs
}

if {[llength $regs] && [llength $outputs]} {
   group_path -name reg2out -from $regs  -to $outputs
}

if {[llength $regs]} {
   group_path -name reg2reg -from $regs -to $regs
}

if {[llength $regs] && [llength $clkgates]} {
   group_path -name reg2clkgate -from $regs -to $clkgates
}

if {[llength $inputs] && [llength $clkgates]} {
   group_path -name in2clkgate -from $inputs -to $clkgates
}

foreach group [list reg2reg reg2clkgate] {
   setPathGroupOptions $group -effortLevel high -targetSlack 0.0 -criticalRange 1.0
}

reportPathGroupOptions


