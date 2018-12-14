module signal_analyser_tb();
    `SETUP_TEST
    reg clk;
    reg rst;
    reg [7:0] d;
    wire [31:0] t;
    wire [7:0] dOut;
    wire newData;


    initial begin
        $dumpfile(`VCD_OUTPUT);
        $dumpvars(0, signal_analyser_tb);
        clk = 0;
        d = 0;
        #1;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        // Reset signal
        rst = 1;
        #2
        rst = 0;

        // Set data just after reset
        d = 69;
        // Wait for one clock cycle and verify that the time and data are
        // correct
        #2
        `ASSERT_EQ(t, 0)
        `ASSERT_EQ(dOut, 69)
        `ASSERT_EQ(newData, 1)

        // Verify that the time and data hasn't changed
        #2;
        `ASSERT_EQ(t, 0)
        `ASSERT_EQ(dOut, 69)
        `ASSERT_EQ(newData, 0)

        // Set new data, verify that it is updated
        #2;
        d = 100;
        #2;
        `ASSERT_EQ(t, 3)
        `ASSERT_EQ(dOut, 100)
        `ASSERT_EQ(newData, 1)
        #2;
        `ASSERT_EQ(newData, 0)


        #3;

        `END_TEST
    end

    SignalAnalyser analyser (
        .clk(clk),
        .rst(rst),
        .data_in(d),
        .data_time(t),
        .data_out(dOut),
        .new_data(newData)
    );
endmodule
