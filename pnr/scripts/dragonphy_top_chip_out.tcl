set mflowgenDir /sim/zamyers/dragonphy2/build/mflowgen_sjkim
set procDir /sim/zamyers/mflowgen/adks/tsmc16/stdview 
set ip_gds [list ${mflowgenDir}/0-analog_core/outputs/analog_core.gds ${mflowgenDir}/6-input_buffer/outputs/input_buffer.gds ${mflowgenDir}/7-mc-gen-sram/outputs/sram.gds ${mflowgenDir}/8-mdll_r1/outputs/mdll_r1_top.gds ${mflowgenDir}/9-output_buffer/outputs/output_buffer.gds ]
set std_gds [list ${procDir}/stdcells.gds ${procDir}/stdcells-lvt.gds ${procDir}/stdcells-ulvt.gds ]
set gds_files "$std_gds $ip_gds"
set map_file ${procDir}/rtk-stream-out.map

saveNetlist ./dragonphy_top.lvs.v -includePowerGround -excludeLeafCell -includeBumpCell -phys
saveNetlist ./dragonphy_top.pnr.v 
write_lef_abstract ./dragonphy_top.lef -specifyTopLayer M8
streamOut ./gragonphy_top.gds -uniquifyCellNames -mode ALL -merge ${gds_files} -mapFile ${map_file} -outputMacros -units 1000



