database -open waves.shm -into waves.shm -default
probe -create shiftTestBench -depth 9
probe -create shiftTestBench -depth 9 -all -memories
run 
exit
