###########################################################################################
# STARS 2025 - Makefile for SystemVerilog Projects
# By Miguel Isrrael Teran, Alex Weyer, Johnny Hazboun, Ben Miller
# 
# Set tab spacing to 2 spaces per tab for best viewing results
###########################################################################################

export PATH := /home/shay/a/ece270/bin:$(PATH)
export LD_LIBRARY_PATH := /home/shay/a/ece270/lib:$(LD_LIBRARY_PATH)

YOSYS=yosys
NEXTPNR=nextpnr-ecp5
SHELL=bash 

MAP = mapped
TB	=  testbench
SRC = source
BUILD = build

FPGA_TOP = top
PLL     = support/ecp5PLL.v
ECP   	= support/ecp5wrapper.sv
UART	= support/uart*.v
PINMAP = support/pinmap.lpf
FPGA_TIMING_CELLS = support/*.v

DEVICE  = 85k
FOOTPRINT=CABGA381

help:
	@echo -e "Help..."
	@cat support/help.txt

# *******************************************************************************
# COMPILATION & SIMULATION TARGETS
# *******************************************************************************

# Source Compilation and simulation of Design
.PHONY: sim_%_src
sim_%_src: 
	@echo -e "Creating executable for source simulation...\n"
	@mkdir -p $(BUILD) && rm -rf $(BUILD)/*
	@iverilog -g2012 -o $(BUILD)/$*_tb -Y .sv -y $(SRC) $(TB)/$*_tb.sv
	@echo -e "\nSource Compilation complete!\n"
	@echo -e "Simulating source...\n"
	@vvp -l vvp_sim.log $(BUILD)/$*_tb
	@echo -e "\nSimulation complete!\n"
	@echo -e "\nOpening waveforms...\n"
	@if [ -f waves/$*.gtkw ]; then \
		gtkwave waves/$*.gtkw; \
	else \
		gtkwave waves/$*.vcd; \
	fi


# Run synthesis on Design
.PHONY: syn_%
syn_%:
	@echo -e "Synthesizing design...\n"
	@mkdir -p $(MAP)
	$(YOSYS) -p "read_verilog -sv -noblackbox $(SRC)/*; synth_ecp5 -top $*; clean; write_verilog $(MAP)/$*.v"
	@echo -e "\nSynthesis complete!\n"


# Compile and simulate synthesized design
.PHONY: sim_%_syn
sim_%_syn: syn_%
	@echo -e "Compiling synthesized design...\n"
	@mkdir -p $(BUILD) && rm -rf $(BUILD)/*
	@iverilog -g2012 -o $(BUILD)/$*_tb -DFUNCTIONAL -DUNIT_DELAY=#1 $(TB)/$*_tb.sv $(MAP)/$*.v $(FPGA_TIMING_CELLS)
	@echo -e "\nCompilation complete!\n"
	@echo -e "Simulating synthesized design...\n\n"
	@vvp -l vvp_sim.log $(BUILD)/$*_tb
	@echo -e "\nSimulation complete!\n"
	@echo -e "\nOpening waveforms...\n"
	@if [ -f waves/$*.gtkw ]; then \
		gtkwave waves/$*.gtkw; \
	else \
		gtkwave waves/$*.vcd; \
	fi


# Lint Design Only
.PHONY: vlint_%
vlint_%:
	@verilator --lint-only -Wall -y $(SRC) $(SRC)/$*.sv $(TB) $(TB)/$*.sv
	@echo -e "\nNo linting errors found!\n"
 	

# *******************************************************************************
# FPGA TARGETS
# *******************************************************************************

# Check code and synthesize design into a JSON netlist
$(BUILD)/$(FPGA_TOP).json : $(ECP) $(SRC) $(PINMAP)
	# lint with Verilator
	verilator --lint-only --top-module top -Werror-latch -y $(SRC) $(SRC)/top.sv
	# if build folder doesn't exist, create it
	mkdir -p $(BUILD)
	# synthesize using Yosys
	mkdir -p $(MAP)
	$(YOSYS) -p "read_verilog -sv -noblackbox $(ECP) $(PLL) $(UART) $(SRC)/*; synth_ecp5 -top ecp5wrapper -json $(BUILD)/$(FPGA_TOP).json; write_verilog $(MAP)/ecp5wrapper.v" 


# Place and route design using nextpnr
$(BUILD)/$(FPGA_TOP).config : $(BUILD)/$(FPGA_TOP).json
	# Place and route using nextpnr
	$(NEXTPNR) --um5g-85k --package CABGA381 --lpf $(PINMAP) --textcfg $(BUILD)/$(FPGA_TOP).config --json $(BUILD)/$(FPGA_TOP).json 2> >(sed -e 's/^.* 0 errors$$//' -e '/^Info:/d' -e '/^[ ]*$$/d' 1>&2)


# Convert to bitstream using IcePack
$(BUILD)/$(FPGA_TOP).bin : $(BUILD)/$(FPGA_TOP).config
	ecppack $(BUILD)/$(FPGA_TOP).config $(BUILD)/$(FPGA_TOP).bin


# Upload design to the FPGA's flash memory
flash: clean $(BUILD)/$(FPGA_TOP).bin
	ecpprog $(BUILD)/$(FPGA_TOP).bin


# Upload design to the FPGA's non-volatile RAM
cram: clean $(BUILD)/$(FPGA_TOP).bin
	ecpprog -S $(BUILD)/$(FPGA_TOP).bin

# Clean temporary files
clean:
	rm -rf build/ mapped/ *.log waves/*.vcd


