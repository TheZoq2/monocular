module spi_tb();
    `SETUP_TEST
    reg clk;
    reg rst;
    reg spi_clk;
    reg mosi;
    reg [7:0] output_data;
    wire miso;
    wire received;
    wire [7:0] spi_out;

    initial begin
        $dumpfile(`VCD_OUTPUT);
        $dumpvars(0, spi_tb);
        clk = 0;
        mosi = 0;
        spi_clk = 0;
        #1;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        output_data = 'b10101011;
        rst = 1;
        #2
        rst = 0;
        #4

        #10

        // Bit0
           mosi = 1; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 1; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 0; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 0; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 1; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 0; #1 spi_clk = 1; #4 spi_clk = 0;
        output_data = 'b00001010;
        #3 mosi = 1; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 1; #1 spi_clk = 1; #4 spi_clk = 0;

        `ASSERT_EQ(spi_out, 'b11001011);


        #10

        // Bit0
           mosi = 1; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 1; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 1; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 1; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 0; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 0; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 0; #1 spi_clk = 1; #4 spi_clk = 0;
        #3 mosi = 0; #1 spi_clk = 1; #4 spi_clk = 0;

        `ASSERT_EQ(spi_out, 'b11110000);

        #10

        `END_TEST
    end

    SPIReader reader
        ( .clk(clk)
        , .rst(rst)
        , .spi_clk(spi_clk)
        , .mosi(mosi)
        , .miso(miso)
        , .toOutput(output_data)
        , .data(spi_out)
        , .received(newData)
        );
endmodule
