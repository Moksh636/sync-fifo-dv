#!/usr/bin/env bash
set -euo pipefail

mkdir -p sim/waves

iverilog -g2012 -Wall \
    -o sim/sync_fifo_sim \
    rtl/sync_fifo.sv \
    tb/tb_sync_fifo.sv

vvp sim/sync_fifo_sim

echo ""
echo "To open waveform:"
echo "gtkwave sim/waves/sync_fifo.vcd"
