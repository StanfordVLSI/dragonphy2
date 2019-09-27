import subprocess
from pathlib import Path

def test_loopback():
    # testbench location
    signals = 'src/signals/beh'
    top = 'src/top/beh/top.sv'

    # library locations
    libs = []
    libs.append('src/loopback/beh/loopback.sv')
    libs.append('src/tx/beh/tx.sv')
    libs.append('src/clk_gen/beh/clk_gen.sv')
    libs.append('src/prbs21/beh/prbs21.sv')
    libs.append('src/chan/beh/chan.sv')
    libs.append('src/tb/syn/tb.sv')
    libs.append('src/rx/syn/rx.sv')
    libs.append('src/rx_cmp/beh/rx_cmp.sv')

    # resolve paths
    signals = Path(signals).resolve()
    top = Path(top).resolve()
    libs = [Path(lib).resolve() for lib in libs]

    # construct the command
    args = []
    args += ['xrun']
    args += ['-timescale', '1s/1fs']
    args += [f'{top}']
    args += ['-top', 'top']
    args += [f'+incdir+{signals}']
    for lib in libs:
        args += ['-v', f'{lib}']

    # set up build dir     
    cwd = Path('tests/build_loopback')
    cwd.mkdir(exist_ok=True)

    # run the simulation
    result = subprocess.run(args, cwd=cwd)
    assert result.returncode == 0

if __name__ == '__main__':
    test_loopback()
