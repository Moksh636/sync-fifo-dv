.RECIPEPREFIX := >

SEED ?= 12648430

.PHONY: test lint wave clean

test:
>SEED=$(SEED) ./scripts/run_tests.sh

lint:
>verilator --lint-only --sv -Wall rtl/sync_fifo.sv

wave:
>gtkwave sim/waves/sync_fifo.vcd

clean:
>rm -f sim/sync_fifo_sim
>rm -f sim/waves/*.vcd
>rm -rf obj_dir
