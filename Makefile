ring_kompilatorn:
	stack exec -- clash --verilog test.hs
	cp verilog/Counter/Counter_topEntity.v counter.v
