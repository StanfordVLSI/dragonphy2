from .files import get_dir
from svinst import get_mod_defs

def remove_dup(seq):
    # Raymond Hettinger
    # https://twitter.com/raymondh/status/944125570534621185
    return list(dict.fromkeys(seq))

def find_preferred_impl(cell_name, view_order, override):
    # if there is a specific view desired for this cell, use it instead of the view order
    if cell_name in override:
        view_order = [override[cell_name]]

    # walk through the view names in order, checking to see if there are any matches in each
    for view_name in view_order:
        view_folder = get_dir('vlog') / view_name
        matches = list(view_folder.rglob(f'{cell_name}.*v'))
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

def get_deps(cell_name, view_order=None, override=None, skip=None,
             includes=None, defines=None):
    print(f'Visiting cell_name={cell_name}')

    # set defaults
    if view_order is None:
        view_order = []
    if override is None:
        override = {}
    if skip is None:
        skip = set()

    # find the most preferred implementation of this cell given
    impl_file = find_preferred_impl(
        cell_name=cell_name,
        view_order=view_order,
        override=override
    )

    # find out what cells are instantiated by this module and descend into them
    mod_def = find_mod_def(cell_name=cell_name, impl_file=impl_file, includes=includes, defines=defines)

    # get a list of unique modules instantiated, preserving order
    submods = remove_dup([inst.mod_name for inst in mod_def.insts])
    print(f'Found the following dependencies: {submods}')

    # recurse into dependencies
    deps = []
    for submod in submods:
        if submod in skip:
            continue
        deps += get_deps(cell_name=submod, view_order=view_order, override=override, skip=skip,
                         includes=includes, defines=defines)

    # add the current file to the end of the list
    deps += [impl_file]

    # remove duplicates preserving order
    deps = remove_dup(deps)

    return deps