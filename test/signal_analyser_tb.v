module signal_analyser_tb();
    `SETUP_TEST
    reg clk;
    reg rst;
    reg [7:0] d;
    wire [32:0] t;
    wire [7:0] dOut;


    initial begin
        $dumpfile(`VCD_OUTPUT);
        $dumpvars(0, signal_analyser_tb);
        clk = 0;
        #1;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        rst = 1;
        #2
        rst = 0;

        d = 69;
        #1
        `ASSERT_EQ(t, 0)
        `ASSERT_EQ(dOut, 69)

        # 5;
        d = 100;
        #1;
        `ASSERT_EQ(t, 5)
        `ASSERT_EQ(dOut, 100)

        


        `END_TEST
    end
endmodule
