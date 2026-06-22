# Randomized Test Notes

## Purpose

The randomized test applies many cycles of random FIFO traffic.

Each cycle randomly chooses:

- wr_en
- rd_en
- din

The scoreboard checks that the FIFO still preserves correct order.

## What This Tests

Random traffic can exercise cases that directed tests may miss, such as:

- write only
- read only
- simultaneous read/write
- read while empty
- write while full
- transitions between empty, middle, and full states
- pointer movement over time

## Scoreboard Role

The scoreboard remains the golden reference model.

It tracks accepted writes and compares accepted reads against the expected order.
