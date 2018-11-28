/*
// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU,  // USB pull-up resistor
    output PIN_13,
    output PIN_12,
    output PIN_11,
    input PIN_1,
    input PIN_2,
    input PIN_3,
    input PIN_4
);
    wire [7:0] spi_read_byte;
    wire new_spi_byte;

    Spi spi (
        .CLK(CLK),
        .master_clock(PIN_1),
        .mosi(PIN_2),
        .miso(PIN_3),
        .last_byte(spi_read_byte),
        .new_byte(new_spi_byte),
        .slave_select(PIN_4)
    );

    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    ////////
    // make a simple blink circuit
    ////////

    // keep track of time and location in blink_pattern
    reg [26:0] blink_counter;

    // pattern that will be flashed over the LED over time
    wire [31:0] blink_pattern = 32'b101010001110111011100010101;

    // increment the blink_counter every clock
    always @(posedge CLK) begin
        blink_counter <= blink_counter + 1;
    end
    
    wire [0:3] pattern_index;
    assign pattern_index = blink_counter[25:21];

    // light up the LED according to the pattern
    // assign LED = blink_pattern[pattern_index];
    // assign PIN_13 = blink_pattern[pattern_index + 1];
    // assign PIN_12 = blink_pattern[pattern_index + 2];
    // assign PIN_11 = blink_pattern[pattern_index + 3];
    assign LED = spi_read_byte[3];
    assign PIN_13 = spi_read_byte[2];
    assign PIN_12 = spi_read_byte[1];
    assign PIN_11 = spi_read_byte[0];
endmodule


*/
