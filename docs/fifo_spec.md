# Parameterized Synchronous FIFO Specification

## Project

Parameterized Synchronous FIFO Design and Verification in SystemVerilog.

## FIFO Type

Synchronous FIFO.

## Clocking

Single clock only.

## Parameters

DATA_WIDTH default: 8 bits  
DEPTH default: 16 entries

## Reset

Reset is active-low and synchronous.

When rst_n is 0 on a rising clock edge:

- write pointer resets to 0
- read pointer resets to 0
- occupancy count resets to 0
- output data resets to 0
- FIFO becomes empty
- FIFO is not full

## Interface

Inputs:

- clk
- rst_n
- wr_en
- rd_en
- din

Outputs:

- dout
- full
- empty

## Write Behavior

A write is accepted when wr_en is 1 and the FIFO is not full.

If write is accepted:

- din is stored into memory at wr_ptr
- wr_ptr increments
- count increases by 1 unless a read is also accepted in the same cycle

## Read Behavior

A read is accepted when rd_en is 1 and the FIFO is not empty.

If read is accepted:

- data at rd_ptr appears on dout
- rd_ptr increments
- count decreases by 1 unless a write is also accepted in the same cycle

## Simultaneous Read and Write

If FIFO is neither full nor empty and both wr_en and rd_en are high:

- one item is written
- one item is read
- count stays the same
- both pointers increment

If FIFO is full and both wr_en and rd_en are high:

- read is accepted
- write is also accepted because the read frees a slot
- count stays full

If FIFO is empty and both wr_en and rd_en are high:

- write is accepted
- read is ignored
- count increases to 1

## Full

full means no free slot is available.

## Empty

empty means no valid data is available to read.

## Overflow Behavior

A write when full is ignored unless a read is also accepted in the same cycle.

## Underflow Behavior

A read when empty is ignored.
