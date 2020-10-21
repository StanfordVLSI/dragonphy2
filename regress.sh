# upgrade pip
pip install -U pip

# uncomment to install HardFloat
# wget -O install_hardfloat.sh https://git.io/JJ5YF
# source install_hardfloat.sh

# install Genesis2
git clone https://github.com/StanfordVLSI/Genesis2.git
export GENESIS_HOME=`realpath Genesis2/Genesis2Tools`
export PERL5LIB="$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions"
export PATH="$GENESIS_HOME/bin:$PATH"
export PATH="$GENESIS_HOME/gui/bin:$PATH"
/bin/rm -rf $GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions/Compress

# install DaVE
# TODO: install from master branch
git clone --single-branch --branch pwl_cos https://github.com/StanfordVLSI/DaVE.git
export mLINGUA_DIR=`realpath DaVE/mLingua`

# install dragonphy
pip install -e .

# re-install six
# TODO: why is this necessary?
pip uninstall -y six
pip install six

# install pytest
pip install pytest pytest-cov

# run tests
if [[ -z "${FPGA_SERVER}" ]]; then
    python make.py --view cpu
    pytest tests/other_tests tests/cpu_block_tests tests/cpu_system_tests \
        -s -v -r s --cov-report=xml --cov=dragonphy --durations=0
else
    python make.py --view fpga
    xvfb-run pytest tests/fpga_block_tests tests/fpga_system_tests/emu \
        tests/fpga_system_tests/emu_macro/test_emu_macro.py::test_1 \
        tests/fpga_system_tests/emu_macro/test_emu_macro.py::test_2 \
        -s -v -r s --cov-report=xml --cov=dragonphy --durations=0 -x
fi

# upload coverage
bash <(curl -s https://codecov.io/bash)
