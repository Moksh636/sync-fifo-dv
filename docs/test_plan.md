# FIFO Verification Test Plan

## Project

Parameterized Synchronous FIFO Design and Verification in SystemVerilog.

## Testbench

Top-level testbench:

- tb/tb_sync_fifo.sv

Simulation script:

- scripts/run_tests.sh

## Directed Tests

| Test | Purpose | Expected Result |
|---|---|---|
| Reset test | Verify reset initializes FIFO | empty=1, full=0, count=0 |
| Single write/read | Verify one value can be written and read back | read data equals written data |
| Fill test | Verify FIFO reaches full state | full=1, count=DEPTH |
| Overflow test | Verify write when full is ignored | extra write is not stored |
| Drain test | Verify FIFO drains in correct order | read order matches write order |
| Underflow test | Verify read when empty is ignored | count stays 0, empty=1 |
| Simultaneous read/write | Verify read and write in same cycle | count remains stable when both accepted |
| Wraparound test | Verify pointers wrap correctly | FIFO preserves order across pointer wrap |

## Future Tests

- randomized traffic
- scoreboard/reference queue
- assertions
- functional coverage
