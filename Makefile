MAIN=top.v
APIO_FILES=apio.ini pins.pcf
BUILD_DIR=build
APIO_BUILD_DIR=apio_build
HDL = $(wildcard hdl/*.v)


hs_files := $(wildcard *.hs)
hs_targets := $(patsubst %.hs, verilog/%/built, $(wildcard *.hs))

test_files := $(wildcard test/*.v)
vcds := $(patsubst test/%.v, %.vcd, ${test_files})


.SECONDEXPANSION:
verilogs=$(shell find verilog -name '*.v')



ring_kompilatorn: sim

build_hs: $(hs_targets)


verilog/%/built: %.hs
	@echo -e "[\033[0;34mclash\033[0m] Building $<"
	@stack exec -- clash --verilog $<
	@touch $@


sim: build_hs $(vcds)

%.vcd: test/%.v hdl/*.v
	@mkdir -p bin
	@mkdir -p output
	@iverilog -o bin/${<F}.out -g2012 -gverilog-ams -gassertions  -DVCD_OUTPUT=\"output/${<F}.out\" ${HDL} $< ${verilogs}
	@vvp bin/${<F}.out | grep -v dumpfile


build: build_hs
	@mkdir -p ${APIO_BUILD_DIR}
	@cp ${MAIN} ${verilogs} ${APIO_FILES} ${APIO_BUILD_DIR}
	@apio build -p ${APIO_BUILD_DIR}

upload: build
	@apio upload -p ${APIO_BUILD_DIR}

clean:
	rm verilog -rf
	rm output -rf
	rm bin -rf
	rm ${APIO_BUILD_DIR} -rf
	rm ${BUILD_DIR} -rf


iverilog_commandfile: build_hs
	@echo -e $(patsubst %, '-l %\n', ${HDL} ${verilogs}) > .verilog_config

