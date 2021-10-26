
#!/bin/sh

## --------------------------------
# synthesis (by sjkim)
## ---------------------------------



DESIGN=$1
aprDir="/aha/canswang/apr_flow"
synDir="./synthesis_dragonphy"
resultDir="${synDir}/${DESIGN}/DC_WORK/${DESIGN}/results"
pnrDir="${aprDir}/pnr_dragonphy"

#-----------------------------
# check argument
#-----------------------------
if [ $# -eq 0 ]
  then
    echo "[ERROR] A block name is required as argument for syn.sh"
    exit 1
fi

#-----------------------------
# check constraints file
#-----------------------------
if [ $DESIGN == "phase_blender" ] || [ $DESIGN == "mux4_gf" ] || [ $DESIGN  == "V2T" ] || [ $DESIGN == "gate_size_test" ] || [ $DESIGN == "stochastic_adc_PR" ] || [ $DESIGN == "phase_interpolator" ] || [ $DESIGN == "input_divider" ] || [ $DESIGN == "analog_core" ] || [ $DESIGN = "new_adc" ] 
  then
    NEED_CONSTRAINTS=1
    if [ ! -e ${synDir}/scripts/constraints/${DESIGN}_constraints.tcl ]
      then
      echo "[ERROR] A file [${synDir}/scripts/constraints/${DESIGN}_constraints.tcl] is required "
      exit 1
    fi
else
    NEED_CONSTRAINTS=0
fi


mkdir -p $synDir/$DESIGN
mkdir -p ./outputs/$DESIGN

\cp ./inputs/synthesis_dragonphy/scripts/Makefile_templete ./outputs/$DESIGN/Makefile
\cp ./inputs/synthesis_dragonphy/scripts/run_dc_templete.tcl ./outputs/$DESIGN/run_dc.tcl
echo "I am a the first occurrance!"
cd ./outputs/$DESIGN
sed -i s,source_path,${SRC_PATH}, Makefile
sed -i s,DesignName,${DESIGN}, Makefile
sed -i s,NEED_SDC,${NEED_CONSTRAINTS}, Makefile

#sed -i '3 a set mvt_target_libs [concat $ulvt_slow_db]' run_dc.tcl

echo "Required file has been prepared"
echo "Now, Let's throw the dice!"

make cleanall > clean.log
make

echo "Build finishes..."
echo "Exporting synthesized file to PnR stage..."

\cp ${resultDir}/${DESIGN}.mapped.v ${pnrDir}/data/mapped_verilog/ 
\cp ${resultDir}/${DESIGN}.mapped.sdc ${pnrDir}/data/sdc/ 
sed -i '1i source '"${pnrDir}"'/scripts/floorplan/'"${DESIGN}"'_dont_touch.tcl' ${pnrDir}/data/sdc/${DESIGN}.mapped.sdc



