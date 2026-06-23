# Parameterized Synchronous FIFO Design and Verification

## Overview

This project implements and verifies a parameterized single-clock synchronous FIFO in SystemVerilog.

The goal of this project is to demonstrate core ASIC design and design verification skills using a clean RTL design, directed testing, randomized testing, a self-checking scoreboard, assertions, functional coverage counters, waveform debugging, and regression scripting.

## Project Status

Current status: v1.0 complete. Milestone 9 passing.

Completed features:

- FIFO RTL design
- Directed tests
- Randomized testing
- Self-checking scoreboard
- Immediate assertions
- Functional coverage counters
- Waveform generation
- Regression script
- Debug documentation
- GitHub-based project tracking

## Design Summary

The FIFO is a hardware buffer that stores data in first-in, first-out order.

Data written into the FIFO is stored at the write pointer. Data read from the FIFO comes from the read pointer. The design uses an occupancy count to track how many valid entries are currently stored.

## RTL Features

- Single-clock synchronous FIFO
- Parameterized data width
- Parameterized depth
- Active-low synchronous reset
- Internal memory array
- Write pointer
- Read pointer
- Occupancy count
- Full flag
- Empty flag
- Simultaneous read/write support
- Write ignored when full unless a read also occurs
- Read ignored when empty

## Interface

Module: rtl/sync_fifo.sv

Parameters:

- DATA_WIDTH: default 8, width of each FIFO entry
- DEPTH: default 16, number of FIFO entries

Ports:

- clk: FIFO clock
- rst_n: active-low synchronous reset
- wr_en: write enable
- rd_en: read enable
- din: input data
- dout: output data
- full: FIFO full flag
- empty: FIFO empty flag

## Verification Summary

The FIFO is verified using a self-checking SystemVerilog testbench.

Testbench:

- tb/tb_sync_fifo.sv

The testbench includes:

- directed tests
- randomized test sequence
- scoreboard/reference model
- immediate assertions
- functional coverage counters
- waveform dump generation

## Directed Tests

The testbench verifies the following cases:

- Reset behavior
- Single write and read
- Fill to full
- Overflow attempt
- Drain and order preservation
- Underflow attempt
- Simultaneous read/write
- Pointer wraparound
- Randomized read/write traffic

## Scoreboard

The testbench uses a SystemVerilog queue as a reference model.

When the DUT accepts a write, the testbench pushes the written data into the expected queue.

When the DUT accepts a read, the testbench pops the oldest value from the expected queue and compares it against dout.

The scoreboard also checks that the DUT count, full flag, and empty flag match the expected queue state.

## Assertions

Immediate assertions check key FIFO properties during simulation:

- count must not exceed DEPTH
- empty must match count == 0
- full must match count == DEPTH
- full and empty must not both be high
- write must not be accepted when full unless a read also occurs
- read must not be accepted when empty

## Functional Coverage

Functional coverage counters track whether important scenarios were exercised.

Coverage points:

- reset seen
- empty state seen
- full state seen
- middle occupancy state seen
- write-only operation seen
- read-only operation seen
- simultaneous read/write seen
- overflow attempt seen
- underflow attempt seen

Latest regression reached all required coverage goals.

## Latest Regression Result

The latest regression passed all directed tests, randomized testing, scoreboard checks, assertions, and coverage goals.

Final result:

Milestone 9 PASSED: reproducible FIFO DV regression complete

Coverage counter values can change as tests are improved.

See docs/regression_latest.txt for the latest regression output and coverage counter values.

## Waveform Debugging

Waveforms are generated in VCD format.

Waveform output:

- sim/waves/sync_fifo.vcd

The waveform was inspected using GTKWave to confirm reset behavior, write behavior, read behavior, pointer movement, count updates, and full/empty flag behavior.

Waveform notes are stored under docs.

## Repository Structure

- rtl/sync_fifo.sv: FIFO RTL design
- tb/tb_sync_fifo.sv: SystemVerilog testbench
- scripts/run_tests.sh: Regression script
- docs/fifo_spec.md: FIFO design specification
- docs/test_plan.md: Verification test plan
- docs/bug_log.md: Debug notes and bug history
- docs/waveform_notes.md: Waveform observations
- docs/scoreboard_notes.md: Scoreboard explanation
- docs/random_test_notes.md: Randomized test explanation
- docs/assertion_notes.md: Assertion notes
- docs/coverage_notes.md: Coverage notes
- docs/regression_latest.txt: Latest regression output

## Tools Used

- WSL Ubuntu
- SystemVerilog
- Icarus Verilog
- GTKWave
- Verilator
- Git
- GitHub

## How to Run

From the project root, run:

    ./scripts/run_tests.sh

To open the generated waveform, run:

    gtkwave sim/waves/sync_fifo.vcd

## Debug Story

During assertion integration, the simulation initially failed because assertions sampled the DUT before reset had initialized internal state.

The failure showed count as X at the first clock edge.

Root cause:

- rst_n was initialized high at time 0
- the first clock edge occurred before the reset task drove rst_n low
- assertions sampled uninitialized DUT state

Fix:

- initialize rst_n low at time 0
- ensure the DUT is in reset before the first clock edge

This issue is documented in docs/bug_log.md.

## What I Learned

This project helped build practical understanding of:

- synchronous FIFO design
- pointer-based buffer control
- occupancy count logic
- full and empty flag generation
- simultaneous read/write behavior
- directed verification
- randomized testing
- scoreboard-based checking
- assertion-based checking
- coverage-driven thinking
- waveform debugging
- Git/GitHub project documentation

## Resume Bullet

Designed and verified a parameterized synchronous FIFO in SystemVerilog using directed and randomized tests, a self-checking scoreboard, immediate assertions, functional coverage counters, waveform debugging, and regression scripting.
