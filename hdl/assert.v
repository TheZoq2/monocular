// RESET \033[0m
// RED \033[0;31m
// GREEN \033[0;32m

`define SETUP_TEST reg __failed = 0;


`define ASSERTION_ERROR $write("[\033[0;31m%m\033[0m] Assertion failed: ");


`define ASSERT_EQ(expr, cond) \
    if ((expr === cond) == 0) begin \
        __failed = 1; \
        `ASSERTION_ERROR; \
        $display("%h /= %h", expr, cond); \
    end
        // `ASSERTION_ERROR \
        // ASSERTION_ERROR($write(" /= cond")) \

`define END_TEST \
    if(__failed == 0) begin \
        $display("[\033[0;32m%m\033[0m] : All tests passed"); \
    end \
    $finish();
