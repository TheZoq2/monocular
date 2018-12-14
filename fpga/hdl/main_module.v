module main_module
    ( input clk
    , input rst
    , input [7:0] pin_values
    , input spi_clk
    , input mosi
    , output miso
    );

    wire spi_byte_received;
    wire [7:0] spi_tx_data;
    wire transmission_started;

    SPIReader spi
        ( .clk(clk)
        , .rst(rst)
        , .spi_clk(spi_clk)
        , .to_output(spi_tx_data)
        , .miso(miso)
        , .mosi(mosi)
        , .received(spi_byte_received)
        , .transmission_started(transmission_started)
        );


    wire [39:0] data_to_send;

    DataSender ds
        ( .clk(clk)
        , .rst(rst)
        , .dataIn(data_to_send)
        , .transmission_done(spi_byte_received)
        , .dataOut(spi_tx_data)
        , .transmission_started(transmission_started)
        );

    SignalAnalyser sa
        ( .clk(clk)
        , .rst(rst)
        , .data_in(pin_values)
        , .data_time(data_to_send[39:8])
        , .data_out(data_to_send[7:0])
        );

endmodule
