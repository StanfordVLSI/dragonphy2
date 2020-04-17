# create virtual environment
$DRAGONPHY_PYTHON -m venv venv
source venv/bin/activate

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
git clone --single-branch --branch pli_workaround https://github.com/StanfordVLSI/DaVE.git
export mLINGUA_DIR=`realpath DaVE/mLingua`

# install dragonphy
pip install -e .

# make dependencies for design
# TODO: should other views be used as well?
python make.py --view fpga

# install pytest
pip install pytest pytest-cov

# run tests
pytest tests -s -v -r s --cov-report=xml --cov=dragonphy --durations=0

# upload coverage
bash <(curl -s https://codecov.io/bash)

# deactivate virtual env
deactivate
