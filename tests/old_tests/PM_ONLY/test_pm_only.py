import pytest
import matplotlib.pyplot as plt
import numpy as np

CLK_ASYNC_FREQ = 501e6
CLK_REF_FREQ = 4e9
N_PM = 20
T_TOL = 1e-12

def plot_data(delay, pm):
    plt.plot(delay*1e12, pm*1e12, '*')
    plt.plot(delay*1e12, ((1/CLK_REF_FREQ)-pm)*1e12, '*')
    plt.xlabel('True Delay (ps)')
    plt.ylabel('Phase Monitor Estimate (ps)')
    plt.legend(['Test', 'Tref-Test'])

    plt.tight_layout()
    plt.savefig('pm.eps')

    plt.cla()
    plt.clf()

def check_data(delay, pm):
    for t_true, t_est in zip(delay, pm):
        # there is a 180 degree ambiguity in the measurement
        delta_1 = abs(t_true - t_est)
        delta_2 = abs(t_true - ((1/CLK_REF_FREQ) - t_est))
        delta = min(delta_1, delta_2)
        print(delta_1, delta_2)

        assert delta <= T_TOL, f'Phase measurement error of {delta*1e12} ps is out of spec.'

@pytest.mark.skip(reason='still in the process of porting this test')
def test_sim(nosim=False):
    if not nosim:
        # config.define('CLK_ASYNC_FREQ', CLK_ASYNC_FREQ)
        # config.define('CLK_REF_FREQ', CLK_REF_FREQ)
        pass

    # read true delay
    # delay = np.array(read_real('delay.txt'), dtype=float)
    delay = None

    # get PM estimate of delay
    # pm = np.array(read_logic('pm.txt'), dtype=float)
    # pm *= (1.0/CLK_ASYNC_FREQ)/(2**(N_PM+1))
    pm = None

    # plot results
    plot_data(delay=delay, pm=pm)

    # check the results
    check_data(delay=delay, pm=pm)
