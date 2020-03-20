from dragonphy import Directory

import pygraphviz as pgv
import yaml, os
import kratos
import matplotlib.pyplot as plt
import matplotlib.image  as mpimg
import importlib.util

from pathlib import Path

class Node:
    def __init__(self, sources, sinks):
        self._edges = {}

        self._edges['sources'] = sources
        self._edges['sinks']  = sinks

    def __getitem__(self, key):
        return self._edges[key]

    def __setitem__(self, key, value):
        self._edges[key] = value

    @property
    def sources(self):
        return self._edges['sources']

    @property
    def sinks(self):
        return self._edges['sinks']



class DependencyNode(Node, Directory):
    def __init__(self, name, src_path=None, snk_path=None, rank=0, sources=None, sinks=None):
        sinks = set() if sinks is None else sinks
        sources = set() if sources is None else sources

        super().__init__(sources, sinks)
        self.rank = rank
        self.name = name
        self.src_path = src_path
        self.snk_path = snk_path

    def __lt__(self, other):
        return self.rank < other

    def __le__(self, other):
        return self.rank <= other

    def __gt__(self, other):
        return self.rank > other

    def __ge__(self, other):
        return self.rank >= other

    def __eq__(self, other):
        return self.rank == other

    def __ne__(self, other):
        return self.rank != other

    def build(self, *src_nodes):
        pass

class DependencyGraph:
    def __init__(self):
        self.graph = {}
        self.rank_order = [set()]

    def __add__(self, node):
        node.rank = 0
        for inp_node_name in node['sources']:
            if self.graph[inp_node_name] >= node:
                node.rank = self.graph[inp_node_name].rank + 1
            self.graph[inp_node_name]['sinks'] = self.graph[inp_node_name]['sinks'] | {node.name}

        self.graph[node.name] = node

        if node >= len(self.rank_order):
            self.rank_order += [{node.name}]
        else:
            self.rank_order[node.rank] = self.rank_order[node.rank] | {node.name}
        return self

    def __iadd__(self, node):
        return self.__add__(node)

    def __getitem__(self, node_name):
        return self.graph[node_name]

    def __setitem__(self, node_name, node):
        self.graph[node_name] = node

    def __iter__(self):
        for node_name_list in self.rank_order:
            yield node_name_list


class BuildStatus(Directory):
    def __init__(self, status_file):
        self.status_file = Path(self.path() + '/build/' + status_file + '.yml').resolve()
        self.state_dict = {'inputs' : None, 'outputs' : None}

    def load(self):
        try:
            with open(Path(self.status_file).resolve(), 'r') as f:
                self.state_dict = yaml.load(f, Loader = yaml.FullLoader)
        except FileNotFoundError:
            #print(f'ERROR: {self.status_file} does not exist')
            raise FileNotFoundError

    def save(self):
        if self.state_dict:
             with open(Path(self.status_file).resolve(), 'w') as f:
                yaml.dump(self.state_dict, f)
        else:
            print(f'ERROR: {status_file}.yml cannot be saved with no tracked files')

    def check_graph_state(self, graph):
        def check_node( src_path, src_name, node_type='inputs'):
            time_stamp = Path(src_path).stat().st_mtime

            if src_name in self.state_dict[node_type]:
                old_time_stamp = self.state_dict[node_type][src_name]['time_stamp']
                return ((old_time_stamp - time_stamp) != 0.0), { 'time_stamp' : time_stamp, 'loc' : src_path }
            else:
                return True, { 'time_stamp' : time_stamp, 'loc' : src_path }

        self.state_dict['inputs'] = {} if self.state_dict['inputs'] is None else self.state_dict['inputs']
        self.state_dict['outputs'] = {} if self.state_dict['outputs'] is None else self.state_dict['outputs']

        update_set = set()

        if len(list(graph)) == 1:
            print('Improperly Formed Graph: Only 1 Layer')
            exit()

        input_node_names = list(graph)[0]
        inter_graph = list(graph)[1:]

        #missing input files
        mifs = set()

        #Validate Input File Existence, Check Time Stamps
        for input_node_name in input_node_names:
            src_path = graph[input_node_name].src_path
            src_name = input_node_name
            file_exists = Path(src_path).is_file()
            if file_exists:
                node_changed, node_state = check_node(src_path, src_name, node_type='inputs')
                if node_changed:
                    self.state_dict['inputs'][src_name] = node_state
                    update_set = update_set | {src_name}
            else:
                mifs = mifs | {src_name}

        if len(mifs):
            print(f'Missing Input Files: {mifs}') 
            exit()

        #Check for Intermediate/Output File Existence
        for node_layer in inter_graph:
            for node_name in node_layer:
                src_path = graph[node_name].src_path
                snk_path = graph[node_name].snk_path

                src_file_exists = Path(src_path).is_file() if not src_path is None else True
                snk_file_exists = Path(snk_path).is_file() if not snk_path is None else True

                if not src_file_exists:
                    update_set = update_set | {node_name}
                elif not snk_file_exists:
                    update_set = update_set | {node_name}

        return update_set

    def update_graph_state(self):
        for src_name in self.state_dict['inputs']:
            src_path = self.state_dict['inputs'][src_name]['loc']
            actual_ts  = Path(src_path).stat().st_mtime
            self.state_dict['inputs'][src_name]['time_stamp'] = actual_ts


class InputNode(DependencyNode):
    def __init__(self, source_file, ext=None, folders=None):
        ext = "" if ext is None else ext
        folders = ['src'] if folders is None else folders

        file_ = "/".join([self.path(), *folders, source_file])
        file_ = ".".join([file_, ext]) if not ext == "" else file_

        super().__init__(source_file, src_path=file_, snk_path=file_)


    def output(self):
        return self.source_file

