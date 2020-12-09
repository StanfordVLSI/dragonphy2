1. Copy design.sdf and design.vcs.v to this folder.
2. Fix the location of the stdcells.v file in opt.f to correspond to your PDK.
3. Compile SDF:
```text
ncsdfc design.sdf -o design.sdf.X
```
4. Run the simulation:
```text
irun -f opt.f
```
5. If there are errors, you may need to delete some black boxes if they are not defined in design.vcs.v.  I had to delete:
    1. analog_core
    2. mdll_top_r1
    3. input_buffer
    4. output_buffer
    5. SRAMs
    6. input_divider
    7. termination
    8. phase_interpolator
