# Waveform Notes

## Milestone 1: Reset, Single Write, Single Read

### Test Objective

Verify that the FIFO can:

1. Reset correctly
2. Accept one write
3. Return the same value on read
4. Update empty/full/count behavior correctly

### Expected Behavior

After reset:

- empty = 1
- full = 0
- count = 0
- wr_ptr = 0
- rd_ptr = 0

During write:

- wr_en = 1
- din = A5
- wr_ptr increments
- count increases from 0 to 1
- empty becomes 0

During read:

- rd_en = 1
- dout becomes A5
- rd_ptr increments
- count decreases from 1 to 0
- empty becomes 1

### Result

PASS.

The waveform confirms that the value written into the FIFO, A5, is read back correctly.
