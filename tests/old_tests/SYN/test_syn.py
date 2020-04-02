from os.path import dirname
from os import chdir, getcwd 
from butterphy import make, abspath

def test_sim():
	cwd = getcwd()
	chdir(dirname(abspath(__file__)))
	make('syn')
	chdir(cwd)
