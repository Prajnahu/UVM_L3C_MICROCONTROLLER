SHELL := /bin/bash
.DEFAULT_GOAL := run

VIP      = ../../../verification_ip
IF_DIR   = $(VIP)/interface_packages
ENV_DIR  = $(VIP)/environment_packages
PRED_DIR = $(VIP)/lc3_prediction_pkg
COMMON   = $(VIP)/lc3_common_pkg
RTL_DIR  = ../rtl
TB_DIR   = ../tb/testbench
TEST_DIR = ../tb/tests
SEQ_DIR  = ../tb/sequences
PAR_DIR  = ../tb/parameters
RESULTS  = ../results

TEST      ?= test_top
SEED      ?= 1
VERBOSITY ?= UVM_LOW
NUM       ?=

# UVMF base library, from the Questa install (set by the Questa module)
UVMF_HOME ?= $(error UVMF_HOME is not set -- load Questa first)
UVMF_BASE  = $(UVMF_HOME)/uvmf_base_pkg

IF_PKGS  = imem dmem fetch_in fetch_out decode_in decode_out execute_in execute_out writeback_in writeback_out memaccess_in memaccess_out control_in control_out
ENV_PKGS = fetch_env decode_env execute_env writeback_env memaccess_env control_env lc3_env
RTL      = Fetch.v Decode_Pipelined.v Execute.v Mem_Access.v WriteBack.v Controller_Pipeline.v TopLevelLC3.v

# ---------------------------------------------------------
# Local writable ini (the shared Questa install is read-only)
# ---------------------------------------------------------
# Every Questa tool started by this Makefile reads this local copy
# (QSIM_INI for 2026.1, MODELSIM for older releases). There is no silent
# fallback: if the copy cannot be made, the build stops and says why.
QUESTA_INI  = questa.ini
QRUN_PATH   = $(shell command -v qrun 2>/dev/null)
QUESTA_HOME = $(abspath $(dir $(QRUN_PATH))..)
INI_ENV     =

export QSIM_INI := $(CURDIR)/$(QUESTA_INI)
export MODELSIM := $(CURDIR)/$(QUESTA_INI)

$(QUESTA_INI):
	@if [ -z "$(QRUN_PATH)" ]; then \
	  echo "ERROR: qrun is not on PATH -- load Questa first (e.g. module load questa)"; exit 1; \
	fi
	@if   [ -f "$(QUESTA_HOME)/questa.ini"   ]; then cp "$(QUESTA_HOME)/questa.ini"   $@; \
	 elif [ -f "$(QUESTA_HOME)/modelsim.ini" ]; then cp "$(QUESTA_HOME)/modelsim.ini" $@; \
	 else env -u QSIM_INI -u MODELSIM vmap -c >/dev/null 2>&1 && [ -f modelsim.ini ] && mv modelsim.ini $@; fi
	@if [ ! -f $@ ]; then \
	  echo "ERROR: could not create a local $@ (qrun: $(QRUN_PATH), install: $(QUESTA_HOME))"; exit 1; \
	fi
	@chmod u+w $@
	@echo "created local $@ from $(QUESTA_HOME)"

check_ini: $(QUESTA_INI)
	@echo "qrun     : $(QRUN_PATH)"
	@echo "QSIM_INI : $$QSIM_INI"
	@echo "MODELSIM : $$MODELSIM"
	@ls -l $(QUESTA_INI)

# ---------------------------------------------------------
# Sources, in compile order
# ---------------------------------------------------------
INCDIRS = \
	+incdir+$(UVMF_BASE) \
	+incdir+$(RTL_DIR) \
	$(foreach p,$(IF_PKGS),+incdir+$(IF_DIR)/$(p)_pkg) \
	$(foreach e,$(ENV_PKGS),+incdir+$(ENV_DIR)/$(e)_pkg) \
	+incdir+$(PRED_DIR) \
	+incdir+$(PAR_DIR) \
	+incdir+$(COMMON) \
	+incdir+$(SEQ_DIR) \
	+incdir+$(TEST_DIR)

