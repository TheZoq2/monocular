// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU,  // USB pull-up resistor
    output PIN_19,
    input PIN_20,
    input PIN_18,

    // Reset pin
    input PIN_13,

    // Debug pin
    output PIN_4,

    input PIN_1,
    input PIN_2,
    input PIN_3,
    input PIN_4,
    input PIN_5,
    input PIN_6,
    input PIN_7,
    input PIN_8,
);
    wire [7:0] spi_read_byte;
    wire new_spi_byte;

    wire spi_clk = PIN_18;
    wire mosi = PIN_20;
    wire miso = PIN_19;
    // wire reset = PIN_13;
    wire reset = 0;


    wire [7:0] pin_values;

    assign pin_values[7] = PIN_1;
    assign pin_values[6] = PIN_2;
    assign pin_values[5] = PIN_3;
    assign pin_values[4] = PIN_4;
    assign pin_values[3] = PIN_5;
    assign pin_values[2] = PIN_6;
    assign pin_values[1] = PIN_7;
    assign pin_values[0] = PIN_8;


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
    /*
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
    */
endmodule


