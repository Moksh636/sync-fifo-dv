# Functional Coverage Notes

## Purpose

Functional coverage tracks which important design scenarios were exercised during simulation.

The goal is not only to pass tests, but also to prove that important FIFO states and operations were reached.

## Coverage Points

The testbench tracks the following coverage points:

- reset seen
- empty state seen
- full state seen
- middle occupancy state seen
- write-only operation seen
- read-only operation seen
- simultaneous read/write seen
- overflow attempt seen
- underflow attempt seen

## Current Implementation

Coverage is implemented using counters inside the testbench.

At the end of simulation, the testbench prints a coverage summary and fails if any required coverage point was not hit.

## Future Improvement

A future version can use SystemVerilog covergroups with a simulator that fully supports functional coverage.
