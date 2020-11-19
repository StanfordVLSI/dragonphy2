import sys

with open(sys.argv[1], "r") as fin:
    with open(f"{sys.argv[1].split('.')[0]}_alt.lvs.v", 'w') as fout:
        for line in fin:
            tokens = line.split()

            if tokens:
                if ".\\adbg_intf_i" in tokens[0]:
                    tokens[0] = f'.\\adbg_intf_i_{tokens[0].split(".")[-1]}'
                    print(" ".join(tokens), file=fout, end="")
                else: 
                    print(line, file=fout, end="")
            else:
                print(line, file=fout, end="")
