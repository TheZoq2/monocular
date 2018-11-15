
module Spi (
    // Main clock
    input CLK,
    input slave_select,
    // SPI clock
    input master_clock,
    // Master in slave out
    input mosi,
    // Master out slave in
    output miso,
    // The last byte that was read
    output [7:0] last_byte,
    // set to true the clock cycle that a new byte arrived
    output new_byte
);
    // Constants
    parameter CLK_RISING_PATTERN = 'b01;
    parameter CLK_FALLING_PATTERN = 'b10;

    // Internal registers
    reg [1:0] r_master_clock;
    reg [7:0] data;
    reg [3:0] bits_received;
    reg mosi_buff;
    reg [1:0] r_slave_select;

    // Internal wires
    wire clk_rising = r_master_clock == CLK_RISING_PATTERN;
    wire clk_falling = r_master_clock == CLK_FALLING_PATTERN;


    // Output buffers
    reg [8:0] read_output;
    reg r_new_byte;
    // Actual outputs
    assign last_byte = read_output;
    assign new_byte = r_new_byte;


    always @(posedge CLK) begin
        mosi_buff <= mosi;
    end



    // Main process
    always @(posedge CLK) begin
        // Update the master clock shift register
        r_master_clock[1] <= r_master_clock[0];
        r_master_clock[0] <= master_clock;

        r_slave_select = {r_slave_select[0], slave_select};

        if(r_slave_select == CLK_FALLING_PATTERN) begin
            bits_received = 0;
        end

        // If the master clock is rising, store another bit
        if(clk_rising == 1) begin
            data <= {data[6:0], mosi_buff};
            bits_received = bits_received + 1;

            // If we read 8 bits, a new byte is ready and we should update the
            // output of the module
            if (bits_received == 8) begin
                read_output = data;
                r_new_byte = 1;
            end
            else begin
                r_new_byte = 0;
            end
        end
    end
endmodule

