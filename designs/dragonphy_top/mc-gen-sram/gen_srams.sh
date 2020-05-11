# Adapted from Garnet

# Note: you'll need to add a link called "mc" in the mc-sram-sram directory
# in order for this script to work

# Write config file for the memory compiler
# This specifies the dimensions of the SRAM
echo "${sram_num_words}x${sram_word_size}m${mux_size}s" >> config.txt

# Set some environment variables
export MC_HOME=mc/tsn16ffcllhdspsbsram_20131200_130a
export PATH="${PATH}:mc/MC2_2013.12.00.f/bin"

# Determine the name of the SRAM
sram_name="ts1n16ffcllsblvtc${sram_num_words}x${sram_word_size}m${sram_mux_size}s"
if [ $sram_partial_write == True ]; then
  sram_name+="w"
fi
sram_name+="_130a"

# Build up the command to run the memory compiler
cmd="./mc/tsn16ffcllhdspsbsram_130a.pl -file config.txt -NonBIST -NonSLP -NonDSLP -NonSD"
if [ ! $sram_partial_write == True ]; then
  cmd+=" -NonBWEB"
fi

# Actually run the memory compiler
eval $cmd

# Link output products from the memory compiler into the "outputs" folder
ln -s ../$sram_name/NLDM/${sram_name}_${sram_corner}.lib outputs/sram_tt.lib
ln -s ../$sram_name/GDSII/${sram_name}_m4xdh.gds outputs/sram.gds
ln -s ../$sram_name/LEF/${sram_name}_m4xdh.lef outputs/sram.lef
ln -s ../$sram_name/VERILOG/${sram_name}_pwr.v outputs/sram_pwr.v
ln -s ../$sram_name/VERILOG/${sram_name}.v outputs/sram.v
ln -s ../$sram_name/SPICE/${sram_name}.spi outputs/sram.spi

# Run a separate script to generate a *.db file for the SRAM
cd lib2db/
make
cd ..