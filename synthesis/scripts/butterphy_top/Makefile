################################################################################
################ Makefile Definitions
################################################################################
# This little trick finds where the makefile exists
REPO_TOP := /aha/sjkim85/verilog/ButterPHY
DESIGN_HOME := /sim/sjkim85/apr_flow_adc/butterphy_top/synthesis_dc
SRC_PATH     	:= $(DESIGN_HOME)/rtl

# RUNDIR is where we are actually running
RUNDIR := $(DESIGN_HOME)

##### FLAGS FOR SYNOPSYS DC-SHELL #####
#######################################
# flags for dc/icc
# define folders
DESIGN_TARGET	= butterphy_top
SYNTH_DIR_NAME 	= syn_$(DESIGN_TARGET)
SYNTH_HOME	= $(DESIGN_HOME)/synth
SYNTH_RUNDIR	= $(RUNDIR)/DC_WORK/$(SYNTH_DIR_NAME)
SYNTH_LOGS	= $(SYNTH_RUNDIR)/log
SYNTH_RESULTS	= $(SYNTH_RUNDIR)/results
SYNTH_REPORTS	= $(SYNTH_RUNDIR)/reports

# define input files
DC_HEAD_SCRIPT = $(SYNTH_HOME)/header.tcl
DC_MAIN_SCRIPT = $(SYNTH_HOME)/run_dc.tcl

# define output files
DC_NETLIST	= $(DESIGN_TARGET).mapped.v
DC_DDC		= $(DESIGN_TARGET).mapped.ddc
DC_SCANDEF	= $(DESIGN_TARGET).mapped.scandef
DC_LOG		= $(SYNTH_LOGS)/dc.log
DC_SIMV		= $(RUNDIR)/dc_simv

# define command strings
SET_SYNTH_PARAMS = 	set DESIGN_TARGET $(DESIGN_TARGET); 	\
			set RTLDIR $(SRC_PATH); \
			set DESIGN_HOME $(DESIGN_HOME); 	\
			set SYNTH_HOME $(SYNTH_HOME);	 	\
			set RUNDIR $(RUNDIR); 			\
			set SYNTH_RESULTS $(SYNTH_RESULTS);	\
			set SYNTH_REPORTS $(SYNTH_REPORTS);	\
			set REPO_TOP $(REPO_TOP);

DC_COMMAND_STRING = "$(SET_SYNTH_PARAMS) source -echo -verbose $(DC_MAIN_SCRIPT)"
DC_LOAD_COMMAND_STRING = "$(SET_SYNTH_PARAMS) source -echo -verbose $(DC_HEAD_SCRIPT)"

######## END OF FLAGS FOR SYNOPSYS DC-SHELL #####


################################################################################
################ Makefile Rules
################################################################################
#default rule: 
all: run_dc

# Design Compiler rules:
########################
.PHONY: run_dc dc_clean force_dc dc_load
force_dc: dc_clean run_dc 

run_dc:$(DC_LOG)

$(DC_LOG): $(GENESIS_SYNTH_LIST) $(DC_MAIN_SCRIPT)
	cp ts1n16ffcllsblvtc1024x144m4sw_130a_ssgnp0p72v125c.db $(SYNTH_RUNDIR)
	cp analog_core.db $(SYNTH_RUNDIR)
	@echo ""
	@echo Now Running DC SHELL: Making $@ because of $?
	@echo =============================================
	@sleep 1;
	@if test ! -d "$(SYNTH_LOGS)"; then 					\
		mkdir -p $(SYNTH_LOGS);						\
	fi
	cd $(SYNTH_RUNDIR); dc_shell-xg-t -64bit -x $(DC_COMMAND_STRING) -output_log_file dcs.log 2>&1 | tee -i $(DC_LOG)

dc_load: $(DC_HEAD_SCRIPT)
	@echo Now LOADING DC SHELL:
	@echo =============================================
	@sleep 1;
	@if test ! -d "$(SYNTH_LOGS)"; then 					\
		mkdir -p $(SYNTH_LOGS);						\
	fi
	cd $(SYNTH_RUNDIR); dc_shell-xg-t -64bit -x $(DC_LOAD_COMMAND_STRING) 

dc_clean:
	@echo ""
	@echo Removing previous DC run log
	@echo =============================================
	\rm -f $(DC_LOG) $(DC_SIMV) 

# Cleanup rules:
#####################
.PHONY: clean cleanall 
clean: dc_clean
	@echo ""
	@echo Cleanning old files, objects, logs and garbage
	@echo ==================================================
	\rm -rf $(SIMV) simv.*
	\rm -f *.tcl
	\rm -f *.info
	\rm -rf csrc
	\rm -rf *.daidir
	\rm -rf *.log
	\rm -rf *.pvl
	\rm -rf *.syn
	\rm -rf *.mr
	\rm -rf *.pvk
	\rm -rf *.flc
	\rm -f pads.tdf
	\rm -f ucli.key
	\rm -rf *~

cleanall: clean 
	\rm -rf DVE*
	\rm -rf DC_WORK
	\rm -rf vcdplus.vpd
	\rm -rf genesis*
	\rm -rf *.vh
	\rm -rf scan.svf
