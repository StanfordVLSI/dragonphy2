1. Copy design.sdf and design.vcs.v to this folder.
2. Compile SDF:
```text
ncsdfc design.sdf -o design.sdf.X
```
3. Run the simulation:
```text
irun test.sv -top test -sdf_cmd_file sdf.cmd
```
4. You may need to delete some black boxes if they are not defined in design.vcs.v.  I had to delete:
    1. analog_core
    2. mdll_top_r1
    3. input_buffer
    4. output_buffer
    5. SRAMs
    6. input_divider
    7. termination
    8. phase_interpolator
