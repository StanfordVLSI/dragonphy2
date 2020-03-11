.PHONY: clean

all: fir models

fir: dragonphy/adapt_fir.py
	mkdir -p build/adapt_fir
	python -c "from dragonphy import *; adapt_fir(get_dir('build/adapt_fir'), 'test_loopback_config')"

models: dragonphy/fpga_models/*.py
	mkdir -p build/fpga_models
	for file in $^ ; do \
	    python $${file} -o build/fpga_models; \
	done

clean:
	rm -rf build
