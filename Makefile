TB=test/spi_test.v
MAIN=top.v
APIO_FILES=apio.ini pins.pcf


verilog/%: %.hs
	stack exec -- clash --verilog $<

sim: build_hs
	@iverilog -o spi_tb.out -D VCD_OUTPUT=spi_tb.vcd verilog/Spi/SPIReader/*.v ${TB}
	@echo ""
	@vvp spi_tb.out


build_hs: *.hs



copy_project:
	@mkdir -p build_dir
	@cp $(wildcard verilog/Spi/SPIReader/*.v) ${MAIN} ${APIO_FILES} build_dir

build: build_hs copy_project
	@apio build -p build_dir


upload: copy_project
	@apio upload -p build_dir




gtkwave:
	gtkwave dump.vcd &



