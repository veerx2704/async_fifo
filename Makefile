SHELL := /bin/bash

DESIGN_TOP ?=

DESIGN_DIR ?=

CONSTR_DIR ?= $(DESIGN_DIR)

CONSTR ?= 

DESIGN_FILES ?= *

CDC_OUTPUT := $(DESIGN_TOP)_cdc_report.json

all: synthesis tpower

synthesis: yosys_flow.sh
	@echo "Beginning Synthesis"
	@./yosys_flow.sh
	@echo "Synthesis Complete! Output recorded at yosys_log.log"

tpower: cache_sta.tcl timing_check.sh
	@echo "Opening Timing and Power Simulation"
	@./cache_sta.tcl > power_timing_report.log
	@./timing_check.sh


cdc_check: $(DESIGN_TOP) $(DESIGN_DIR) $(CONSTR_DIR) $(CONSTR) $(CDC_OUTPUT) cdc_checker.sh 
	@echo "Beginning CDC Check"
	@./cdc_checker.sh --sv -t $(DESIGN_TOP) -p $(CONSTR_DIR) -c $(CONSTR) -d $(DESIGN_DIR) -o $(CDC_OUTPUT)
	
clean:
	
