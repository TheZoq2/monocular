TB=test/spi_test.v
MAIN=top.v
APIO_FILES=apio.ini pins.pcf

sim:
	@make build_hs
	@echo ""
	@iverilog -o spi_tb.out -D VCD_OUTPUT=spi_tb.vcd $(wildcard verilog/Spi/SPIReader/*.v) ${TB}
	@echo ""
	@vvp spi_tb.out


build_hs:
	@stack exec -- clash --verilog spi.hs

copy_project:
	@mkdir -p build_dir
	@cp $(wildcard verilog/Spi/SPIReader/*.v) ${MAIN} ${APIO_FILES} build_dir

build:
	@make build_hs
	@make copy_project
	@apio build -p build_dir


upload:
	@make copy_project
	@apio upload -p build_dir




gtkwave:
	gtkwave dump.vcd &
