import re


find_adbg_intf = re.compile(r"\s+(PIN|END)\sadbg_intf_i_(.+)")

with open("analog_core.lef", "r") as fin:
    with open("analog_core_alt.lef", "w") as fout:
        for line in fin:
            result = find_adbg_intf.match(line)
            if result:
                boundary_tag = result.group(1)
                pin_tag      = result.group(2)
                print(f'  {boundary_tag} adbg_intf_i.{pin_tag}', file=fout)
            else:
                print(line, file=fout, end='')

