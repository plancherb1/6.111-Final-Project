setMode -bs
setMode -bs
setCable -port auto
Identify 
identifyMPM 
assignFile -p 2 -file "/afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Main_FPGA/labkit.bit"
Program -p 2 
saveProjectFile -file "/afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Main_FPGA/Main_FPGA.ipf"
setMode -bs
deleteDevice -position 1
deleteDevice -position 1
deleteDevice -position 1
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
