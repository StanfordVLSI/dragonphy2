proc check {status} {
	if {$status != 1} {
		exit 1
	}
}

set search_path [list {.} {../../inc/net}]

set file_list [concat \
[glob ../../pack/all/*.*v] \
[glob ../../src/calib_pfd_offset/all/*.*v] \
[glob ../../src/common/all/*.*v] \
[glob ../../src/sram/all/*.*v] \
[glob ../../src/sram/net/*.*v] \
[glob ../../src/jtag/all/*.*v] \
[glob ../../src/jtag/generate/*.*v] \
[glob ../../src/mm_cdr/all/*.*v] \
[glob ../../src/digital_core/all/*.*v] \
[glob ../../src/analog_core/all/acore_debug_intf.sv] \
[glob ../../src/top/all/*.*v] \
[glob /cad/synopsys/syn/L-2016.03-SP5-5/dw/sim_ver/DW_tap.v] \
]

check [analyze -format sverilog $file_list]

check [elaborate butterphy_top]

exit 0
