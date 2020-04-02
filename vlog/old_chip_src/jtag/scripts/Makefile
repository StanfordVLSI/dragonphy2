# Determine path to top-level ButterPHY directory
BUTTERPHY_DIR := $(abspath ../../../)

# Set path to JUSTAG
# ref: https://unix.stackexchange.com/questions/13466/can-grep-output-only-specified-groupings-that-match
JUSTAG_DIR := $(shell pip show justag | sed -n "s/^\s*Location:\s*\(\S*\)\s*$$/\1/p")
ifeq ($(JUSTAG_DIR),)
$(error Could not find JusTag.  Please make sure that you have pip-installed it.)
endif

TOP_NAME := raw_jtag

PACK_DIR := $(BUTTERPHY_DIR)/pack/all
INTF_DIR := $(BUTTERPHY_DIR)/src/reg

PRIM_DIR   := $(JUSTAG_DIR)/rtl/primitives
DIGT_DIR   := $(JUSTAG_DIR)/rtl/digital
VERF_DIR   := $(JUSTAG_DIR)/verif

SVP_FILES  := $(DIGT_DIR)/$(TOP_NAME).svp \
	      $(PRIM_DIR)/cfg_ifc.svp \
	      $(DIGT_DIR)/$(TOP_NAME)_ifc.svp \
	      $(PRIM_DIR)/flop.svp \
	      $(DIGT_DIR)/tap.svp \
	      $(DIGT_DIR)/cfg_and_dbg.svp \
	      $(PRIM_DIR)/reg_file.svp 

../generate/done.txt: $(JUSTAG_DIR)/JusTAG.py $(JUSTAG_DIR)/justag/*.py $(INTF_DIR)/*.md $(PACK_DIR)/*.*v $(SVP_FILES)
	python $(JUSTAG_DIR)/JusTAG.py $(INTF_DIR)/*.md $(PACK_DIR)/*.*v

	Genesis2.pl -parse -generate -top $(TOP_NAME) -input $(SVP_FILES)

	mkdir -p ../generate
	cp genesis_verif/* ../generate/.

	mkdir -p ../beh
	cp jtag_reg_pack.sv ../beh/.
	cp reg_list.json ../beh/.

	touch ../generate/done.txt

jtag_test: $(VERF_DIR)/JTAGDriver.svp
	Genesis2.pl -parse -generate -top JTAGDriver -input $(VERF_DIR)/JTAGDriver.svp

clean:
	@echo ""
	@echo Cleaning previous runs of Genesis
	@echo ===================================
	@if test -f "genesis_clean.cmd"; then 	\
		 ./genesis_clean.cmd;		\
	fi

	rm -rf ../generate
	rm -f *.txt
