.PHONY: clean

models: dragonphy/fpga_models/*.py
	mkdir -p build/fpga_models
	for file in $^ ; do \
	    python $${file} -o build/fpga_models; \
	done

clean:
	rm -rf build
