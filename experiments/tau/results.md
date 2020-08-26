* tau meaning seems to match expectations, since 10-90% rise time is 222.1ps, corresponding to a tau of 101ps (i.e., divide by 2.2)
* need to look into:
  * channel_simple etol -- route etol through diff_channel; default is 0.001
  * bit2pwl rise time -- set tr for diff_tx_driver; default is 10e-12
  * diff_channel timescale
  * tx_prbs_i timescale
  * diff_tx_driver timescale
  * clock parameters -- nothing like etol
  * prbs21 parameters -- none, but note that the output is on the sixth bit
  * bit2pwl etol -- no, doesnt exist
  * DAVE_TIMEUNIT -- already set by DRAGON_TESTER
etol of filter
  * 
