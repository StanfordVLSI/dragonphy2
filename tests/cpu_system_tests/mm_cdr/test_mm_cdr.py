from pathlib import Path
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

def test_sim(dump_waveforms):
    #check for deps file if it doesn't exist, regenerate dependencies:
    if not (THIS_DIR / Path('.deps.txt')).is_file():
        
        #Get dependencies, write to a file
        deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    
        with open('.deps.txt', 'w') as f:
            for line in deps:
                print(line, file=f)

    deps = []
    with open('.deps.txt', 'r') as f:
        for line in f:
            deps += [Path(line.strip())]

    print(deps)


    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        dump_waveforms=dump_waveforms
    ).run()

if __name__ == "__main__":
    test_sim(dump_waveforms=True)
