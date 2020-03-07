models: adc_model

adc_model: vlog/fpga_models/gen_rx_adc_core.py
	mkdir -p build/fpga_models
	python vlog/fpga_models/gen_rx_adc_core.py -o build/fpga_models
