#!/usr/bin/env bash
set -euo pipefail

SEED="${SEED:-12648430}"

mkdir -p sim/waves

iverilog -g2012 -Wall \
    -o sim/sync_fifo_sim \
    rtl/sync_fifo.sv \
    tb/tb_sync_fifo.sv

vvp sim/sync_fifo_sim +SEED="${SEED}"

echo ""
echo "To open waveform:"
echo "gtkwave sim/waves/sync_fifo.vcd"
