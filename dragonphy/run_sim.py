import subprocess
from pathlib import Path

def run_sim(srcs=None, libs=None, timescale='1s/1fs',
            inc_dirs=None, top=None, cwd=None, defs=None):
    if srcs is None:
        srcs = []
    if libs is None:
        libs = []
    if inc_dirs is None:
        inc_dirs = []
    if defs is None:
        defs = []

    srcs = [Path(src).resolve() for src in srcs]
    libs = [Path(lib).resolve() for lib in libs]
    inc_dirs = [Path(d).resolve() for d in inc_dirs]

    # construct the command
    args = []
    args += ['xrun']
    if timescale is not None:
        args += ['-timescale', '1s/1fs']
    if top is not None:
        args += ['-top', f'{top}']
    for inc_dir in inc_dirs:
        args += [f'+incdir+{inc_dir}']
    for src in srcs:
        args += [f'{src}']
    for lib in libs:
        args += ['-v', f'{lib}']
    for def_ in defs:
        if not isinstance(def_, str):
            args += [f'+define+{def_[0]}={def_[1]}']
        else:
            args += [f'+define+{def_}']

    # set up build dir     
    if cwd is not None:
        cwd = Path('tests/build_loopback')
        cwd.mkdir(exist_ok=True)

    # run the simulation
    result = subprocess.run(args, cwd=cwd)

    # check the result
    assert result.returncode == 0
