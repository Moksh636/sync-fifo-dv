# Project Explanation

## 30-Second Explanation

This project is a parameterized synchronous FIFO designed and verified in SystemVerilog.

The RTL includes FIFO memory, write and read pointers, an occupancy count, full and empty flags, and support for simultaneous read/write behavior.

The verification environment includes directed tests, randomized traffic, a self-checking scoreboard, immediate assertions, functional coverage counters, waveform debugging, and a regression script.

The project demonstrates core ASIC design and design verification skills using an open-source simulation flow.

## 2-Minute Explanation

This project implements a single-clock synchronous FIFO in SystemVerilog.

The FIFO stores data in first-in, first-out order. On a write, input data is stored into the memory array at the write pointer. On a read, data is returned from the read pointer. The design uses an occupancy count to determine when the FIFO is full or empty.

The FIFO is parameterized by data width and depth, so the same RTL can be reused for different configurations. The default configuration is 8-bit data width and 16 entries.

The verification environment starts with directed tests for reset, single write/read, fill, drain, overflow, underflow, simultaneous read/write, and pointer wraparound. After that, randomized read/write traffic is applied to stress the FIFO over many cycles.

A scoreboard is used as a reference model. The testbench keeps a SystemVerilog queue of expected values. When the FIFO accepts a write, the testbench pushes the data into the queue. When the FIFO accepts a read, the testbench pops the oldest value and compares it against the DUT output.

Immediate assertions check important design properties such as count bounds, full/empty flag correctness, and invalid read/write acceptance. Functional coverage counters track whether key states and operations were exercised, including empty state, full state, middle occupancy, read-only, write-only, simultaneous read/write, overflow attempt, and underflow attempt.

Waveforms were inspected using GTKWave, and the project includes documentation for the design spec, test plan, scoreboard, assertions, coverage, debug notes, and regression output.

## Resume Bullet

Designed and verified a parameterized synchronous FIFO in SystemVerilog using directed and randomized tests, a self-checking scoreboard, immediate assertions, functional coverage counters, waveform debugging, and regression scripting.

## Skills Demonstrated

- RTL design
- SystemVerilog testbench development
- FIFO control logic
- Pointer and count-based design
- Directed verification
- Randomized verification
- Scoreboard/reference model checking
- Assertion-based checking
- Functional coverage planning
- Waveform debugging
- Regression scripting
- Git/GitHub project documentation
