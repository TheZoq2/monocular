module signal_analyser_tb();
    `SETUP_TEST
    reg clk;
    reg rst;
    reg [7:0] mask;
    reg [7:0] d;
    wire [31:0] t;
    wire [7:0] dOut;
    wire newData;
    reg data_sent;


    initial begin
        $dumpfile(`VCD_OUTPUT);
        $dumpvars(0, signal_analyser_tb);
        clk = 0;
        d = 0;
        data_sent = 0;
        mask = 'hff;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        // Reset signal
        rst = 1;
        #0 @(negedge clk)
        rst = 0;

        d = 69;

        // Set data just after reset
        // Wait for one clock cycle and verify that the time and data are
        // correct
        @(negedge clk)
        `ASSERT_EQ(t, 0)
        `ASSERT_EQ(dOut, 69)
        `ASSERT_EQ(newData, 1)

        // Verify that the data hasn't changed
        @(negedge clk)
        `ASSERT_EQ(dOut, 69)
        `ASSERT_EQ(newData, 0)

        // Verify that time does not update until a change has been sent
        `ASSERT_EQ(t, 0)
        data_sent = 1;
        @(negedge clk)
        data_sent = 0;
        @(negedge clk)
        `ASSERT_EQ(t, 3)

        @(negedge clk)

        // Set new data, verify that it is updated
        d = 100;
        @(negedge clk)
        `ASSERT_EQ(t, 5)
        `ASSERT_EQ(dOut, 100)
        `ASSERT_EQ(newData, 1)
        @(negedge clk)
        `ASSERT_EQ(newData, 0)


        // Add a mask and ensure that the masked bytes are now set to 0
        mask = 'b11110000;
        d = 'b11010010;
        @(negedge clk)
        `ASSERT_EQ(dOut, 'b11010000)


        #3;

        `END_TEST
    end

    SignalAnalyser analyser (
        .clk(clk),
        .rst(rst),
        .data_in(d),
        .data_time(t),
        .data_out(dOut),
        .new_data(newData),
        .data_sent(data_sent),
        .channel_mask(mask)
    );
endmodule
