
set aprDir /aha/sjkim85/apr_flow

## macro definition (sub-modules)
if { ${HAS_MACRO} == 1 } {
source ${aprDir}/pnr_dragonphy/scripts/floorplan/${DesignName}_macro_def.tcl
}

## common variables
source ${aprDir}/pnr_dragonphy/scripts/common_vars.tcl

## initialize design
source ${scrDir}/00_init_design.tcl



## load floorplan
source ${scrDir}/floorplan/${DesignName}_floorplan.tcl


#DONT TOUCH
set_dont_touch [get_cells -hierarchical *dont_touch*]


source ${scrDir}/edi_setting.tcl
setDelayCalMode -engine Aae -SIAware false -signOff true 
source ${scrDir}/path_groups.tcl
timeDesign -expandedViews -prePlace -outDir RPT/preplace -numPaths 500

## placement ##
source ${scrDir}/01_place.tcl

## prects ##
source ${scrDir}/02_prects.tcl

## cts + postcts ##
source ${scrDir}/03_native_ccopt.tcl

## Route ##
source ${scrDir}/04_route.tcl

## postRoute ##
source ${scrDir}/05_postroute.tcl

## addFiller ##
if { ${MULTIPLE_POWER} == 1 } {
	source ${scrDir}/floorplan/${DesignName}_addFiller.tcl
} else {
	source ${scrDir}/07_addFiller.tcl
}

## fix vias
source ${scrDir}/08_editSVIA1.tcl

## DB out
source ${scrDir}/chip_out.tcl

## generate ILM
createInterfaceLogic -hold -keepAll -dir ${ilmDir}


