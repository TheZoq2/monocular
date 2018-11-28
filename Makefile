sim:
	stack exec -- clash --verilog spi.hs
	cp verilog/Spi/SPIReader/* .
	iverilog -o spi_tb.out -D VCD_OUTPUT=spi_tb.vcd *.v
	vvp spi_tb.out


gtkwave:
	gtkwave dump.vcd &
