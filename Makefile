models: adc_model

adc_model: dragonphy/fpga_models/rx_adc_core.py
	mkdir -p build/fpga_models
	python dragonphy/fpga_models/rx_adc_core.py -o build/fpga_models
