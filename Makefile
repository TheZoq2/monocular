MAIN=top.v
APIO_FILES=apio.ini pins.pcf
BUILD_DIR=build
APIO_BUILD_DIR=apio_build
HDL = $(wildcard hdl/*.v)


hs_files := $(wildcard *.hs)
hs_targets := $(patsubst %.hs, verilog/%/built, $(wildcard *.hs))

test_files := $(wildcard test/*.v)
vcds := $(patsubst test/%.v, output/%.v.vcd, ${test_files})


.SECONDEXPANSION:
verilogs=$(shell find verilog -name '*.v')
outfiles := $(patsubst test/%.v, bin/%.v.out, ${test_files})

.SECONDARY: $(outfiles)

ring_kompilatorn: sim

build_hs: $(hs_targets)


verilog/%/built: %.hs
	@echo -e "[\033[0;34mclash\033[0m] Building $<"
	@stack exec -- clash --verilog $<
	@touch $@


sim: build_hs $(vcds)

output/%.v.vcd: bin/%.v.out $(HDL) FORCE
	@mkdir -p output
	@echo -e "[\033[0;34mvvp\033[0m] simulating $<"
	@vvp $< | grep -v dumpfile


bin/%.v.out: test/%.v $(HDL) $(hs_targets)
	@echo -e "[\033[0;34miverilog\033[0m] building $@"
	@mkdir -p bin
	@iverilog -o ${@} -g2012 -gverilog-ams -gassertions  -DVCD_OUTPUT=\"output/${<F}.vcd\" ${HDL} $< ${verilogs}


build: build_hs
	@mkdir -p ${APIO_BUILD_DIR}
	@cp ${MAIN} ${verilogs} ${APIO_FILES} ${APIO_BUILD_DIR}
	@echo -e "[\033[0;34mapio\033[0m] building"
	@apio build -p ${APIO_BUILD_DIR}

upload: build
	@echo -e "[\033[0;34mapio\033[0m] uploading"
	@apio upload -p ${APIO_BUILD_DIR}

clean:
	rm verilog -rf
	rm output -rf
	rm bin -rf
	rm ${APIO_BUILD_DIR} -rf
	rm ${BUILD_DIR} -rf


FORCE:

iverilog_commandfile: build_hs
	@echo -e $(patsubst %, '-l %\n', ${HDL} ${verilogs}) > .verilog_config