# UVMF compile order: base library, then for every interface its HDL and HVL
# packages before the signal bundle and BFMs (the BFMs hold a proxy handle to
# a class in the HVL package), then environments, then the bench.
SRC_FILES = \
	$(UVMF_BASE)/uvmf_base_pkg_hdl.sv \
	$(UVMF_BASE)/uvmf_base_pkg.sv \
	$(foreach p,$(IF_PKGS),$(IF_DIR)/$(p)_pkg/$(p)_pkg_hdl.sv) \
	$(foreach p,$(IF_PKGS),$(IF_DIR)/$(p)_pkg/$(p)_pkg.sv) \
	$(foreach p,$(IF_PKGS),$(IF_DIR)/$(p)_pkg/src/$(p)_if.sv) \
	$(foreach p,$(IF_PKGS),$(IF_DIR)/$(p)_pkg/src/$(p)_monitor_bfm.sv) \
	$(foreach p,$(IF_PKGS),$(IF_DIR)/$(p)_pkg/src/$(p)_driver_bfm.sv) \
	$(PRED_DIR)/lc3_prediction_pkg.sv \
	$(COMMON)/lc3_common_pkg.sv \
	$(foreach e,$(ENV_PKGS),$(ENV_DIR)/$(e)_pkg/$(e)_pkg.sv) \
	$(PAR_DIR)/lc3_parameters_pkg.sv \
	$(SEQ_DIR)/lc3_sequences_pkg.sv \
	$(TEST_DIR)/lc3_tests_pkg.sv \
	$(foreach f,$(RTL),$(RTL_DIR)/$(f)) \
	$(TB_DIR)/hdl_top.sv \
	$(TB_DIR)/hvl_top.sv

# Compile/optimize options (no test-specific arguments, so one compiled
# design serves every test)
COMP_OPTS = \
	-uvm \
	-64 \
	+define+QUESTA \
	-suppress vsim-8887 \
	-suppress 8451 \
	$(INCDIRS) \
	$(SRC_FILES) \
	-top hdl_top \
	-top hvl_top

# Per-test simulation arguments
SIM_ARGS = \
	-sv_seed $(SEED) \
	+UVM_TESTNAME=$(TEST) \
	+UVM_VERBOSITY=$(VERBOSITY) \
	+UVM_NO_RELNOTES \
	$(if $(NUM),+NUM_INSTRUCTIONS=$(NUM),)

QRUN_OPTS = $(COMP_OPTS) $(SIM_ARGS)

# qrun keeps the compiled libraries in qrun.out; qrun_opt is the name qrun
# gives the optimized design
WORK_LIB   = qrun.out/work
OPT_DESIGN = qrun_opt

