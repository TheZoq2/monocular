MAIN=top.v
APIO_FILES=apio.ini pins.pcf
BUILD_DIR=build
APIO_BUILD_DIR=apio_build


hs_files := $(wildcard *.hs)
hs_targets := $(patsubst %.hs, verilog/%/built, $(wildcard *.hs))

test_files := $(wildcard test/*.v)
vcds := $(patsubst test/%.v, output/%.vcd, ${test_files})


.SECONDEXPANSION:
verilogs=$(shell find verilog -name '*.v')



ring_kompilatorn: sim

build_hs: $(hs_targets)


verilog/%/built: %.hs
	@stack exec -- clash --verilog $<
	@touch $@


sim: build_hs $(vcds)

output/%.vcd: test/%.v
	@mkdir -p bin
	@mkdir -p output
	@echo "Building ${<F}"
	@iverilog -o bin/${<F}.out -DVCD_OUTPUT=\"$@\" $< ${verilogs}
	@vvp bin/${<F}.out


build: build_hs
	@mkdir -p build
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
