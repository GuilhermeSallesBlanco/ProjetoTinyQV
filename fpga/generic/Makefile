TOP = tinyQV_top # Arquivo top
LPF = ProjetoTinyQV.lpf # Arquivo LPF
DEVICE = --45k # Dispositivo alvo
PACKAGE = --package CABGA381 # Pacote do dispositivo
FREQMHZ = 25 # Frequência do clock em MHz

# Project setup
PROJ = tinyqv

# TinyQV program to run - the $PROG.hex file must be in this directory
PROG ?= ledstrip # Rodar `make PROG=[nome do programa]` para mudar o programa

# Files
FILES = top.v peripherals.v sim_qspi.v bram.v ../../src/tinyQV/cpu/*.v ../../src/tinyQV/peri/uart/*.v ../../src/peri_byte_example.v ../../src/peri_full_example.v ../../src/peri_full_empty.v ../../src/peri_byte_empty.v ../../src/user_peripherals/*.v ../../src/user_peripherals/*.sv ../../src/user_peripherals/*/*.v ../../src/user_peripherals/*/*.sv

.PHONY: clean burn run

all: $(PROJ).bit

# Lint
#verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-MULTITOP $(FILES)

# synthesize using Yosys
$(PROJ).json: $(FILES)
	yosys -p "read -sv $(FILES) ; synth_ecp5 -top $(TOP) -json $(PROJ).json" -DECP5 -DPURE_RTL -DSYNTH_FPGA -DPROG_FILE=\"$(PROG).hex\"  > yosys.log
# 	@grep Warn yosys.log || true
# 	@grep Error yosys.log || true
# 	@grep "   Number of cells" yosys.log
# 	@grep "     SB_DFF" yosys.log | awk '{sum+=$$2;}END{printf("     SB_DFF* %25d\n", sum);}'
# 	@grep "     SB_LUT" yosys.log
# 	@echo

# Place and route using nextpnr
$(PROJ).config: $(PROJ).json $(LPF)
	nextpnr-ecp5 --json $(PROJ).json --textcfg $(PROJ).config $(DEVICE) $(PACKAGE) --lpf $(LPF) --lpf-allow-unconstrained --freq $(FREQMHZ)
# 	@grep Warn nextpnr.log || true
# 	@grep Error nextpnr.log || true
# 	@grep "Max frequency.*clk" nextpnr.log | tail -1
# 	@echo

	# Convert to bitstream using IcePack
$(PROJ).bit: $(PROJ).config
	ecppack $(PROJ).config $(PROJ).bit --compress

stats:
# 	@grep Warn yosys.log | grep -v tri-state || true
# 	@grep Error yosys.log || true
# 	@grep Warn nextpnr.log || true
# 	@grep Error nextpnr.log || true
# 	@grep "Max frequency.*clk" nextpnr.log | tail -1
# 	@echo "| Item | Count |"
# 	@echo "| ---- | ----- |"
# 	@grep "   Number of cells" yosys.log | awk '{printf("| Cells | %s |\n", $$4);}'
# 	@grep "     SB_DFF" yosys.log | awk '{sum+=$$2;}END{printf("| SB_DFF* | %d |\n", sum);}'
# 	@grep "     SB_LUT" yosys.log | awk '{printf("| %s | %s |\n", $$1, $$2);}'
# 	@grep "     ICESTORM_LC" nextpnr.log | awk '{gsub(/\//, "", $$3);printf("| ICE40 LCs | %s |\n", $$3);}'

clean:
	rm -f $(PROJ).json $(PROJ).config $(PROJ).bit yosys.log nextpnr.log
