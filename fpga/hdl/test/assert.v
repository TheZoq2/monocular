// RESET \033[0m
// RED \033[0;31m
// GREEN \033[0;32m

`define SETUP_TEST reg __failed = 0;


// `define ASSERTION_ERROR $write("[\033[0;31m%s\033[0m: %d] Assertion failed: ", `__FILE__, `__LINE__);
`define ASSERTION_ERROR $write("["); \
    $write("\033[0;31m"); \ // Red
    $write("%m"); \ // Filename
    $write("\033[0m"); \ // Reset colour
    $write(": %0d", `__LINE__); \ // : <line number>
    $write("]"); \
    $write("Assertion failed: ");


`define ASSERT_EQ(expr, cond) \
    if ((expr === cond) == 0) begin \
        __failed = 1; \
        `ASSERTION_ERROR; \
        $display("was %h, expected %h", expr, cond); \
    end
        // `ASSERTION_ERROR \
        // ASSERTION_ERROR($write(" /= cond")) \

`define END_TEST \
    if(__failed == 0) begin \
        $display("[\033[0;32m%m\033[0m] : All tests passed"); \
    end \
    $finish();
