database -open wave.shm -into wave.shm -default
probe -create test -depth 9
probe -create test.ffe_inst1 -depth 9 -all -memories
run
exit
