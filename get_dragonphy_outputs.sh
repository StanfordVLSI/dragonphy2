# make build directory and cd into it
mkdir -p build/mflowgen_dragonphy_top
cd build/mflowgen_dragonphy_top

# set up mflowgen
mflowgen run --design ../../designs/dragonphy_top

# run PnR, generate a GDS, run LVS
make synopsys-ptpx-genlibdb
make mentor-calibre-gdsmerge
make mentor-calibre-lvs

# save outputs
mkdir -p outputs
cp -L *synopsys-ptpx-genlibdb/outputs/design.lib outputs/dragonphy_tt.lib
cp -L *synopsys-ptpx-genlibdb/outputs/design.db outputs/dragonphy.db
cp -L *cadence-innovus-signoff/outputs/design.lef outputs/dragonphy.lef
cp -L *mentor-calibre-gdsmerge/outputs/design_merged.gds outputs/dragonphy.gds
cp -L *mentor-calibre-lvs/outputs/design_merged.lvs.v outputs/dragonphy.lvs.v

# cd back to original directory
cd ../..
