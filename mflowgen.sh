# upgrade pip
pip install -U pip

# install Genesis2
git clone https://github.com/StanfordVLSI/Genesis2.git
export GENESIS_HOME=`realpath Genesis2/Genesis2Tools`
export PERL5LIB="$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions"
export PATH="$GENESIS_HOME/bin:$PATH"
export PATH="$GENESIS_HOME/gui/bin:$PATH"
/bin/rm -rf $GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions/Compress

# install mflowgen
git clone https://github.com/cornell-brg/mflowgen
cd mflowgen
pip install -e .
cd ..

# install OpenRAM
git clone https://github.com/VLSIDA/OpenRAM.git
export OPENRAM_HOME=`realpath OpenRAM/compiler`
export OPENRAM_TECH=`realpath OpenRAM/technology`

# install dragonphy
pip install -e .

# make dependencies for design
# TODO: should other views be used as well?
python make.py --view asic
python make.py --view fpga
python make.py --view cpu

# run mflowgen
mkdir -p build/mflowgen_dragonphy_top
cd build/mflowgen_dragonphy_top
mflowgen run --design ../../designs/dragonphy_top
make cadence-innovus-place
cd ../..
