# Assertion Notes

## Purpose

Assertions check design rules that should always be true during simulation.

They help catch bugs immediately instead of only finding mismatches at the end of a test.

## FIFO Assertions

The testbench checks the following properties:

1. Count should never be greater than DEPTH.
2. Empty should match count == 0.
3. Full should match count == DEPTH.
4. Full and empty should not both be true for this FIFO.
5. A write should not be accepted when full unless a read is also accepted.
6. A read should not be accepted when empty.

## Current Implementation

Assertions are implemented as immediate assertions inside the testbench.

This is simple and works well for the first open-source simulator flow.

A future version can move these into a separate assertion file or use bind-based SVA.
