# Adapted from Garnet

# Determine the name of the SRAM library
set sram_lib_name "ts1n16ffcllsblvtc$::env(sram_num_words)x$::env(sram_word_size)m$::env(sram_mux_size)s"
if {$::env(sram_partial_write)} {
  set sram_lib_name "${sram_lib_name}w"
}
set sram_lib_name "${sram_lib_name}_$::env(sram_corner)"

# Enable library "write" mode -- this must be done before reading a library if
# the user intends to write a library
enable_write_lib_mode

# Read the SRAM *.lib file (output of memory compiler)
read_lib ../../outputs/sram_small_tt.lib

# Write a *.db file for the SRAM
write_lib -format db $sram_lib_name -output ../../outputs/sram_small_tt.db

exit
