// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU,  // USB pull-up resistor
    output PIN_3,
    input PIN_1,
    input PIN_2,

    // Reset pin
    input PIN_13,

    // Debug pin
    output PIN_4,

    input PIN_5,
    input PIN_6,
    input PIN_7,
    input PIN_8,
    input PIN_9,
    input PIN_10,
    input PIN_11,
    input PIN_12,

    output PIN_14,
    output PIN_15,
    output PIN_16,
    output PIN_17,
    output PIN_18,
    output PIN_19,
    output PIN_20,
    output PIN_21,
);
    wire [7:0] spi_read_byte;
    wire new_spi_byte;

    wire spi_clk = PIN_1;
    wire mosi = PIN_2;
    wire miso = PIN_3;
    wire spi_debug = PIN_4;
    wire reset = PIN_13;


    // SPIReader reader
    //     ( .clk(CLK)
    //     , .rst(reset)
    //     , .spi_clk(spi_clk_buffered)
    //     , .mosi(mosi)
    //     , .miso(miso)
    //     , .data(spi_read_byte)
    //     , .received(new_spi_byte)
    //     , .to_output('b10000001)
    //     );

    wire [7:0] pin_values =
        { PIN_5
        , PIN_6
        , PIN_7
        , PIN_8
        , PIN_9
        , PIN_10
        , PIN_11
        , PIN_12
        };


    main_module main
        ( .clk(CLK)
        , .rst(reset)
        , .pin_values(pin_values)
        , .spi_clk(spi_clk_buffered)
        , .mosi(mosi)
        , .miso(miso)
        );


    assign USBPU = 0;
    ////////////////////////////////////////////////////////////////////////////////
    //                          SPI clock buffering
    ////////////////////////////////////////////////////////////////////////////////
    reg spi_clk_buffered;
    reg [1:0] spi_buffer;

    always @(posedge CLK) begin
        case (spi_buffer)
            'b11: spi_clk_buffered = 1;
            'b00: spi_clk_buffered = 0;
            default: spi_clk_buffered = spi_clk_buffered;
        endcase
        spi_buffer = {spi_buffer[0], spi_clk};
    end




    ////////////////////////////////////////////////////////////////////////////////
    //                          Clock debug
    ////////////////////////////////////////////////////////////////////////////////
    reg [2:0] clk_counter;
    always @(posedge CLK) begin
        if (reset) begin
            clk_counter = 0;
        end else begin
            if (spi_clk) begin
                clk_counter = clk_counter + 1;
            end
        end
    end


    ////////////////////////////////////////////////////////////////////////////////
    //                          Debug output
    ////////////////////////////////////////////////////////////////////////////////
    assign
        { PIN_14
        , PIN_15
        , PIN_16
        , PIN_17
        , PIN_18
        , PIN_19
        , PIN_20
        , PIN_21
        } = pin_values;
endmodule


