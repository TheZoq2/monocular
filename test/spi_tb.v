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
    wire transmission_started;

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

        `ASSERT_EQ(transmission_started, 0)
        // Bit0
           mosi = 1; #1 spi_clk = 1; #4 spi_clk = 0;
        `ASSERT_EQ(transmission_started, 1)
        #3 mosi = 1; #1 spi_clk = 1; #4 spi_clk = 0;
        `ASSERT_EQ(transmission_started, 0)
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

        rst = 1; #2 rst = 0;

        output_data = 'b11010010;

        # 4

        `ASSERT_EQ(miso, 1);
        spi_clk = 1; # 4
        spi_clk = 0; # 4
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; # 4
        spi_clk = 0; # 4
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; # 4
        spi_clk = 0; # 4
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; # 4
        spi_clk = 0; # 4
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; # 4
        spi_clk = 0; # 4
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; # 4
        spi_clk = 0; # 4
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; # 4
        spi_clk = 0; # 4
        `ASSERT_EQ(miso, 0);



        # 10

        `END_TEST
    end

    SPIReader reader
        ( .clk(clk)
        , .rst(rst)
        , .spi_clk(spi_clk)
        , .mosi(mosi)
        , .miso(miso)
        , .to_output(output_data)
        , .data(spi_out)
        , .received(newData)
        );
endmodule
