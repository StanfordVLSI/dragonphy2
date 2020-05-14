globalNetConnect DVDD -type pgpin -pin VDD -inst * -override
globalNetConnect DVSS -type pgpin -pin VSS -inst * -override
globalNetConnect DVDD -type pgpin -pin VPP -inst * -override
globalNetConnect DVSS -type pgpin -pin VBB -inst * -override

globalNetConnect DVDD -type pgpin -pin DVDD -inst {iacore} -override
globalNetConnect DVSS -type pgpin -pin DVSS -inst {iacore} -override

globalNetConnect AVDD -type pgpin -pin AVDD -inst {iacore} -override
globalNetConnect AVSS -type pgpin -pin AVSS -inst {iacore} -override

globalNetConnect CVDD -type pgpin -pin CVDD -inst {iacore} -override
globalNetConnect CVSS -type pgpin -pin CVSS -inst {iacore} -override

globalNetConnect DVDD -type pgpin -pin avdd -inst {*ibuf_*} -override
globalNetConnect DVSS -type pgpin -pin avss -inst {*ibuf_*} -override

# TODO: are special net connections needed for the MDLL?