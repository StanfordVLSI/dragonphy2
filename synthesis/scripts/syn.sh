
#!/bin/sh

DESIGN=$1
aprDir=$PWD/../..
srcDir="${aprDir}/vlog/new_chip_src/analog_core"
synDir="${aprDir}/synthesis"
resultDir="${synDir}/${DESIGN}/DC_WORK/${DESIGN}/results"
pnrDir="${aprDir}/pnr"

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
if [ $DESIGN == "phase_blender" ] || [ $DESIGN == "mux_network" ] || [ $DESIGN == "mux4_gf_1st" ] || [ $DESIGN == "wallace_adder" ] || [ $DESIGN  == "V2T" ] || [ $DESIGN == "V2T_clock_gen" ] || [ $DESIGN == "V2T_clock_gen_S2D" ] || [ $DESIGN == "gate_size_test" ] || [ $DESIGN == "stochastic_adc_PR" ] || [ $DESIGN == "phase_interpolator" ] || [ $DESIGN == "analog_core" ] || [ $DESIGN == "top" ]
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

if [ $DESIGN == "gate_size_test" ]
  then
  SRC_PATH=${srcDir}"/../../new_chip_stubs"
else
  SRC_PATH=${srcDir} 
fi

mkdir -p $synDir/$DESIGN
\cp Makefile_templete ${synDir}/$DESIGN/Makefile
\cp run_dc_templete.tcl ${synDir}/$DESIGN/run_dc.tcl
cd $synDir/$DESIGN
sed -i s,source_path,${SRC_PATH}, Makefile
sed -i s,DesignName,${DESIGN}, Makefile
sed -i s,NEED_SDC,${NEED_CONSTRAINTS}, Makefile

#sed -i '3 a set mvt_target_libs [concat $ulvt_slow_db]' run_dc.tcl



make cleanall > clean.log
make

\cp ${resultDir}/${DESIGN}.mapped.v ${pnrDir}/data/mapped_verilog/ 
\cp ${resultDir}/${DESIGN}.mapped.sdc ${pnrDir}/data/sdc/ 

