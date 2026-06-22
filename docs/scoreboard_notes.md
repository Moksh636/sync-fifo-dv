# Scoreboard Notes

## Purpose

The scoreboard is a reference model used by the testbench to check the FIFO automatically.

Instead of manually checking every read value, the testbench keeps an expected queue.

## Reference Model

When a write is accepted by the FIFO:

- push the written data into the back of the expected queue

When a read is accepted by the FIFO:

- pop the oldest value from the front of the expected queue
- compare it against dout

## Why This Matters

This turns the testbench into a self-checking verification environment.

The testbench no longer only applies stimulus. It also predicts correct behavior and catches mismatches.

## Scoreboard Checks

The scoreboard checks:

- read data matches expected FIFO order
- DUT count matches expected queue size
- empty flag matches expected queue empty state
- full flag matches expected queue full state
