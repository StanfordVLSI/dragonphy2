##------------------------------------------------------
## Chip Out
##------------------------------------------------------

##### Add seal ring ##
#addInst -cell N16_SR_B_1KX1K_DPO_DOD_FFC_5x5 -inst sealring -physical -loc {-50 -50}

##### Verilog out ##
### -phys for outputting filler cells (DCAP, etc.)
saveNetlist ${resDir}/${DesignName}.lvs.v -includePowerGround -excludeLeafCell -includeBumpCell -phys
saveNetlist ${resDir}/${DesignName}.pnr.v 

##### GDS out ##
#streamOut ${resDir}/${DesignName}.gds -uniquifyCellNames -mode ALL -merge ${gds_files} -mapFile ${procDir}/gdsout_2Xa1Xd_h_3Xe_vhv_2Z_1.2a.map -outputMacros -units 1000
streamOut ${resDir}/${DesignName}.gds -mode ALL -merge ${gds_files} -mapFile ${procDir}/gdsout_2Xa1Xd_h_3Xe_vhv_2Z_1.2a.map -outputMacros -units 1000
##### LEF out ##
write_lef_abstract ${resDir}/${DesignName}.lef -specifyTopLayer ${TOP_BLK_LAYER}
##### SDF out ##
write_sdf ${resDir}/${DesignName}.sdf -max_view setup_rcworst_CC -min_view hold_rcbest_CC

##### SPF/SPEF out ##
rcOut -spef ${resDir}/${DesignName}_rcworst_CC.spef -rc_corner rcworst_CC
rcOut -spef ${resDir}/${DesignName}_rcbest.spef -rc_corner rcbest_CC
rcOut -spf ${resDir}/${DesignName}_rcworst_CC.spf -rc_corner rcworst_CC
rcOut -spf ${resDir}/${DesignName}_rcbest.spf -rc_corner rcbest_CC

### Save Model ##
saveModel -dir ${resDir}/${DesignName}_Model -spef 

puts "============="
puts " PnR is done "
puts "============="

