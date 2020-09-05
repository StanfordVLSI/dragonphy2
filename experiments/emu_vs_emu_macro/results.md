Friday Sept. 4

* Low-level emulator
Using jitter=5 ps
BER: 5.975747e-08
Total bits: 50202928
Using jitter=6 ps
BER: 2.987365e-07
Total bits: 50211472
Using jitter=7 ps
BER: 1.081463e-05
Total bits: 50209776
Using jitter=8 ps
BER: 8.375055e-05
Total bits: 50196688
Using jitter=9 ps
BER: 3.860070e-04
Total bits: 50193392
Using jitter=10 ps
BER: 1.200900e-03
Total bits: 50228992
OK!

Using noise=25 mV
BER: 3.889528e-06
Total bits: 50134624
Using noise=30 mV
BER: 1.082594e-04
Total bits: 50157312
Using noise=35 mV
BER: 9.837082e-04
Total bits: 50115472
Using noise=40 mV
BER: 4.284022e-03
Total bits: 50161744
Using noise=45 mV
BER: 1.202435e-02
Total bits: 50157728
Using noise=50 mV
BER: 2.527556e-02
Total bits: 50127584

* High-level emulator (with a known issue in which jitter is not clamped to a minimum value as it is in the low-level emulator.  there may also be a related issue for the very last sample, in which it could occasionally go "over the edge".

BER: 0.000000e+00
Total bits: 81581728
Using jitter=1 ps
BER: 0.000000e+00
Total bits: 81839520
Using jitter=2 ps
BER: 0.000000e+00
Total bits: 81863952
Using jitter=3 ps
BER: 0.000000e+00
Total bits: 81749328
Using jitter=4 ps
BER: 0.000000e+00
Total bits: 81799120
Using jitter=5 ps
BER: 0.000000e+00
Total bits: 81838096
Using jitter=6 ps
BER: 4.036159e-07
Total bits: 81760912
Using jitter=7 ps
BER: 8.329344e-06
Total bits: 81759136
Using jitter=8 ps
BER: 7.407140e-05
Total bits: 81853456
Using jitter=9 ps
BER: 3.411289e-04
Total bits: 81848832
Using jitter=10 ps
BER: 1.129128e-03
Total bits: 81847232

Using noise=25 mV
BER: 3.298853e-06
Total bits: 81846640
Using noise=30 mV
BER: 1.074822e-04
Total bits: 81706544
Using noise=35 mV
BER: 9.828201e-04
Total bits: 81862384
Using noise=40 mV
BER: 4.335408e-03
Total bits: 81661520
Using noise=45 mV
BER: 1.199838e-02
Total bits: 81718928
Using noise=50 mV
BER: 2.528944e-02
Total bits: 81858208

* Comparing at max jitter: 12.7ps
Low-level: 9.580927e-03
High-level: 9.503907e-03

============

Jitter = [6, 7, 8, 9, 10], Noise=30mV when added
Low-level, no noise: [6.245447e-07, 1.170676e-05, 8.705806e-05, 3.917500e-04, 1.195517e-03]
Low-level, with noise: [1.819405e-03, 3.249811e-03, 5.565236e-03, 9.108862e-03, 1.398099e-02]

Jitter = [6, 7, 8, 9, 10], Noise=30mV when added
High-level, no noise: [4.540911e-07, 8.923727e-06, 7.380974e-05, 3.465255e-04, 1.137632e-03]
High-level, with noise: [1.719253e-03, 3.082160e-03, 5.311254e-03, 8.697677e-03, 1.356970e-02]

Jitter = [8, 9, 10], Noise=30mV when added
CPU sim, no noise: [8.340000e-05, 3.789000e-04, 1.252800e-03].  Used 20M, 10M, 5M points respectively.
CPU sim, with noise: [5.474500e-03, 8.858500e-03, 1.371100e-02].  Used 2M points.
