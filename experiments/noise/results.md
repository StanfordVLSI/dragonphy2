* Run as xrun test.sv
  * optional +defines to set scale and number of iterations
* With 1B points and SCALE=10000:
  * -6: meas 1.000000e-09
  * -5: meas 2.970000e-07
  * -4: meas 3.167000e-05
  * -3: meas 1.349127e-03
  * -2: meas 2.273798e-02
  * -1: meas 1.586418e-01
  * 0: meas 4.999795e-01
  * 1: meas 8.413344e-01
  * 2: meas 9.772516e-01
  * 3: meas 9.986508e-01
  * 4: meas 9.999683e-01
  * 5: meas 9.999997e-01
  * 6: meas 1.000000e+00 
* Distribution appears to be very accurate even when SCALE is relatively low.  This suggests SCALE mainly affects the resolution of the output, not the frequency of events
* However, if SCALE is in the neighborhood of 1B or larger, the distribution accuracy collapses.  Seems that using SCALE=10000 provides plenty of resolution without being anywhere close to that point
