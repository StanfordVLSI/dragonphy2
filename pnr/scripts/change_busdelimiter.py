#!/usr/bin/env python

__doc__ = ''' 
Change Bus delimiter from "_ _" to "< >"
'''

import re

infile = 'osc_main2_rcbest.spf'
outfile = 'osc_main2_rcbest.spf.mod'
  
def repl(mobj):
  s = mobj.group(0).rstrip('_').lstrip('_')
  return '<'+s+'>'

fw = open(outfile,"w") 

with open(infile,"r") as f:
  for l in f.readlines():
    fw.write(re.sub(r'_[0-9]+_',repl, l))

fw.close()
