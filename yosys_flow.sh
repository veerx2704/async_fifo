#!/usr/bin/env bash

yosys -s synth.ys -l synth_logs/synthesis_report.log
sed -i -E 's/\b(wire|reg|input|output|inout)\s+signed\b/\1/g' results/fifo_netlist.v
