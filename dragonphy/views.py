from pathlib import Path

import os
import msdsl, svreal
from svinst import get_mod_defs

from .files import get_dir, get_file, get_mlingua_dir

def remove_dup(seq):
    # fast method to remove duplicates from a list while preserving order
    # source: Raymond Hettinger (https://twitter.com/raymondh/status/944125570534621185)
    return list(dict.fromkeys(seq))

def find_preferred_impl(cell_name, view_order, override):
    # if there is a specific view desired for this cell, use it instead of the view order
    if cell_name in override:
        view_order = [override[cell_name]]

    # walk through the view names in order, checking to see if there are any matches in each
    for view_name in view_order:
        matches = []
        for dir_name in ['vlog', 'build']:
            view_folder = get_dir(dir_name) / view_name
            matches += list(view_folder.rglob(f'{cell_name}.*v'))
        if len(matches) == 0:
            continue
        elif len(matches) == 1:
            return matches[0]
        else:
            print(f'Found multiple matches for cell_name={cell_name}:')
            for match in matches:
                print(f'{match}')
            raise Exception('Build failed due to ambiguity.')

    # fail if we get to this point because no matches were found
    print(f'Found no matches for cell_name={cell_name}:')
    print(f'using view_order={view_order}')
    print(f'using override={override}')
    raise Exception('Build failed due to a missing cell definition.')

def find_mod_def(cell_name, impl_file, includes, defines):
    mod_defs = get_mod_defs(impl_file, includes=includes, defines=defines)
    matches = [elem for elem in mod_defs if elem.name == cell_name]
    if len(matches) == 0:
        print(f'Found no matches for cell_name={cell_name}:')
        print(f'using impl_file={impl_file}')
        print(f'using includes={includes}')
        print(f'using defines={defines}')
        raise Exception('Build failed due to a missing module definition.')
    elif len(matches) > 1:
        print(f'Found multiple matches for cell_name={cell_name}:')
        print(f'using impl_file={impl_file}')
        print(f'using includes={includes}')
        print(f'using defines={defines}')
        raise Exception('Build failed due to an unexpected module redefinition.')
    else:
        return matches[0]

def get_deps(cell_name=None, view_order=None, override=None,
             skip=None, includes=None, defines=None, impl_file=None):
    # set defaults
    if view_order is None:
        view_order = []
    if override is None:
        override = {}
    if skip is None:
        skip = set()
    if cell_name is None:
        if impl_file is not None:
            cell_name = Path(impl_file).stem
        else:
            raise Exception('Must provide either cell_name or impl_file.')

    print(f'Visiting cell_name={cell_name}')

    # find the most preferred implementation of this cell given
    if impl_file is None:
        impl_file = find_preferred_impl(
            cell_name=cell_name,
            view_order=view_order,
            override=override
        )

    # find out what cells are instantiated by this module and descend into them
    mod_def = find_mod_def(
        cell_name=cell_name, impl_file=impl_file, includes=includes, defines=defines
    )

    # get a list of unique modules instantiated, preserving order
    submods = remove_dup([inst.mod_name for inst in mod_def.insts])
    print(f'Found the following dependencies: {submods}')

    # recurse into dependencies
    deps = []
    for submod in submods:
        if submod in skip:
            continue
        deps += get_deps(cell_name=submod, view_order=view_order, override=override,
                         skip=skip, includes=includes, defines=defines)

    # add the current file to the end of the list
    deps += [impl_file]

    # remove duplicates preserving order
    deps = remove_dup(deps)

    return deps

def get_deps_cpu_sim_old(cell_name=None, impl_file=None):
    deps = []
    deps += [Path(os.environ['DW_TAP']).resolve()]
    deps += [get_mlingua_dir() / 'samples' / 'meas' / 'meas_clock.v']
    deps += [get_mlingua_dir() / 'samples' / 'stim' / 'pulse.v']
    deps += [get_mlingua_dir() / 'samples' / 'stim' / 'clock.v']
    deps += [get_file('vlog/old_tb/jtag_drv_pack.sv')]
    deps += [get_file('vlog/old_tb/checker_pack.sv')]
    deps += [get_file('vlog/old_cpu_models/jtag/jtag_reg_pack.sv')]
    deps += list(get_dir('vlog/old_pack').glob('*.sv'))
    deps += [get_file('vlog/old_chip_src/analog_core/acore_debug_intf.sv')]
    deps += [get_file('vlog/old_chip_src/mm_cdr/cdr_debug_intf.sv')]
    deps += [get_file('vlog/old_chip_src/sram/sram_debug_intf.sv')]
    deps += [get_file('vlog/old_chip_src/digital_core/dcore_debug_intf.sv')]
    deps += [get_file('vlog/old_chip_src/analog_core/acore_debug_intf.sv')]
    deps += [get_file('vlog/old_chip_src/jtag/generate/raw_jtag_ifc_unq1.sv')]
    deps += [get_file('vlog/old_chip_src/jtag/generate/cfg_ifc_unq1.sv')]
    deps += [get_file('vlog/old_chip_src/jtag/jtag_intf.sv')]
    deps += get_deps(
        cell_name=cell_name,
        impl_file=impl_file,
        view_order=['old_tb', 'old_cpu_models', 'old_chip_src'],
        includes=[get_dir('inc/old_cpu'), get_mlingua_dir() / 'samples'],
        skip={'acore_debug_intf', 'cdr_debug_intf', 'sram_debug_intf',
              'dcore_debug_intf', 'raw_jtag_ifc_unq1', 'cfg_ifc_unq1',
              'jtag_intf', 'clock', 'DW_tap', 'meas_clock'}
    )
    return deps

def get_deps_cpu_sim_new(cell_name=None, impl_file=None):
    deps = []
    deps += get_deps(
        cell_name=cell_name,
        impl_file=impl_file,
        view_order=['new_cpu_models', 'new_chip_src'],
        includes=[get_dir('inc/old_cpu'), get_mlingua_dir() / 'samples'],
        skip={'snh', 'MUX2D1BWP16P90ULVT', 'PI_delay_unit', 'del_PI'}
    )
    return deps

def get_deps_cpu_sim(cell_name=None, impl_file=None):
    deps = []
    deps += list(get_dir('build/all/adapt_fir').glob('*.sv'))
    deps += get_deps(
        cell_name=cell_name,
        impl_file=impl_file,
        view_order=['tb', 'cpu_models', 'chip_src'],
        includes=[get_dir('inc/cpu')],
        skip={'analog_if'}
    )
    return deps

def get_deps_fpga_emu(cell_name=None, impl_file=None):
    deps = []
    deps += list(get_dir('build/all/adapt_fir').glob('*.sv'))
    deps += get_deps(
        cell_name=cell_name,
        impl_file=impl_file,
        view_order=['tb', 'fpga_models', 'chip_src'],
        includes=[
            get_dir('inc/fpga'),
            svreal.get_svreal_header().parent,
            msdsl.get_msdsl_header().parent
        ],
        defines={'DT_WIDTH': 27, 'DT_EXPONENT': -46},
        skip={'svreal', 'assign_real', 'comp_real', 'add_sub_real', 'ite_real',
              'dff_real', 'mul_real', 'mem_digital', 'sync_rom_real'}
    )
    return deps