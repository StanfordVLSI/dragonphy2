# From Garnet

all:
	rm -rf build
	mkdir -p build
	cd build && dc_shell-xg-t -64bit -output_log_file build.log -f ../generate_db.tcl | tee build.log
	ln -sf build/foo.db

clean:
	rm -rf build foo.db