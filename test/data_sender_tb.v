
module data_sender_tb();
    `SETUP_TEST
    reg clk;
    reg rst;

    reg transmission_started;
    reg transmission_done;
    reg [39:0] signal_to_send;
    wire [7:0] byte_to_send;

    initial begin
        $dumpfile(`VCD_OUTPUT);
        $dumpvars(0, data_sender_tb);
        clk = 0;
        signal_to_send = 0;
        transmission_done = 0;
        transmission_started = 0;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        // Reset signal
        rst = 1;
        #2
        rst = 0;

        // Give initial data
        signal_to_send = 'h1122334455;
        transmission_started = 1;

        #2
        transmission_started = 0;
        // Ensure that the first byte of the new data is sent to the sender
        `ASSERT_EQ(byte_to_send, 'h55);
        #2

        // Ensure that the next data chunk is sent when transmission_done is
        // received
           transmission_done = 1; #2 transmission_done = 0;
        `ASSERT_EQ(byte_to_send, 'h44);
        // Ensure that this is always the case
        #2 transmission_done = 1; #2 transmission_done = 0;
        `ASSERT_EQ(byte_to_send, 'h33);
        #2 transmission_done = 1; #2 transmission_done = 0;
        `ASSERT_EQ(byte_to_send, 'h22);
        #2 transmission_done = 1; #2 transmission_done = 0;
        `ASSERT_EQ(byte_to_send, 'h11);


        rst = 1;
        #2
        rst = 0;
        // Ensure that the data can not be changed when transmission is in
        // progress
        transmission_started = 1;
        #2;
        transmission_started = 0;
        signal_to_send = 'h123456789a;
        #2;
        `ASSERT_EQ(byte_to_send, 'h55);
           transmission_done = 1; #2 transmission_done = 0;
        `ASSERT_EQ(byte_to_send, 'h44);
        #2 transmission_done = 1; #2 transmission_done = 0;
        `ASSERT_EQ(byte_to_send, 'h33);
        #2 transmission_done = 1; #2 transmission_done = 0;
        `ASSERT_EQ(byte_to_send, 'h22);
        #2 transmission_done = 1; #2 transmission_done = 0;
        `ASSERT_EQ(byte_to_send, 'h11);

        #2
        transmission_started = 1;
        #2
        transmission_started = 0;

        // Ensure that the new data is sent now that transmission start is low
        #2;
        `ASSERT_EQ(byte_to_send, 'h9a);
           transmission_done = 1; #2 transmission_done = 0;
        `ASSERT_EQ(byte_to_send, 'h78);
        #2 transmission_done = 1; #2 transmission_done = 0;
        `ASSERT_EQ(byte_to_send, 'h56);
        #2 transmission_done = 1; #2 transmission_done = 0;
        `ASSERT_EQ(byte_to_send, 'h34);
        #2 transmission_done = 1; #2 transmission_done = 0;
        `ASSERT_EQ(byte_to_send, 'h12);



        #10

        `END_TEST
    end


    DataSender ds (
        .clk(clk),
        .rst(rst),
        .dataIn(signal_to_send),
        .dataOut(byte_to_send),
        .transmission_done(transmission_done),
        .transmission_started(transmission_started)
    );

endmodule
