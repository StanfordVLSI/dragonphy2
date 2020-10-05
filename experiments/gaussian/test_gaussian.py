import time
from pathlib import Path

from anasymod.analysis import Analysis

root = Path(__file__).resolve().parent

MIN_CDF = -6
MAX_CDF = +6

def numstr(i):
    if i < 0:
        return f'm{-i}'
    elif i == 0:
        return '0'
    else:
        return f'p{i}'

def test_1():
    ana = Analysis(input=root, simulator_name='icarus')
    ana.gen_sources()
    ana.set_target(target_name='sim')
    ana.simulate()

def test_2():
    ana = Analysis(input=root)
    ana.gen_sources()
    ana.set_target(target_name='fpga')
    ana.build()

def test_3():
    ana = Analysis(input=root)
    ana.gen_sources()
    ana.set_target(target_name='fpga')
    ctrl = ana.launch(debug=True)

    # reset sequence
    # the RNG takes 25000 cycles to start up, but we wait
    # 10x longer to be extra sure (i.e., 25ms)
    ctrl.set_param('cdf_rst', 1)
    ctrl.set_reset(1)
    ctrl.set_reset(0)
    time.sleep(25e-3)
    ctrl.set_param('cdf_rst', 0)

    # run for some time (each second yields 10M points)
    time.sleep(100)

    # read out results
    ctrl.stall_emu()
    ctrl.refresh_param('vio_0_i')
    cdfs = []
    cdf_tot = int(ctrl.get_param('cdf_tot'))
    for i in range(MIN_CDF, MAX_CDF+1):
        cdfs.append(int(ctrl.get_param(f'cdf_{numstr(i)}')))

    # print results
    print(f'cdf_tot: {cdf_tot}')
    for i in range(MIN_CDF, MAX_CDF+1):
        print(f'{i}: {cdfs[i-MIN_CDF]/cdf_tot}')
