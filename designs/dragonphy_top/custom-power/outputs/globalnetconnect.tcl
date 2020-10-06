#=========================================================================
# globalnetconnect.tcl
#=========================================================================
# Author : Christopher Torng
# Date   : January 13, 2020

#-------------------------------------------------------------------------
# Global net connections for PG pins
#-------------------------------------------------------------------------
globalNetConnect DVDD -type pgpin -pin VDD -inst * -override
globalNetConnect DVSS -type pgpin -pin VSS -inst * -override
globalNetConnect DVDD -type pgpin -pin VPP -inst * -override
globalNetConnect DVSS -type pgpin -pin VBB -inst * -override

globalNetConnect CVDD -type pgpin -pin CVDD1 -inst {imdll} -override
globalNetConnect CVDD -type pgpin -pin CVDD2 -inst {imdll} -override
globalNetConnect DVDD -type pgpin -pin DVDD -inst {imdll} -override
globalNetConnect DVSS -type pgpin -pin DVSS -inst {imdll} -override


globalNetConnect DVDD -type pgpin -pin DVDD -inst {iacore} -override
globalNetConnect DVSS -type pgpin -pin DVSS -inst {iacore} -override

globalNetConnect AVDD -type pgpin -pin AVDD -inst {iacore} -override
globalNetConnect AVSS -type pgpin -pin AVSS -inst {iacore} -override

globalNetConnect CVDD -type pgpin -pin CVDD -inst {iacore} -override
globalNetConnect CVSS -type pgpin -pin CVSS -inst {iacore} -override

globalNetConnect DVDD -type pgpin -pin avdd -inst {*ibuf_*} -override
globalNetConnect DVSS -type pgpin -pin avss -inst {*ibuf_*} -override

# TODO: are special net connections needed for the MDLL?
#
#globalNetConnect VDD    -type pgpin -pin VDD    -inst * -verbose
#globalNetConnect VSS    -type pgpin -pin VSS    -inst * -verbose

#if { [ lindex [dbGet top.insts.cell.pgterms.name VNW] 0 ] != 0x0 } {
#  globalNetConnect VDD    -type pgpin -pin VNW    -inst * -verbose
#  globalNetConnect VSS    -type pgpin -pin VPW    -inst * -verbose
#}


