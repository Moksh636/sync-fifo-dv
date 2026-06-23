# FIFO Verification Test Plan

## Project

Parameterized Synchronous FIFO Design and Verification in SystemVerilog.

## Current Status

Implemented and passing:

- directed tests
- randomized tests
- self-checking scoreboard
- immediate assertions
- functional coverage counters
- regression script
- Verilator lint target
- GitHub Actions CI

## Testbench

Top-level testbench:

- tb/tb_sync_fifo.sv

Simulation script:

- scripts/run_tests.sh

Makefile targets:

- make test
- make test SEED=42
- make lint
- make wave
- make clean

## Directed Tests

| Test | Purpose | Status |
|---|---|---|
| Reset test | Verify FIFO initializes correctly | Implemented |
| Single write/read | Verify one value can be written and read back | Implemented |
| Fill test | Verify FIFO reaches full state | Implemented |
| Overflow attempt | Verify write when full is ignored | Implemented |
| Drain/order test | Verify FIFO preserves first-in, first-out order | Implemented |
| Underflow attempt | Verify read when empty is ignored | Implemented |
| Simultaneous read/write in middle state | Verify count stability and ordering | Implemented |
| Simultaneous read/write when empty | Verify read is ignored and write is accepted | Implemented |
| Simultaneous read/write when full | Verify read and write are both accepted and count stays full | Implemented |
| Pointer wraparound | Verify pointer wrapping preserves data order | Implemented |
| Randomized traffic | Stress FIFO with random read/write operations | Implemented |

## Scoreboard

The scoreboard uses a SystemVerilog queue as the reference model.

Accepted writes are pushed into the queue.

Accepted reads pop the oldest value from the queue and compare it against dout.

The scoreboard also checks count, full, and empty behavior.

## Assertions

Immediate assertions check:

- count never exceeds DEPTH
- empty matches count == 0
- full matches count == DEPTH
- full and empty are not both high
- write is not accepted while full unless a read also happens
- read is not accepted while empty

## Functional Coverage

Coverage counters track:

- reset seen
- empty state
- full state
- middle occupancy state
- write-only operation
- read-only operation
- simultaneous read/write
- overflow attempt
- underflow attempt

The regression fails if any required coverage point is missed.

## Random Seed Control

The randomized test supports repeatable seeds.

Default:

- SEED=12648430

Example:

- make test SEED=42
