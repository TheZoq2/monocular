module counter_tb();
    reg clk;
    reg rst;
    wire [31:0] counter_out;

    initial begin
        $dumpfile("counter_tb.vcd");
        $dumpvars(0, clk, counter_out, rst);
        clk = 0;
        #1;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        rst = 1;
        repeat (2) begin
            @(posedge clk);
        end
        rst = 0;
        repeat (100) begin
            @(posedge clk);
        end
        $finish();
    end

    counter counter (
        .clk(clk),
        .rst(rst),
        .counter_out(counter_out)
    );
endmodule
