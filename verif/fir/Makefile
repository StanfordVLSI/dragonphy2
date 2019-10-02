TOP_MODULE := test

NCVLOG_FLAGS := -f opt.f -mcl 8

#Append extra arguments as required

ifneq ($(strip $(TOP_MODULE)),)
	NCVLOG_FLAGS += -top $(TOP_MODULE)
endif

ifneq ($(strip $(TIME_SCALE)),)
	NCVLOG_FLAGS += -timescale $(TIME_SCALE)
endif

ifneq ("$(wildcard custom.f)", "")
	NCVLOG_FLAGS += -f custom.f
endif

#Set the simulator location - if not defined externally, default to ncsim

ifeq ($(strip $(NCVLOG_CMD)),)
	NCVLOG_CMD = xrun
endif

all: run

update: 
	@echo Building Dependencies

run: update
	@echo ""
	@echo dumping user-selected signals
	@echo ====================================================

	@echo 'database -open wave.shm -into wave.shm -default' > hdl.tcl

ifneq ("$(wildcard probes.tcl)","")
	cat probes.tcl >> hdl.tcl
endif

ifneq ($(strip $(TRAN_TIME)),)
	@echo 'run $(TRAN_TIME)' >> hdl.tcl
else
	@echo 'run' >> hdl.tcl
endif

	@echo 'exit' >> hdl.tcl
	$(NCVLOG_CMD) $(NCVLOG_FLAGS) -input hdl.tcl -access r

ifneq ($(strip $(POST_CMD)),)
	$(POST_CMD)
endif

wave:
	@echo ""
	@echo dumping user-selected signals
	@echo ====================================================

	@echo 'database -open wave.shm -into wave.shm -default' > hdl.tcl
	@echo 'probe -creat -shm -all -dynamic -depth all -memories' >> hdl.tcl

ifneq ("$(wildcard probes.tcl)","")
	cat probes.tcl >> hdl.tcl
endif

ifneq ($(strip $(TRAN_TIME)),)
	@echo 'run $(TRAN_TIME)' >> hdl.tcl
else
	@echo 'run' >> hdl.tcl
endif

	@echo 'exit' >> hdl.tcl
	$(NCVLOG_CMD) $(NCVLOG_FLAGS) -input hdl.tcl -access r

ifneq ($(strip $(POST_CMD)),)
	$(POST_CMD)
endif

clean::
	\rm -rf simv simv.* csrc ucli.key vc_hdrs.h DVEfiles *vpd vcs.prof *.txt INCA_libs waves.shm *.log hdl.tcl ncprof.out shm.prof ncverilog.key .simvision *.eps *.history xmprof.out xmverilog.key xrun.* xcelium.d *.diag __pycache__ .bpad *.err *.svf