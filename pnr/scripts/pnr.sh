#!/bin/sh
#
DESIGN=$1
aprDir=$PWD/../..
pnrDir="${aprDir}/pnr_dragonphy"
lefDir="${pnrDir}/data/lef"
gdsDir="${pnrDir}/data/gds"
POWER_NAME="VDD"
GROUND_NAME="VSS"

#-----------------------------
# check input argument
#-----------------------------
if [ $# -eq 0 ]
  then
    echo "[ERROR] A block name is required as argument for pnr.sh"
    exit 1
fi

#-----------------------------
# check macro definition
#-----------------------------
if [ $DESIGN == "V2T" ] || [ $DESIGN == "biasgen" ] || [ $DESIGN == "stochastic_adc_PR" ] || [ $DESIGN == "PI_delay_chain" ] || [ $DESIGN == "phase_interpolator" ] || [ $DESIGN == "analog_core" ] 
  then
	HAS_MACRO=1
	if [ ! -e ${pnrDir}/scripts/floorplan/${DESIGN}_macro_def.tcl ]
	  then
      echo "[ERROR] A file [./floorplan/${DESIGN}_macro_def.tcl] is required "
   	  exit 1
	fi
else
	HAS_MACRO=0
fi

#-----------------------------
# check floorplan
#-----------------------------
if [ ! -e ${pnrDir}/scripts/floorplan/${DESIGN}_floorplan.tcl ]
  then
    echo "[ERROR] A file [${pnrDir}/scripts/floorplan/${DESIGN}_floorplan.tcl] is required "
    exit 1
fi

#-----------------------------
# check multiple power domain
#-----------------------------
if [ $DESIGN == "V2T" ] || [ $DESIGN == "biasgen" ] || [ $DESIGN == "stochastic_adc_PR" ] || [ $DESIGN == "analog_core" ]
  then
	MULTIPLE_POWER=1
	if [ ! -e ${pnrDir}/scripts/floorplan/${DESIGN}_addFiller.tcl ]
	  then
      echo "[ERROR] A file [./floorplan/${DESIGN}_addFiller.tcl] is required "
   	  exit 1
	fi
	if [ $DESIGN == "V2T" ]
	  then
		POWER_NAME="{VDD Vcal}"
		GROUND_NAME="{VSS}"
	fi
	if [ $DESIGN == "biasgen" ]
	  then
		POWER_NAME="{VDD Vbias}"
		GROUND_NAME="{VSS}"
	fi
	if [ $DESIGN == "stochastic_adc_PR" ] 
	  then
		POWER_NAME="{AVDD DVDD}"
		GROUND_NAME="{AVSS DVSS}"
	fi
	if [ $DESIGN == "analog_core" ]
	  then
		POWER_NAME="{AVDD DVDD CVDD}"
		GROUND_NAME="{AVSS DVSS CVSS}"
	fi
  else
	MULTIPLE_POWER=0
fi

#-----------------------------------
# check top metal bloackage layer
#-----------------------------------
TOP_BLK_LAYER="M7"
if [ $DESIGN == "V2T" ] 
  then
    TOP_BLK_LAYER="M9"
fi

mkdir -p $pnrDir/$DESIGN
\cp ${pnrDir}/scripts/run_all_templete.tcl ${pnrDir}/$DESIGN/${DESIGN}_run_all.tcl
cd $pnrDir/$DESIGN 
sed -i "1 i\#----------------------------------------" ${DESIGN}_run_all.tcl
sed -i "1 i\set pwr_name ${POWER_NAME}" ${DESIGN}_run_all.tcl
sed -i "1 i\set gnd_name ${GROUND_NAME}" ${DESIGN}_run_all.tcl
sed -i "1 i\set MULTIPLE_POWER ${MULTIPLE_POWER}" ${DESIGN}_run_all.tcl
sed -i "1 i\set HAS_MACRO ${HAS_MACRO}" ${DESIGN}_run_all.tcl
sed -i "1 i\set DesignName ${DESIGN}" ${DESIGN}_run_all.tcl
sed -i "1 i\set TOP_BLK_LAYER ${TOP_BLK_LAYER}" ${DESIGN}_run_all.tcl
sed -i "1 i\#---------------- HEADER ----------------" ${DESIGN}_run_all.tcl

#-----------------------------
# run Innovus
#-----------------------------
\rm -rf ./DBS
\rm -f ${DESIGN}_innvus.log
\rm -f ${DESIGN}_drc.log

echo ""
echo "[PnR] Innovus is running for block [$DESIGN] ..."
echo ""
innovus -batch -no_gui -files ${DESIGN}_run_all.tcl -no_logv -overwrite > ${DESIGN}_innovus.log 

if grep -q "PnR is done" ${DESIGN}_innovus.log
then
    echo -e "[PnR] Completed"
	\cp ./results/${DESIGN}.lef $lefDir/${DESIGN}.lef 
	\cp ./results/${DESIGN}_Model/library/${DESIGN}_antenna.lef $lefDir/${DESIGN}_antenna.lef 
	\cp ./results/${DESIGN}.gds $gdsDir/${DESIGN}.gds 
	echo -e "[${DESIGN}.lef] is copied to ${lefDir}"
	echo -e "[${DESIGN}_antenna.lef] is copied to ${lefDir}"
	echo -e "[${DESIGN}.gds] is copied to ${gdsDir}"
else
    echo -e "[PnR] Innonus stopped at stage [x]";
    #echo -e "[PnR] Innonus stopped at stage [${vars(db_name)}]";
fi




#-----------------------------
# run calibre DRC
#-----------------------------
#echo "[DRC] Calibre DRC is running for block [$DESIGN] ..."
#\cp ${pnrDir}/scripts/runset_block_drc_templete ./${DESIGN}_runset_block_drc 
#sed -i s,BLOCK,${DESIGN}, ${DESIGN}_runset_block_drc
#sed -i s,gds_path,${gdsDir}/${DESIGN}.gds, ${DESIGN}_runset_block_drc
#calibre -gui -drc ${DESIGN}_runset_block_drc -batch > ${DESIGN}_drc.log 
#echo "[RVE] Launching RVE window for block [$DESIGN] ..."


#-----------------------------
# run Calinre LVS
#-----------------------------
#echo "[LVS] Calibre LVS is running for block [$DESIGN] ..."
#calibre -gui -lvs ${DESIGN}_runset_lvs -batch > ${DESIGN}_lvs.log 

#-----------------------------
# run Calinre RVE
#-----------------------------


