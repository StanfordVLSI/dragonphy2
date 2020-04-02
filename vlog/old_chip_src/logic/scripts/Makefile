.PHONY: check clean

../generate/done.txt: update.py ../../analog_core/all/*.*v ../../../butterphy/*.py
	mkdir -p ../generate
	python update.py
	touch ../generate/done.txt

check:
	xrun ../generate/*.*v

clean:
	rm -f xrun.log xrun.history 
	rm -rf xcelium.d ../generate
