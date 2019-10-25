* NMOS/PMOS models from
* https://people.rit.edu/lffeee/SPICE_Examples.pdf

.model EENMOS NMOS (VTO=0.4 KP=432E-6 GAMMA=0.2 PHI=.88)
.model EEPMOS PMOS (VTO=-0.4 KP=122E-6 GAMMA=0.2 PHI=.88)

.subckt simple_comparator my_in my_out vdd vss
R1 vdd N001 5k
M1 N001 my_in vss vss EENMOS w=1u l=0.1u
R2 vdd my_out 5k
M2 my_out N001 vss vss EENMOS w=1u l=0.1u
.ends my_comparator
