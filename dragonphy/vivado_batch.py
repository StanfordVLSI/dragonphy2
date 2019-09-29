# subprocess code modified from https://github.com/leonardt/fault/blob/master/fault/subprocess_run.py

from subprocess import Popen, PIPE
from pathlib import Path

# terminal formatting codes
MAGENTA = '\x1b[35m'
BRIGHT = '\x1b[1m'
RESET_ALL = '\x1b[0m'

# used for real-time output
def print_lines(fd, name):
    text = ''
    
    for line in fd:
        if text == '':
            print(MAGENTA + BRIGHT + f'<{name}>' + RESET_ALL)
        print(line, end='')
        text += line

    if text != '':
        print(MAGENTA + BRIGHT + f'</{name}>' + RESET_ALL)

    return text

def vivado_batch(script=None, cwd=None):
    # find path to script
    script = Path(script).resolve()

    # construct the command
    args = []
    args += ['vivado']
    args += ['-nolog']
    args += ['-nojournal']
    args += ['-mode', 'batch']
    args += ['-source', f'{script}']

    # set up build dir     
    if cwd is not None:
        cwd = Path(cwd)
        cwd.mkdir(exist_ok=True)

    # run the simulation
    with Popen(args, cwd=cwd, stdout=PIPE, stderr=PIPE, bufsize=1,
               universal_newlines=True) as p:
        # get output from command
        stdout = print_lines(p.stdout, 'STDOUT')
        stderr = print_lines(p.stderr, 'STDERR')
        returncode = p.wait()

        # check the return code
        assert returncode == 0
    
        # look for known error strings
        err_strs = ['CRITICAL WARNING', 'ERROR', 'FATAL']
        for err_str in err_strs:
            assert err_str not in stdout, f'Found "{err_str}" in STDOUT.'
            assert err_str not in stderr, f'Found "{err_str}" in STDERR.'
