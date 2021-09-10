# Gleefully stolen from https://github.com/icebreaker-fpga/icebreaker-verilog-examples

PROJ=desynk
PIN_DEF=icebreaker.pcf
DEVICE=up5k
PACKAGE=sg48

ADD_CLEAN=$(PROJ)_tb.vcd

all: $(PROJ).bin

test: $(PROJ)_tb.vcd

%.json: %.v $(ADD_SRC) $(ADD_DEPS)
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

%_tb: %_tb.v %.v
	iverilog -g2012 -o $@ $^

%_tb.vcd: %_tb
	vvp -N $< +vcd=$@

%_syn.v: %.json
	yosys -p 'read_json $^; write_verilog $@'

%_syntb: %_tb.v %_syn.v
	iverilog -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

%_syntb.vcd: %_syntb
	vvp -N $< +vcd=$@

iceprog: $(PROJ).bin
	iceprog $<

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).bin $(PROJ).json $(PROJ).log $(ADD_CLEAN)
