.PHONY: test wave clean

test:
	./scripts/run_tests.sh

wave:
	gtkwave sim/waves/sync_fifo.vcd

clean:
	rm -f sim/sync_fifo_sim
	rm -f sim/waves/*.vcd
