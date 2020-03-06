import json
from .files import get_dir
from svinst import get_mod_defs

VIEW_DIRS = ['src', 'verif']
VIEW_NAMES = {'beh', 'fpga', 'fpga_verif', 'syn', 'spice', 'layout', 'struct', 'all'}
KNOWN_PRIMS = {'BUFG'}
VIEW_EXTS = {'.v', '.sv'}

class CellView:
    def __init__(self, file_, view=None, comment='//', includes=None, defines=None):
        # set defaults
        if includes is None:
            includes = []
        if defines is None:
            defines = {}

        # save settings
        self.file_ = file_
        self.view = view
        self.comment = comment
        self.includes = includes
        self.defines = defines

        # parse submodules
        self.uses = self.parse_submodules()

    def parse_submodules(self):
        # TODO: do we need to pass in defines and includes, or is ignore_include enough?
        try:
            mod_defs = get_mod_defs(self.file_, includes=self.includes, defines=self.defines)
        except:
            print(f'Could not parse {self.file_}, assuming there are no relevant module instantiations...')
            return set()
        if len(mod_defs) >= 1:
            mod_def = mod_defs[0]
            return set([elem.mod_name for elem in mod_def.insts])
        else:
            return set()

    def serialize(self):
        return {'file_': f'{self.file_}',
                'uses': self.uses}

    def __str__(self):
        return json.dumps(self.serialize(), indent=2)

class DragonViews:
    def __init__(self, includes=None, defines=None):
        # save settings
        self.includes = includes
        self.defines = defines

        # instantiate internal variables
        self.view_dict = {}
        self.build_view_dict()

    def build_view_dict(self):
        for view_dir in VIEW_DIRS:
            view_dir = get_dir(view_dir)
            for f in view_dir.iterdir():
                if not f.is_dir():
                    if f.suffix in VIEW_EXTS:
                        self.add_view_def(f.stem, 'all', f)
                else:
                    self.process_subdir(f)

    def process_subdir(self, subdir):
        for f in subdir.iterdir():
            if not f.is_dir():
                if f.suffix in VIEW_EXTS:
                    self.add_view_def(f.stem, 'all', f)
            else:
                self.process_subsubdir(f)

    def process_subsubdir(self, subsubdir):
        for f in subsubdir.iterdir():
            if not f.is_dir():
                if f.suffix in VIEW_EXTS:
                    self.add_view_def(f.stem, subsubdir.name, f)

    def add_view_def(self, cell, view, file_):
        # make sure cell and view are strings
        cell = f'{cell}'
        view = f'{view}'

        # create a new cell if needed
        if cell not in self.view_dict:
            self.view_dict[cell] = {}

        # make sure the cell view has not already been defined
        if view in self.view_dict[cell]:
            raise Exception(f'Cannot define a view from {file_} since cell={cell}, view={view} has already been defined in {self.view_dict[cell][view]}.')

        # finally add the cell view
        self.view_dict[cell][view] = CellView(
            file_=file_,
            view=view,
            includes=self.includes,
            defines=self.defines
        )

    def has_cell(self, cell):
        return cell in self.view_dict

    def get_cell(self, cell):
        assert self.has_cell(cell), f'Could not find cell={cell}.'
        return self.view_dict[cell]

    def has_view(self, cell, view):
        return self.has_cell(cell) and view in self.get_cell(cell)

    def get_view(self, cell, view):
        assert self.has_view(cell=cell, view=view), f'Could not find cell={cell} view={view}.'
        return self.view_dict[cell][view]

    def search_views(self, cell, view_order=None):
        # set defaults
        if view_order is None:
            view_order = []

        # return None if the cell hasn't been defined
        if not self.has_cell(cell):
            return None

        # otherwise return a view in the preference order listed
        for view_name in view_order:
            if view_name in self.view_dict[cell]:
                return self.view_dict[cell][view_name]

        # if we get to this point, make one last check for the 'all' view
        if 'all' in self.view_dict[cell]:
            return self.view_dict[cell]['all']

        # no view found
        return None

    def serialize(self):
        return {cell: {view_name: view_obj.serialize() for view_name, view_obj in views.items()}
                    for cell, views in self.view_dict.items()}

    def __str__(self):
        return json.dumps(self.serialize(), indent=2)

def get_deps(cell, view_order=None, override=None, includes=None, defines=None):
    dv = DragonViews(includes=includes, defines=defines)

    def get_deps_helper(cell, view_order=None, override=None, retval=None):
        # set defaults
        if view_order is None:
            view_order = []
        if override is None:
            override = {}
        if retval is None:
            retval = {}

        # convert cell to a CellView if needed
        if not isinstance(cell, CellView):
            cell = CellView(cell, includes=includes, defines=defines)

        # recursively descend into the blocks used by this cell
        for subcell in cell.uses:
            if subcell in retval:
                # don't revist the same cell twice
                continue
            elif subcell in override:
                # note that this will produce an error if the specified
                # view does not exist
                print(f'Adding view={override[subcell]} for cell={subcell}.')
                retval[subcell] = dv.get_view(cell=subcell, view=override[subcell])
            else:
                subcell_view = dv.search_views(cell=subcell, view_order=view_order)
                if subcell_view is not None:
                    print(f'Adding view={subcell_view.view} for cell={subcell}.')
                    retval[subcell] = subcell_view
                    get_deps_helper(cell=subcell_view, view_order=view_order, override=override, retval=retval)
                else:
                    if subcell in KNOWN_PRIMS:
                        # we already know this is a primitive cell, so pass
                        pass
                    else:
                        # otherwise raise an exception that we could not find
                        # a suitable view
                        raise Exception(f'Could not find a suitable view for cell={subcell}.')

        return [val.file_ for val in retval.values()]

    return get_deps_helper(cell=cell, view_order=view_order, override=override)