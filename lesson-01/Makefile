# Lesson 1 — RTL modelling
#
#   Run inside the course Codespace: make <target>

SHELL := /bin/bash
.DEFAULT_GOAL := help

VERILATOR ?= verilator
BUILD     := build

# -Wall is on the command line because it is the one flag worth seeing: two of
# the three diagnostics this lesson teaches are reported only under it. It goes
# before verilator.cfg, whose suppressions would be undone the other way round.
VFLAGS := -Wall -f verilator.cfg

.PHONY: help style1 style2 style3 style4 style5 style6 build run check wave clean

help:
	@printf '%s\n' \
	  'Lesson 1 — RTL modelling' \
	  '' \
	  'Part 1. Do style1 by hand first; README.md has the commands and what' \
	  'every flag is for. These targets run the same three steps and print' \
	  'the command before running it.' \
	  '' \
	  '  make style1   combinational logic: two spellings' \
	  '  make style2   a path that assigns nothing' \
	  '  make style3   a register waits for the clock' \
	  '  make style4   `=` and `<=` in a clocked block' \
	  '  make style5   one signal, two writers' \
	  '  make style6   one source file, several circuits' \
	  '' \
	  'Part 2.' \
	  '' \
	  '  make build    compile your rtl/counter.sv, do not run it' \
	  '  make run      run it and write the trace, without judging it' \
	  '  make check    build, run and judge it' \
	  '  make wave     the command for looking at its trace' \
	  '  make clean    remove build/' \
	  ''

# --- Part 1 ----------------------------------------------------------------
#
# One name decides three things: the output directory, the top module, and the
# trace file. The signal list is the only other thing that varies.
#
# --no-skip-identical is in verilator.cfg on purpose. Without it Verilator
# notices the output is already up to date, skips the compile, and prints no
# warnings at all -- so running a specimen a second time would hide the
# diagnostic that is the whole point of it.

SIG_combinational := sel,a,b,y_proc,y_cont
SIG_incomplete    := en,d,y_complete,y_incomplete
SIG_registered    := clk,d,q_wire,q_reg
SIG_blocking      := clk,d,q_nb,q_b
SIG_two_drivers   := clk,d,q_one,q_two
SIG_parameters    := d4,q4,d8,q8

define SPECIMEN
	@mkdir -p $(BUILD)/obj/$(1) $(BUILD)/waves
	@printf '\n--- compile ---\n'
	@printf '%s %s -Mdir %s/obj/%s \\\n    --top-module tb_%s -o sim styles/%s\n\n' \
	    '$(VERILATOR)' '$(VFLAGS)' '$(BUILD)' '$(1)' '$(1)' '$(2)'
	@$(VERILATOR) $(VFLAGS) -Mdir $(BUILD)/obj/$(1) \
	    --top-module tb_$(1) -o sim styles/$(2)
	@printf '\n--- execute ---\n'
	@printf './%s/obj/%s/sim\n\n' '$(BUILD)' '$(1)'
	@./$(BUILD)/obj/$(1)/sim +verilator+quiet
	@printf '\n--- now look ---\n'
	@printf 'vcdtui %s/waves/%s.vcd --scope tb_%s \\\n       -s %s --dump\n\n' \
	    '$(BUILD)' '$(1)' '$(1)' '$(SIG_$(1))'
endef

style1: ; $(call SPECIMEN,combinational,01_combinational.sv)
style2: ; $(call SPECIMEN,incomplete,02_incomplete.sv)
style3: ; $(call SPECIMEN,registered,03_registered.sv)
style4: ; $(call SPECIMEN,blocking,04_blocking.sv)
style5: ; $(call SPECIMEN,two_drivers,05_two_drivers.sv)
style6: ; $(call SPECIMEN,parameters,06_parameters.sv)

# --- Part 2 ----------------------------------------------------------------

build: $(BUILD)/obj/counter/sim

run: $(BUILD)/obj/counter/sim
	@./$(BUILD)/obj/counter/sim +verilator+quiet

check: $(BUILD)/obj/counter/sim
	@mkdir -p $(BUILD)/logs
	@printf '\n==> your counter\n'
	@$(BUILD)/obj/counter/sim +verilator+quiet | tee $(BUILD)/logs/counter.log
	@printf '\n'
	@grep -qF 'completed tb_counter' $(BUILD)/logs/counter.log \
	  && printf 'PASS Lesson 1 student workspace\n' \
	  || { printf 'FAIL — rtl/counter.sv does not do what README.md asks yet\n'; exit 1; }

$(BUILD)/obj/counter/sim: rtl/counter.sv tb/tb_counter.sv
	@mkdir -p $(BUILD)/obj/counter $(BUILD)/waves
	@$(VERILATOR) $(VFLAGS) -Mdir $(BUILD)/obj/counter --top-module tb_counter \
	    -o sim rtl/counter.sv tb/tb_counter.sv

wave: check
	@printf '\nYour counter:\n'
	@printf '  vcdtui %s/waves/counter.vcd --scope tb_counter \\\n' $(BUILD)
	@printf '         -s clk,start,dec,in4,value4,stop4 --dump\n\n'

clean:
	@rm -rf $(BUILD)
