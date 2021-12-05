# Gleefully stolen from https://github.com/icebreaker-fpga/icebreaker-verilog-examples

PROJ=top
PIN_DEF=icebreaker.pcf
DEVICE=up5k
PACKAGE=sg48

TESTBENCHES:=$(wildcard *_tb.sv)
TB_WAVES:=$(patsubst %_tb.sv,%_tb.vcd,$(TESTBENCHES))
MODULES:=$(filter-out $(TESTBENCHES),$(wildcard *.sv))

TEST_SRC:=$(wildcard dummy*.sv)
ADD_SRC:=$(filter-out top.sv,$(MODULES))
ADD_SRC:=$(filter-out $(TEST_SRC),$(ADD_SRC))
ADD_CLEAN:=$(TB_WAVES)

all: $(PROJ).bin

test: $(TB_WAVES)

%.json: %.sv $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log -p 'synth_ice40 -top top -json $@' $< $(ADD_SRC)

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) \
	$(if $(PACKAGE),--package $(PACKAGE)) \
	--json $(filter-out $<,$^) \
	--pcf $< \
	--asc $@ \
	$(if $(PNR_SEED),--seed $(PNR_SEED))

%.bin: %.asc
	icepack $< $@

%_tb: %_tb.sv %.sv $(ADD_SRC) $(TEST_SRC)
	iverilog -g2012 -o $@ $^

%_tb.vcd: %_tb
	vvp -N $< +vcd=$@

%_syn.v: %.json
	yosys -p 'read_json $^; write_verilog $@'

%_syntb: %_tb.sv %_syn.v
	iverilog -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

%_syntb.vcd: %_syntb
	vvp -N $< +vcd=$@

iceprog: $(PROJ).bin
	iceprog $<

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).bin $(PROJ).json $(PROJ).log $(ADD_CLEAN)

info:
	@echo $(wildcard *.sv)
	@echo $(TESTBENCHES)
	@echo $(MODULES)
	@echo $(TB_WAVES)
