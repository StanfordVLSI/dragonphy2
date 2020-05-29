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
git clone --single-branch --branch pwl_cos https://github.com/StanfordVLSI/DaVE.git
export mLINGUA_DIR=`realpath DaVE/mLingua`

# install dragonphy
pip install -e .

# make dependencies for design
# TODO: should other views be used as well?
python make.py --view asic
python make.py --view fpga
python make.py --view cpu

# install pytest
pip install pytest pytest-cov

# run tests
if [[ -z "${FPGA_SERVER}" ]]; then
    pytest tests/other_tests -s -v -r s --cov-report=xml --cov=dragonphy --durations=0
    pytest tests/cpu_block_tests -s -v -r s --cov-report=xml --cov=dragonphy --durations=0
    pytest tests/cpu_system_tests -s -v -r s --cov-report=xml --cov=dragonphy --durations=0
else
    # pytest tests/fpga_tests -s -v -r s --cov-report=xml --cov=dragonphy --durations=0
fi

# upload coverage
bash <(curl -s https://codecov.io/bash)