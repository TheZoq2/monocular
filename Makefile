SPI_FILES=$(wildcard verilog/Spi/SPIReader/*.v)
TB=test/spi_test.v
MAIN=top.v

sim:
	stack exec -- clash --verilog spi.hs
	cp verilog/Spi/SPIReader/* .
	iverilog -o spi_tb.out -D VCD_OUTPUT=spi_tb.vcd ${SPI_FILES} ${TB}
	vvp spi_tb.out





gtkwave:
	gtkwave dump.vcd &
