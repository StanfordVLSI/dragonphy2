#!/usr/bin/env python

__doc__ = '''
    Create a mdll primitive model that maps to foundry stdcell
'''

__author__ = '''
    bclim@alumni.stanford.edu
'''

import yaml
import os

template_dir = "../template"
output_dir = "../primitive"
cfg_file = os.path.join(template_dir,"config.yaml")

def vlog_expr(cellname, instname, portmap):
    template = '{cellname} {instname} ( {port_by_name} );'
    pmap = []
    for k,v in portmap.items():
        pmap.append('.%s(%s)' % (k,v))
    pmb = ', '.join(pmap)
    return template.format(cellname=cellname, instname=instname, port_by_name = pmb)
        
def make(master_name, cell_info):
    fname = master_name + '.sv'
    print('Creating %s' % os.path.join(output_dir,fname))
    expr = vlog_expr(v['cell'],'u1',v['port'])
    
    fi = open(os.path.join(template_dir,fname), 'r')
    fo = open(os.path.join(output_dir,fname), 'w')
    for line in fi:
        fo.write(line.replace('//INSTANCE//', expr))
        

with open(cfg_file, 'r') as f:
    cfg = yaml.load(f)

for k,v in cfg.items():
    os.system('mkdir -p %s' % output_dir)
    make(k, v)
