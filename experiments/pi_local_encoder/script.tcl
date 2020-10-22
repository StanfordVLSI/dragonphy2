analyze -clear
analyze -sva test.sv

elaborate -top tb

clock -none
reset -none

set_engine_mode default

prove -all
