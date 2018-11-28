// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU,  // USB pull-up resistor
    input PIN_1,
    input PIN_2,
    input PIN_3,
    input PIN_4
);
    wire [7:0] spi_read_byte;
    wire new_spi_byte;

    SPIReader reader
        ( .clk(CLK)
        , .rst(0)
        , .spi_clk(PIN_1)
        , .mosi(PIN_2)
        , .data(spi_read_byte)
        , .received(new_spi_byte)
        );

    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    ////////
    // make a simple blink circuit
    ////////

    // keep track of time and location in blink_pattern
    reg [26:0] blink_counter;

    // pattern that will be flashed over the LED over time
    wire [7:0] blink_pattern = spi_read_byte;

    // increment the blink_counter every clock
    always @(posedge CLK) begin
        blink_counter <= blink_counter + 1;
    end
    
    wire [0:3] pattern_index;
    assign pattern_index = blink_counter[25:21];

    // light up the LED according to the pattern
    assign LED = blink_pattern[pattern_index];
endmodule


