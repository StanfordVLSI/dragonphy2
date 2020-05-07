# required in order to write libraries
enable_write_lib_mode

# write the *.db for the output buffer
read_lib output_buffer.lib
write_lib -format db output_buffer -output ../outputs/output_buffer.db

exit