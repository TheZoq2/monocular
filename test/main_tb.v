module main_tb();
    `SETUP_TEST
    reg clk;
    reg rst;
    reg spi_clk;
    reg mosi;
    reg [7:0] pin_values;
    wire miso;

    initial begin
        $dumpfile(`VCD_OUTPUT);
        $dumpvars(0, main_tb);
        clk = 0;
        mosi = 0;
        spi_clk = 0;
        pin_values = 0;
        #1;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        rst=1;
        #2;
        rst=0;
        #2;

        // Ensure that the data on the port is sent
        pin_values = 'b1101_0010;
        #3

        `ASSERT_EQ(miso, 1);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; #4 spi_clk = 0; #4;

        // Check clock data
        repeat (32) begin
            `ASSERT_EQ(miso, 0);
            spi_clk = 1;
            #4;
            spi_clk = 0;
            #4;
        end

        #10;
        `END_TEST
    end

    main main
        ( .clk(clk)
        , .rst(rst)
        , .miso(miso)
        , .mosi(mosi)
        , .spi_clk(spi_clk)
        , .pin_values(pin_values)
        );
endmodule
