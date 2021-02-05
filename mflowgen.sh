# upgrade pip
pip install -U pip

# install Genesis2
git clone https://github.com/StanfordVLSI/Genesis2.git
export GENESIS_HOME=`realpath Genesis2/Genesis2Tools`
export PERL5LIB="$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions"
export PATH="$GENESIS_HOME/bin:$PATH"
export PATH="$GENESIS_HOME/gui/bin:$PATH"
/bin/rm -rf $GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions/Compress

# temporary fix
pip install cvxpy==1.1.7

# install mflowgen
git clone https://github.com/cornell-brg/mflowgen
cd mflowgen
pip install -e .
cd ..

# install dragonphy
pip install -e .

# make dependencies for design
python make.py --view asic

# run mflowgen
mkdir -p build/mflowgen_dragonphy_top
cd build/mflowgen_dragonphy_top
mflowgen run --design ../../designs/dragonphy_top
make synopsys-dc-synthesis
cd ../..
