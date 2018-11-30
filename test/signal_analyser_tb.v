
module signal_analyser_tb();
    reg clk;
    reg rst;

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
        #4



        `END_TEST
    end
endmodule
