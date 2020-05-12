# Modified from Garnet

set sram_lib_name "sram_$::env(sram_word_size)_$::env(sram_num_words)_$::env(sram_tech_name)_TT_1p0V_25C"

enable_write_lib_mode
read_lib "../outputs/sram_tt.lib"
write_lib -format db "${sram_lib_name}_lib" -output "../outputs/sram_tt.db"

exit