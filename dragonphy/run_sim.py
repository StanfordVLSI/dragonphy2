from pathlib import Path
from .deluxe_run import deluxe_run

class Probe:
    def __init__(self, path, depth='all', scopes=None):
        # set defaults
        if scopes is None:
            # other options are "functions" and "tasks"
            scopes = ['all', 'memories']

        # save settings
        self.path = path
        self.depth = depth
        self.scopes = scopes

    def create(self, database=None, mode=None):
        cmd = []
        cmd += ['probe']
        cmd += ['-create', f'{self.path}']
        if self.depth is not None:
            cmd += ['-depth', f'{self.depth}']
        for scope in self.scopes:
            cmd += [f'-{scope}']
        if mode is not None:
            cmd += [f'-{mode}']
        if database is not None:
            cmd += ['-database', f'{database}']
        return ' '.join(cmd)

def write_probes(probes, tcl_file, database):
    lines = []
    lines += [f'database -open {database} -shm']
    for probe in probes:
        # convert to a Probe if needed
        if isinstance(probe, str):
            probe = Probe(path=probe)
        # add probe command to TCL file
        lines += [probe.create(database=database, mode='shm')]
    lines += ['run']
    lines += ['exit']
    with open(tcl_file, 'w') as f:
        f.write('\n'.join(lines))

def run_sim(srcs=None, libs=None, timescale='1s/1fs',
            inc_dirs=None, top=None, cwd='build', defs=None,
            probes=None, database='waves'):
    # set defaults
    if srcs is None:
        srcs = []
    if libs is None:
        libs = []
    if inc_dirs is None:
        inc_dirs = []
    if defs is None:
        defs = []

    # make working directory if needed
    cwd = Path(cwd).resolve()
    cwd.mkdir(exist_ok=True)

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
    if probes is not None:
        tcl_file = cwd / 'input.tcl'
        write_probes(probes=probes, tcl_file=tcl_file, database=database)
        args += ['+access+rwc']
        args += ['-input', tcl_file]

    # run the simulation
    err_strs = ['ERROR', 'FATAL']
    deluxe_run(args, cwd=cwd, err_strs=err_strs)
