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

    output PIN_14,
    output PIN_15,
    output PIN_16,
    output PIN_17,
    output PIN_18,
    output PIN_19,
    output PIN_20,
    output PIN_21,

    // RST forwarding
    output PIN_5
);
    wire [7:0] spi_read_byte;
    wire new_spi_byte;

    wire spi_clk = PIN_1;


    SPIReader reader
        ( .clk(CLK)
        , .rst(PIN_13)
        , .spi_clk(spi_clk_buffered)
        , .mosi(PIN_2)
        , .miso(PIN_3)
        , .data(spi_read_byte)
        , .received(new_spi_byte)
        , .to_output('b10000001)
        , .debug(PIN_4)
        );



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

    reg [2:0] clk_counter;

    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    assign PIN_5 = PIN_13;

    ////////
    // make a simple blink circuit
    ////////

    // keep track of time and location in blink_pattern
    reg [26:0] blink_counter;

    // pattern that will be flashed over the LED over time
    reg [7:0] blink_pattern;

    always @(posedge CLK) begin
        if (new_spi_byte) begin
            blink_pattern = spi_read_byte;
        end

        if (PIN_13) begin
            clk_counter = 0;
        end else begin
            if (PIN_1) begin
                clk_counter = clk_counter + 1;
            end
        end
    end

    // increment the blink_counter every clock
    always @(posedge CLK) begin
        blink_counter <= blink_counter + 1;
    end

    // light up the LED according to the pattern
    // assign LED = blink_pattern[pattern_index];
    //

    // assign PIN_14 = 1;
    assign
        { PIN_14
        , PIN_15
        , PIN_16
        , PIN_17
        , PIN_18
        , PIN_19
        , PIN_20
        , PIN_21
        } = clk_counter;
endmodule


