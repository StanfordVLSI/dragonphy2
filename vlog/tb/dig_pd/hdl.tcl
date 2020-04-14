database -open waves.shm -into waves.shm -default
probe -create testbench -depth 9
probe -create testbench -depth 9 -all -memories
run 
exit
