################################################################
# Setup scripts for bridging the AMS flow with TSMC16 library  #
# Adopted from Sungjin-KIM                                     #
# By Can Wang                                                  #
# 7th, Nov, 2021                                               #
################################################################


setenv TSMCHOME ../../../../inputs/adk
setenv METALTOP 9 # top metal layer (9, 10, 11, 13 etc,.)
setenv TSMC_STDLIB_PREFIX tcbn16ffcllbwp16p90

# Set the .db file for best case & worst case of the I/O library

setenv TPHN16FFC $TSMCHOME/iocells.db

# setenv TPHN16FFC_MW # milkyway lib is missing ?
# setenv TPHN16FFC_VERILOG # Verilog 

# Core std Vt
# db
setenv TCBN16FFC_SVT_DB $TSMCHOME/stdcells.db
# mwlib
setenv TCBN16FFC_SVT_MW $TSMCHOME/stdcells.mwlib 
# verilog
setenv TCBN16FFC_SVT_VERILOG $TSMCHOME/stdcells.v

# Core low Vt
# db
setenv TCBN16FFC_LVT_DB $TSMCHOME/stdcells-lvt.db
# mwlib
setenv TCBN16FFC_LVT_MW $TSMCHOME/stdcells-lvt.mwlib 
# verilog
setenv TCBN16FFC_LVT_VERILOG $TSMCHOME/stdcells-lvt.v

# Core ultra low Vt
# db
setenv TCBN16FFC_ULVT_DB $TSMCHOME/stdcells-ulvt.db
# mwlib
setenv TCBN16FFC_ULVT_MW $TSMCHOME/stdcells-ulvt.mwlib 
# verilog
setenv TCBN16FFC_ULVT_VERILOG $TSMCHOME/stdcells-ulvt.v



