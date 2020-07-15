# upgrade pip
pip install -U pip

# install Genesis2
git clone https://github.com/StanfordVLSI/Genesis2.git
export GENESIS_HOME=`realpath Genesis2/Genesis2Tools`
export PERL5LIB="$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions"
export PATH="$GENESIS_HOME/bin:$PATH"
export PATH="$GENESIS_HOME/gui/bin:$PATH"
/bin/rm -rf $GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions/Compress

# install DaVE
# TODO: install from master branch
git clone --single-branch --branch move_to_python3 https://github.com/StanfordVLSI/DaVE.git
export mLINGUA_DIR=`realpath DaVE/mLingua`
#export DAVE_INST_DIR=`realpath DaVE`
#export PYTHONPATH="${DAVE_INST_DIR}:$PYTHONPATH"
pushd DaVE
pip install -e .
popd


# install dragonphy
pip install -e .

# install pytest
pip install pytest pytest-cov

# run tests
if [[ -z "${FPGA_SERVER}" ]]; then
    python make.py --view cpu
    pytest tests/other_tests tests/cpu_block_tests tests/cpu_system_tests \
        tests/fixture_tests \
        -s -v -r s --cov-report=xml --cov=dragonphy --durations=0
else
    python make.py --view fpga
    pytest tests/fpga_system_tests \
        -s -v -r s --cov-report=xml --cov=dragonphy --durations=0
fi

# upload coverage
bash <(curl -s https://codecov.io/bash)
