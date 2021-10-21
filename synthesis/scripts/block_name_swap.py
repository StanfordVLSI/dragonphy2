# Take input from the commandline 
module_name = input()

# Open the setup.sh and add the last line to tell the tool which block to synthesize
file1 = open("./setup.sh", "a")

file1.write("./inputs/synthesis_dragonphy/scripts/syn.sh " + module_name)

file1.close()

./inputs/synthesis_dragonphy/scripts/syn.sh gate_size_test
