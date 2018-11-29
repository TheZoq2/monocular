SPI_FILES=$(wildcard verilog/Spi/SPIReader/*.v)
TB=test/spi_test.v
MAIN=top.v
APIO_FILES=apio.ini pins.pcf

sim:
	@stack exec -- clash --verilog spi.hs
	@echo ""
	@iverilog -o spi_tb.out -D VCD_OUTPUT=spi_tb.vcd ${SPI_FILES} ${TB}
	@echo ""
	@vvp spi_tb.out

copy_project:
	@mkdir -p build_dir
	@cp ${SPI_FILES} ${MAIN} ${APIO_FILES} build_dir

build:
	@make copy_project
	@apio build -p build_dir


upload:
	@make copy_project
	@apio upload -p build_dir




gtkwave:
	gtkwave dump.vcd &
