// SV flag is needed since some *.v files are actually
// SystemVerilog files
-sv
-64bit
-seed random

// include paths
//-incdir ${mLINGUA_DIR}/samples


// extensions for library files
+libext+.v
+libext+.sv
+libext+.vp

//FFE Files
-y ../../rtl

// the TAP controller has to stay on our server, sorry :-(
//-v /cad/synopsys/syn/L-2016.03-SP5-5/dw/sim_ver/DW_tap.v


// tb sources
//-y ../../tb

// test sources
*.*v
