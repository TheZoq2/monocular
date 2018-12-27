module control_message_decoder_tb();
    `SETUP_TEST

    reg clk;
    reg rst;
    reg [7:0] spi_byte;
    wire [7:0] channel_mask;


    initial begin
        $dumpfile(`VCD_OUTPUT);
        $dumpvars(0, control_message_decoder_tb);
        clk = 0;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        // Reset signal
        rst = 1;
        #0 @(negedge clk)
        rst = 0;

        // Unless anything else has been said, data mask should be 0
        `ASSERT_EQ(channel_mask, 0);

        spi_byte = 'hfe;
        @(negedge clk)
        spi_byte = 1;
        @(negedge clk)
        spi_byte = 'b11010010;
        @(negedge clk)
        `ASSERT_EQ(channel_mask, 'b11010010);



        `END_TEST
    end


    ControlMessageDecoder cmd
        ( .clk(clk)
        , .rst(rst)
        , .spi_byte(spi_byte)
        , .channel_mask(channel_mask)
        );
endmodule
