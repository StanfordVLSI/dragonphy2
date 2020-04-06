# create virtual environment
$DRAGONPHY_PYTHON -m venv venv
source venv/bin/activate

# upgrade pip
pip install -U pip

# install Genesis2
# TODO: simplify install
git clone https://github.com/StanfordVLSI/Genesis2.git
export GENESIS_HOME=`realpath Genesis2/Genesis2Tools`
export PERL5LIB="$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions"
export PATH="$GENESIS_HOME/bin:$PATH"
export PATH="$GENESIS_HOME/gui/bin:$PATH"
/bin/rm -rf $GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions/Compress

# install JusTAG
# TODO: install from pip as a dependency
git clone --single-branch --branch dragonphy_integration https://github.com/StanfordVLSI/JusTAG.git
export JUSTAG_DIR=`realpath JusTAG`
cd JusTAG
pip install -e .
cd ..

# install DaVE
# TODO: install from master branch
git clone --single-branch --branch pli_workaround https://github.com/StanfordVLSI/DaVE.git
export mLINGUA_DIR=`realpath DaVE/mLingua`

# install dragonphy
pip install -e .

# build JTAG
# TODO: move into build flow
export DRAGONPHY_TOP=`realpath .`
mkdir -p ${DRAGONPHY_TOP}/build/jtag
cd build/jtag
python ${JUSTAG_DIR}/JusTAG.py ${DRAGONPHY_TOP}/md/reg/*.md ${DRAGONPHY_TOP}/vlog/old_pack/all/const_pack.sv
export TOP_NAME=raw_jtag
export PRIM_DIR=${JUSTAG_DIR}/rtl/primitives
export DIGT_DIR=${JUSTAG_DIR}/rtl/digital
export VERF_DIR=${JUSTAG_DIR}/verif
export SVP_FILES="${DIGT_DIR}/${TOP_NAME}.svp ${PRIM_DIR}/cfg_ifc.svp ${DIGT_DIR}/${TOP_NAME}_ifc.svp ${PRIM_DIR}/flop.svp ${DIGT_DIR}/tap.svp ${DIGT_DIR}/cfg_and_dbg.svp ${PRIM_DIR}/reg_file.svp"
Genesis2.pl -parse -generate -top ${TOP_NAME} -input ${SVP_FILES}
Genesis2.pl -parse -generate -top JTAGDriver -input ${VERF_DIR}/JTAGDriver.svp
mkdir -p ${DRAGONPHY_TOP}/build/old_cpu_models/jtag
mv jtag_reg_pack.sv ${DRAGONPHY_TOP}/build/old_cpu_models/jtag/.
mkdir -p ${DRAGONPHY_TOP}/build/old_tb
mv genesis_verif/JTAGDriver.sv ${DRAGONPHY_TOP}/build/old_tb/jtag_drv_pack.sv
mkdir -p ${DRAGONPHY_TOP}/build/old_chip_src/jtag
mv genesis_verif/* {$DRAGONPHY_TOP}/build/old_chip_src/jtag/.
cd ${DRAGONPHY_TOP}

# make dependencies for design
# TODO: should other views be used as well?
python make.py --view fpga

# install pytest
pip install pytest pytest-cov

# run tests
pytest tests -x -s -v -r s --cov-report=xml --cov=dragonphy

# upload coverage
bash <(curl -s https://codecov.io/bash)

# deactivate virtual env
deactivate
