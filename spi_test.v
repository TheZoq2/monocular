module spi_tb();
    reg clk;
    reg rst;
    reg spi_clk;
    reg mosi;
    wire received;
    wire [7:0] spi_out;

    initial begin
        $dumpfile("spi_tb.vcd");
        $dumpvars(0, clk, rst, spi_clk, mosi, spi_out, newData);
        clk = 0;
        mosi = 0;
        spi_clk = 0;
        #1;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        rst = 1;
        #2
        rst = 0;
        #4

        #10

        // Bit0
        mosi = 1;
        #1
        spi_clk = 1;
        #4
        spi_clk = 0;

        //Bit1
        #3
        mosi = 1;
        #1
        spi_clk = 1;
        #4
        spi_clk = 0;

        //bit 2
        #3
        mosi = 0;
        #1
        spi_clk = 1;
        #4
        spi_clk = 0;

        //bit 3
        #3
        mosi = 0;
        #1
        spi_clk = 1;
        #4
        spi_clk = 0;

        //bit 4
        #3
        mosi = 1;
        #1
        spi_clk = 1;
        #4
        spi_clk = 0;

        //bit 5
        #3
        mosi = 0;
        #1
        spi_clk = 1;
        #4
        spi_clk = 0;

        //bit 6
        #3
        mosi = 1;
        #1
        spi_clk = 1;
        #4
        spi_clk = 0;

        //bit 7
        #3
        mosi = 1;
        #1
        spi_clk = 1;
        #4
        spi_clk = 0;




        #10

        $finish();
    end

    SPIReader reader
        ( .clk(clk)
        , .rst(rst)
        , .spi_clk(spi_clk)
        , .mosi(mosi)
        , .data(spi_out)
        , .received(newData)
        );
endmodule
