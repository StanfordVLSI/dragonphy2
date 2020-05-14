set scrDir ./scripts

source ${scrDir}/00_init_design.tcl



#set_dont_touch [list IPI_dchain Imuxnet] 

source ${scrDir}/edi_setting.tcl
########
#BCLIM: complain -useECSMInPreRoute is invalid opt
#setDelayCalMode -engine Aae -SIAware false -signOff true -useECSMInPreRoute true
setDelayCalMode -engine Aae -SIAware false -signOff true 
#######

source ${scrDir}/path_groups.tcl
timeDesign -expandedViews -prePlace -outDir RPT/preplace -numPaths 500

### placement ##
source ${scrDir}/01_place.tcl

#### prects ##
source ${scrDir}/02_prects.tcl

## cts + postcts ##
source ${scrDir}/03_native_ccopt.tcl

### Route ##
source ${scrDir}/04_route.tcl

### postRoute ##
source ${scrDir}/05_postroute.tcl

deleteRouteBlk -name *

selectObstruct 107.8200 695.8080 472.2300 700.4160 defScreenName
deleteSelectedFromFPlan


#### addFiller ##
source ${scrDir}/07_addFiller.tcl

addFiller -cell $filler4 -prefix DCAP_DVDD
addFiller -cell $fillerCell -prefix FILLER
checkFiller

source ${scrDir}/08_editSVIA1.tcl

source ${scrDir}/chip_out.tcl

