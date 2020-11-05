import subprocess
import sys
import shutil
import os
from pathlib import Path

THIS_DIR = Path(__file__).resolve().parent
TOP_DIR = THIS_DIR.parent.parent
BUILD_DIR = TOP_DIR / 'build'

NUM_TRIALS = 25

def run_trial():
    cwd = os.getcwd()
    os.chdir(TOP_DIR)

    shutil.rmtree(BUILD_DIR, ignore_errors=True)
    python = sys.executable
    result = subprocess.run([python, 'make.py', '--view', 'asic'],
                            capture_output=True)

    assert result.returncode == 0, 'JusTAG failed to run.'

    with open(BUILD_DIR / 'all' / 'jtag' / 'reg_list.json', 'r') as f:
        text = f.read()

    os.chdir(cwd)
    return text

# run reference
print(f'Reference run...')
ref_text = run_trial()

# main trials
for k in range(NUM_TRIALS):
    print(f'Running trial {k}...')
    trial_text = run_trial()
    print(f'Checking trial {k}...')
    assert trial_text == ref_text, f'Failed at trial {k}'
    print('OK')
