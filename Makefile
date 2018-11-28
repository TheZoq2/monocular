sim:
	stack exec -- clash --verilog spi.hs
	cp verilog/Counter/counter/counter.v counter.v
	cp verilog/Spi/SPIReader/SPIReader.v spi.v
	iverilog -o spi_tb.out -D VCD_OUTPUT=spi_tb.vcd spi.v spi_test.v
	vvp spi_tb.out


gtkwave:
	gtkwave dump.vcd &
