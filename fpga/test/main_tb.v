module main_tb();
    `SETUP_TEST
    reg clk;
    reg rst;
    reg spi_clk;
    reg mosi;
    reg [7:0] pin_values;
    wire miso;

    reg [31:0] current_time;
    reg [31:0] tx_start_time;
    reg [31:0] change_time;

    integer i;
    integer b;

    initial begin
        $dumpfile(`VCD_OUTPUT);
        $dumpvars(0, main_tb);
        clk = 0;
        mosi = 0;
        spi_clk = 0;
        pin_values = 0;
        current_time = 0;
        #1;
        forever begin
            #1 clk = ~clk;

        end
    end

    always @(posedge clk) begin
        if (rst == 1)
            current_time = 0;
        else
            current_time = current_time + clk;
    end

    initial begin
        rst=1;
        #2;
        rst=0;
        #2;

        // Ensure that the data on the port is sent
        pin_values = 'b1101_0010;
        tx_start_time = current_time;
        #3

        `ASSERT_EQ(miso, 1);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; #4 spi_clk = 0; #4;

        // Set some new data
        pin_values = 'b0010_1101;
        change_time = current_time;
        // Check clock data
        for (b = 0; b < 4; b = b + 1) begin
            for (i = 0; i < 8; i = i + 1) begin
                `ASSERT_EQ(miso, tx_start_time[(b+1) * 8 - i - 1]);
                spi_clk = 1;
                #4;
                spi_clk = 0;
                #4;
            end
        end

        tx_start_time = change_time;


        // Ensure that the new data is being transmitted
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 0);
        spi_clk = 1; #4 spi_clk = 0; #4;
        `ASSERT_EQ(miso, 1);
        spi_clk = 1; #4 spi_clk = 0; #4;

        // Check clock data
        for (b = 0; b < 4; b = b + 1) begin
            for (i = 0; i < 8; i = i + 1) begin
                `ASSERT_EQ(miso, tx_start_time[(b+1) * 8 - i - 1]);
                spi_clk = 1;
                #4;
                spi_clk = 0;
                #4;
            end
        end

        #10;
        `END_TEST
    end

    main_module main
        ( .clk(clk)
        , .rst(rst)
        , .miso(miso)
        , .mosi(mosi)
        , .spi_clk(spi_clk)
        , .pin_values(pin_values)
        );
endmodule
