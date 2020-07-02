import os
import subprocess
from pathlib import Path

THIS_DIR = Path(__file__).parent.resolve()
FIXTURE_DIR = THIS_DIR / '..' / '..' / 'fixture_models'

def assert_same(path1, path2):
    timestamp_line = 4

    with open(path1) as f1:
        lines1 = f1.readlines()

    with open(path2) as f2:
        lines2 = f2.readlines()

    assert len(lines1) == len(lines2), 'Generated and golden files have different length'

    for i in range(len(lines1)):
        if i == timestamp_line:
            continue
        print(lines1[i], lines2[i])
        assert lines1[i] == lines2[i], f'Golden and generated files mismatch on line {i}'



def test_pb():
    pb_dir = FIXTURE_DIR / 'phase_blender'
    generated_pb_dir = pb_dir / 'final.sv'
    python_file_dir = pb_dir / 'generate.py'
    golden_file_path = THIS_DIR / '..' / '..' / 'vlog' / 'cpu_models' / 'analog_core' / 'phase_blender.sv'

    if os.path.exists(generated_pb_dir):
        print('Removing existing file', generated_pb_dir)
        os.remove(generated_pb_dir)

    subprocess.run(
        ['python',  str(python_file_dir)], cwd=pb_dir
    )


    assert_same(generated_pb_dir, golden_file_path)
    
