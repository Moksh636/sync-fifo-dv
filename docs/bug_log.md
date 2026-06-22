# Bug Log

## Bug 1: Assertion Fired Before Reset

### Symptom

Simulation failed immediately with:

ASSERTION FAIL: count exceeded DEPTH. count=x DEPTH=4

### Root Cause

The testbench initialized rst_n high at time 0.

Because the first clock edge occurred before the reset task drove rst_n low, the assertion block sampled the DUT while internal state was still unknown X.

The count signal was X, so the assertion count <= DEPTH failed.

### Fix

Initialize rst_n to 0 at the start of simulation so the DUT is already in reset before the first clock edge.

### Status

Fixed.
