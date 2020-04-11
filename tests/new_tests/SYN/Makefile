.PHONY: syn clean

syn:
	dc_shell -f run.tcl -no_init -no_home_init -no_local_init -no_gui -no_log 2>&1 | tee out.txt
	if [ `grep -ci error out.txt` -ne 0 ]; then \
		exit 1; \
	fi;

clean:
	rm -f *.svf
	rm -f *.mr
	rm -f *.pvl
	rm -f *.syn
	rm -f *.log
	rm -f *.pvk
	rm -f *.txt
