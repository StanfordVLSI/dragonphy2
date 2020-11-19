1. Copy design.sdf and design.vcs.v to this folder.
2. Fix the location of the stdcells.v file in opt.f to correspond to your PDK.
3. Compile SDF:
```text
ncsdfc design.sdf -o design.sdf.X
```
4. Run the simulation:
```text
xrun -f opt.f
```
