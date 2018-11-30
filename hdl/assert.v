// RESET \033[0m
// RED \033[0;31m
// GREEN \033[0;32m

`define ASSERT(test) if(!(test)) begin $display("[\033[0;31m%m\033[0m] Assertion failed <test>"); $finish(-1); end
`define END_TEST $display("[\033[0;32m%m\033[0m] : All tests passed"); $finish();
