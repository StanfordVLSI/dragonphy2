import sys

with open(sys.argv[1], "r") as fin:
    with open(f"{sys.argv[1].split('.')[0]}_alt.lvs.v", 'w') as fout:
        for line in fin:
            tokens = line.split()

            if tokens:
                if "termination" in tokens[0]:
                    line = f'   {line.strip()}\n\t.VSS(DVSS),\n'
                    print(line, file=fout, end="")
                else: 
                    print(line, file=fout, end="")
            else:
                print(line, file=fout, end="")