class ConfigNode(InputNode):
    def __init__(self, source_file):
        super().__init__(source_file, ext='yml', folders=['config'])

        try:
            with open(Path(self.src_path).resolve(), 'r') as f:
                self.config_dict = yaml.load(f, Loader = yaml.FullLoader)
        except FileNotFoundError:
            print(f'ERROR: {self.src_path} does not exist')
            exit()

    def output(self):
        return self.config_dict

class ConcatNode(DependencyNode):
    def __init__(self, name, sources, ext=None, folders=None):
        ext = "" if ext is None else ext
        folders = [] if folders is None else folders
        directory_path = "/".join([self.path(), 'build', *folders])

        super().__init__(name, sources=sources)

        #Make Directory if it doesnt exist
        directory_path = "/".join([self.path(), 'build', *folders])
        Path(directory_path).mkdir(parents=True, exist_ok=True)

        file_ = directory_path + "/" + name
        file_ = ".".join([file_, ext]) if not ext == "" else file_

        self.src_path = None
        self.snk_path = file_

    def build(self, src_nodes):
        input_paths = [src_node.snk_path for src_node in src_nodes]
        os.system(f'cat {" ".join(input_paths)} > {self.snk_path}')

    def output(self):
        pass #Location Of Merged Verilog File?

class KratosNode(DependencyNode):
    def __init__(self, name, source_file, generator_name, config_sources=None, folders=None):
        config_sources = set() if config_sources is None else config_sources
        folders = [] if folders is None else folders
        super().__init__(name, sources=config_sources)

        #Make Directory if it doesnt exist
        directory_path = "/".join([self.path(), 'build', name])
        Path(directory_path).mkdir(parents=True, exist_ok=True)

        self.src_path = "/".join([self.path(), 'src', *folders, source_file]) + '.py'
        self.snk_path = directory_path + '/' + f'{self.name}.sv'
        self.gen_name = generator_name

    def build(self, src_nodes):        

        gen_spec = importlib.util.spec_from_file_location(self.gen_name, self.src_path)
        gen_mod  = importlib.util.module_from_spec(gen_spec)
        gen_spec.loader.exec_module(gen_mod)
        vlog_gen = getattr(gen_mod, self.gen_name)

        kratos.verilog(vlog_gen(**(src_nodes[0].config_dict)), filename=self.snk_path)

    def output(self):
        pass #Location of Verilog File?

class PythonNode(DependencyNode):
    def __init__(self, name, python_generator, config_sources=None):
        config_sources = set() if config_sources is None else config_sources
        super().__init__(name, sources=config_sources)
        self.python_generator = python_generator

    def build(self, *src_nodes):
        build_dir = self.path() + f'/build/{self.name}/'
        filename = f'{self.name}.sv'

        self.python_generator.generate(*src_nodes, filename=build_dir + filename, debug=False)

    def output(self):
        pass #


class BuildGraph(Directory):
    def __init__(self, view):
        self.depend_graph = DependencyGraph()
        self.view = view
        self.build_status = BuildStatus('timestamps')

    def insert_node(self, node):
        self.depend_graph += node

    def insert_nodes(self, nodes):
        for node in nodes:
            self.depend_graph += node

    def add_input(self, name, ext=None, folders=None):
        self.depend_graph += InputNode(name, ext=ext, folders=folders)

    def add_kratos(self, build_name, script, generator_name, folders=None, config_sources=None):
        self.depend_graph += KratosNode(build_name, script, generator_name, folders=folders, config_sources=config_sources)

    def add_config(self, name):
        self.depend_graph += ConfigNode(name)

    def merge_results(self, name, sources, ext=None, folders=None):
        self.depend_graph += ConcatNode(name, sources, ext=ext, folders=folders)

    def build(self):
        #Check If Build Directory Exists
        try:
            cwd = Path(self.path() + '/build').resolve(strict=True)
        except FileNotFoundError:
            cwd = Path(self.path() + '/build').resolve()
            cwd.mkdir(exist_ok=True)

        build_status = self.build_status

        track_list = set()
        try:
            build_status.load()
            print(f'BUILD STATE DETECTED')

        except FileNotFoundError:
            print(f'NO BUILD STATE DETECTED')

        target_node_list = build_status.check_graph_state(self.depend_graph)
        
        if not len(target_node_list):
            print(f'NOTHING TO BUILD')
            return

        for node_name_list in self.depend_graph:
            for node_name in node_name_list & target_node_list:
                node = self.depend_graph[node_name]
                src_nodes = [self.depend_graph[src_name] for src_name in node.sources]
                print(f'BUILDING: {node_name}')
                node.build(src_nodes)
                target_node_list = target_node_list | node['sinks']

        build_status.update_graph_state()
        build_status.save()


    def visualize(self):
        graph_render = pgv.AGraph(directed=True)

        for node_name_list in self.depend_graph:
            for node_name in node_name_list:
                graph_render.add_node(node_name)
                for source_node in self.depend_graph[node_name]['sources']:
                    graph_render.add_edge(source_node, node_name)

        graph_render.layout('dot')
        graph_render.draw(f'{self.view}.svg')


def test_build_graph_properties():
    build_graph = BuildGraph('View 1')

    build_graph.add_input('a', ext='v', folders=['src', 'a'])
    build_graph.add_input('c', ext='v', folders=['src', 'b'])
    build_graph.add_config('test')
    build_graph.merge_results('d', {'a','c'}, folders=['h'])
    build_graph.merge_results('e', {'a','d'}, folders=['g'])
    build_graph.add_kratos('passthru', 'async_reg', 'PassThrough', folders=['c'], config_sources={'test'})

    build_graph.build()
    build_graph.visualize()


if __name__ == "__main__":
    test_build_graph_properties()
