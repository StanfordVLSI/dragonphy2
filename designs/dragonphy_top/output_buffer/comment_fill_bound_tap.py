import sys

with open(sys.argv[1], "r") as fin:
    with open(f"{sys.argv[1].split('.')[0]}_alt.lvs.v", 'w') as fout:
        comment_out = False
        comment_cells = ["BOUNDARY", "FILL", "TAPCELL"]
        for line in fin:
            tokens = line.split()

            if tokens:
                if comment_out:
                    print("//" + line, file=fout, end="")
                elif any([cell in tokens[0] for cell in comment_cells]):
                    print("//" + line, file=fout, end="")
                    comment_out = True
                else: 
                    print(line, file=fout, end="")

                if ");" in tokens[-1]:
                    comment_out = False
            else:
                print(line, file=fout, end="")
