#!/bin/csh
setenv MC_HOME ./tsn16ffcllhdspsbsram_20131200_130a
setenv PATH "${PATH}:/sim2/mstrange/mc/MC2_2013.12.00.f/bin"
./tsn16ffcllhdspsbsram_130a.pl -file config.txt -NonBIST -NonSLP -NonDSLP -NonSD 

