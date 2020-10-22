from pathlib import Path
from dragonphy.files import get_file, get_dir
from dragonphy.git_util import *
from justag import jtag_directory


class JTAG:
    def __init__(self,  filename=None, **system_values):
        build_dir = Path(filename).parent

        id_code = self.calc_id_code()
        print(f'JTAG ID Code: 0x{id_code:08x}')

        # get a list of markdown files and sort by name
        md_files = list(get_dir('md').glob('*.md'))
        md_files = sorted(md_files, key=lambda md: md.stem)
        md_files = [str(md) for md in md_files]

        justag_inputs = []
        justag_inputs += [str(id_code)]
        justag_inputs += [str(4)]
        justag_inputs += md_files
        justag_inputs += [get_file('vlog/pack/const_pack.sv')]
        print(justag_inputs)

        # call JusTAG
        self.justag(*justag_inputs, cwd=build_dir)

        # generate JTAG for the chip source

        TOP_NAME='raw_jtag'
        JUSTAG_DIR = jtag_directory()

        PRIM_DIR=f'{JUSTAG_DIR}/rtl/primitives'
        DIGT_DIR=f'{JUSTAG_DIR}/rtl/digital'
        VERF_DIR=f'{JUSTAG_DIR}/verif'
        SVP_FILES = [
            f'{DIGT_DIR}/{TOP_NAME}.svp',
            f'{PRIM_DIR}/cfg_ifc.svp',
            f'{DIGT_DIR}/{TOP_NAME}_ifc.svp',
            f'{PRIM_DIR}/flop.svp',
            f'{DIGT_DIR}/tap.svp',
            f'{DIGT_DIR}/cfg_and_dbg.svp',
            f'{PRIM_DIR}/reg_file.svp'
        ]


        self.genesis(TOP_NAME, *SVP_FILES, cwd=build_dir)

        # generate the JTAG test harness

        self.genesis('JTAGDriver', f'{VERF_DIR}/JTAGDriver.svp', cwd=build_dir)

        # move the package containing register numbers

        cpu_models = get_dir('build/cpu_models/jtag')
        cpu_models.mkdir(exist_ok=True, parents=True)
        (build_dir / 'jtag_reg_pack.sv').replace(cpu_models / 'jtag_reg_pack.sv')

        # move the test harness and place inside a package

        tb = get_dir('build/tb')
        tb.mkdir(exist_ok=True, parents=True)
        with open(build_dir / 'genesis_verif' / 'JTAGDriver.sv', 'r') as orig:
            with open(tb / 'jtag_drv_pack.sv', 'w') as new:
                new.write('package jtag_drv_pack;\n')
                new.write(orig.read())
                new.write('endpackage\n')

        # move the generated source code for the JTAG implementation

        chip_src = get_dir('build/chip_src/jtag')
        chip_src.mkdir(exist_ok=True, parents=True)
        for file in (build_dir / 'genesis_verif').glob('*.sv'):
            file.replace(chip_src / file.name)

        # specify the generated files
        self.generated_files = []
        self.generated_files += [get_file('build/tb/jtag_drv_pack.sv')]
        self.generated_files += [get_file('build/cpu_models/jtag/jtag_reg_pack.sv')]
        self.generated_files += list(get_dir('build/chip_src/jtag').glob('*.sv'))

    @staticmethod
    def justag(*inputs, cwd=None):
        args = []
        args += [f'justag']
        args += list(inputs)
        retcode = subprocess.call(args, cwd=cwd)
        assert retcode==0, 'Error when calling justag.'

    @staticmethod
    def genesis(top, *inputs, cwd=None):
        args = []
        args += ['Genesis2.pl']
        args += ['-parse']
        args += ['-generate']
        args += ['-top', top]
        args += ['-input'] + list(inputs)
        retcode = subprocess.call(args, cwd=cwd)
        assert retcode==0, 'Error when calling genesis.'

    @staticmethod
    def required_values():
        return []

    @staticmethod
    def calc_id_code():
        # get short git hash as an int
        git_hash_short = get_git_hash_short()

        # find out if the git repo is clean/dirty
        git_is_clean = get_git_is_clean()

        # build up ID code
        id_code = 0

        # add 7-character git hash
        id_code |= git_hash_short << 4

        # add bit to indicate clean/dirty status
        if git_is_clean:
            id_code |= 1 << 1

        # lowest bit is always "1"
        id_code |= 1

        # return the ID code
        return id_code
