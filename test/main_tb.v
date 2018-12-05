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
        #2
        // Check clock data
        repeat (32) begin
            `ASSERT_EQ(miso, 0);
            spi_clk = 1;
            #4;
            spi_clk = 0;
            #4;
        end

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

        #10;
        $finish();
    end

    wire spi_byte_received;
    wire [7:0] spi_tx_data;

    SPIReader spi
        ( .clk(clk)
        , .rst(rst)
        , .spi_clk(spi_clk)
        , .miso(miso)
        , .mosi(mosi)
        , .received(spi_byte_received)
        );


    wire [39:0] data_to_send;

    DataSender ds
        ( .clk(clk)
        , .rst(rst)
        , .dataIn(data_to_send)
        , .transmissionDone(spi_byte_received)
        , .dataOut(spi_tx_data)
        );

    SignalAnalyser sa
        ( .clk(clk)
        , .rst(rst)
        , .dataIn(pin_values)
        , .dataTime(data_to_send[39:8])
        , .dataOut(data_to_send[7:0])
        );
endmodule
