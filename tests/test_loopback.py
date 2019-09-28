import subprocess
from pathlib import Path

def test_loopback():
    # testbench location
    signals = 'src/signals/beh/signals.sv'
    stim = 'stim/loopback_stim.sv'

    # library locations
    libs = []
    libs.append('verif/loopback/loopback.sv')
    libs.append('verif/tx/tx.sv')
    libs.append('verif/clk_gen/beh/clk_gen.sv')
    libs.append('verif/prbs21/prbs21.sv')
    libs.append('verif/chan/chan.sv')
    libs.append('verif/tb/tb.sv')
    libs.append('src/rx/rx.sv')
    libs.append('src/rx_cmp/rx_cmp.sv')

    # resolve paths
    signals = Path(signals).resolve()
    stim = Path(stim).resolve()
    libs = [Path(lib).resolve() for lib in libs]

    # construct the command
    args = []
    args += ['xrun']
    args += ['-timescale', '1s/1fs']
    args += ['-top', 'stim']
    args += [f'+incdir+{signals.parent}']

    srcs = [signals] + libs + [stim]
    srcs = [f'{src}' for src in srcs]
    args += srcs

    # set up build dir     
    cwd = Path('tests/build_loopback')
    cwd.mkdir(exist_ok=True)

    # run the simulation
    result = subprocess.run(args, cwd=cwd)
    assert result.returncode == 0

if __name__ == '__main__':
    test_loopback()