TEST_UCDBS = $(filter-out $(RESULTS)/lc3_testplan.ucdb $(RESULTS)/lc3_merged.ucdb,$(wildcard $(RESULTS)/*.ucdb))

# ---------------------------------------------------------
# Compile and optimize once (incremental: only changed files are rebuilt)
# ---------------------------------------------------------
compile: $(QUESTA_INI)
	$(INI_ENV) qrun -optimize $(COMP_OPTS)

# ---------------------------------------------------------
# Simulate one test on the compiled design, in batch, to completion.
# Several 'make sim' can run at the same time (regress.sh does this):
# each writes only its own log and UCDB. QUIET=1 hides the transcript.
#   make sim TEST=lc3_alu_test SEED=1
# ---------------------------------------------------------
sim: $(QUESTA_INI)
	@mkdir -p $(RESULTS)
	$(INI_ENV) vsim -64 -c -lib $(WORK_LIB) $(OPT_DESIGN) -suppress 8887,8451 $(SIM_ARGS) \
		-l $(RESULTS)/$(TEST).log -wlf $(RESULTS)/$(TEST).wlf -wlfdeleteonquit \
		-do "coverage save -onexit $(RESULTS)/$(TEST).ucdb; run -all; quit -f" $(if $(QUIET),> /dev/null,)
	@grep -q "TEST PASSED" $(RESULTS)/$(TEST).log

# ---------------------------------------------------------
# Compile (if needed), run one test and save its coverage
#   make run TEST=lc3_closure_test SEED=1
# ---------------------------------------------------------
# After the simulation, the coverage GUI opens on this test's UCDB when a
# display is available. BATCH=1 skips it.
# ---------------------------------------------------------
run: compile
	-@$(MAKE) --no-print-directory sim TEST=$(TEST) SEED=$(SEED) VERBOSITY=$(VERBOSITY) NUM=$(NUM)
	@if [ -n "$$DISPLAY" ] && [ -z "$(BATCH)" ]; then \
	  echo "Opening the coverage GUI for $(TEST) ..."; \
	  $(INI_ENV) vsim -viewcov $(RESULTS)/$(TEST).ucdb -do "view covergroups" > /dev/null 2>&1 & \
	fi

# ---------------------------------------------------------
# Coverage GUI on one test's saved coverage, no re-simulation
#   make view_test TEST=lc3_alu_test
# ---------------------------------------------------------
view_test: $(QUESTA_INI)
	$(INI_ENV) vsim -viewcov $(RESULTS)/$(TEST).ucdb -do "view covergroups"

# ---------------------------------------------------------
# Debug: QuestaSim GUI when a display exists (type run -all),
# batch otherwise
# ---------------------------------------------------------
p3_debug: $(QUESTA_INI)
	@if [ -n "$$DISPLAY" ] && [ -z "$(BATCH)" ]; then \
	  $(INI_ENV) qrun $(QRUN_OPTS) -voptargs=+acc -classdebug -gui -onfinish stop -do "log -r /*"; \
	else \
	  $(INI_ENV) qrun $(QRUN_OPTS) -do "run -all; quit -f"; \
	fi

# ---------------------------------------------------------
# Merge every test UCDB with the test plan
# ---------------------------------------------------------
merge: $(QUESTA_INI)
	@mkdir -p $(RESULTS)
	@if [ -z "$(TEST_UCDBS)" ]; then \
	  echo "ERROR: no test coverage in $(RESULTS) -- run a test first, e.g.  make run TEST=lc3_closure_test  or  bash regress.sh"; \
	  exit 1; \
	fi
	-$(INI_ENV) xml2ucdb -format Excel lc3_testplan.xml $(RESULTS)/lc3_testplan.ucdb
	@if [ -f $(RESULTS)/lc3_testplan.ucdb ]; then \
	  $(INI_ENV) vcover merge -out $(RESULTS)/lc3_merged.ucdb $(RESULTS)/lc3_testplan.ucdb $(TEST_UCDBS); \
	else \
	  echo "WARNING: test plan import failed; merging test coverage without it"; \
	  $(INI_ENV) vcover merge -out $(RESULTS)/lc3_merged.ucdb $(TEST_UCDBS); \
	fi

# ---------------------------------------------------------
# Text coverage report of the merged database
# ---------------------------------------------------------
report: $(QUESTA_INI)
	$(INI_ENV) vcover report -cvg $(RESULTS)/lc3_merged.ucdb > $(RESULTS)/coverage_report.txt
	@grep -i "TOTAL COVERGROUP COVERAGE" $(RESULTS)/coverage_report.txt || true

html_coverage: $(QUESTA_INI)
	$(INI_ENV) vcover report -details -html -htmldir $(RESULTS)/covhtmlreport $(RESULTS)/lc3_merged.ucdb

view_coverage: $(QUESTA_INI)
	$(INI_ENV) vsim -viewcov $(RESULTS)/lc3_merged.ucdb -do "view covergroups"

regress:
	bash regress.sh

# ---------------------------------------------------------
# Remove compiled libraries and generated simulation files
# ---------------------------------------------------------
clean:
	rm -rf work qrun.out covhtmlreport .visualizer
	rm -f transcript *.log *.wlf *.ucdb *.db design.bin questa.ini modelsim.ini

.PHONY: check_ini compile sim run view_test p3_debug merge report html_coverage view_coverage regress clean
