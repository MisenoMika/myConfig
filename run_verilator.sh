#!/usr/bin/env bash

set -euo pipefail

TOPNAME=${1-"top"}
WAVEFORM=${2-"--trace-fst"}
if [[ "${1:-}" == "clean" ]]; then
	rm -rf --verbose obj_dir
	exit 0
fi

if [[ "${1:-}" == "help" ]]; then
	echo "Usage: $0 [clean|help|<top_module_name>] [fst|vcd]" >&2
	exit 0
fi

if [[ "${2:-}" == "fst" ]]; then
	WAVEFORM="--trace-fst"
elif [[ "${2:-}" == "vcd" ]]; then
	WAVEFORM="--trace-vcd"
else
	exit 0
fi


PROJECT_DIR="$(pwd)"
CPP_FILE="csrc/sim.cpp"

if [[ ! -f "$CPP_FILE" ]]; then
	echo "missing: $CPP_FILE" >&2
	exit 1
fi

if [[ ! -d vsrc ]]; then
	echo "missing directory: vsrc" >&2
	exit 1
fi

mapfile -t VERILOG_FILES < <(find "$PROJECT_DIR/vsrc" -maxdepth 1 -type f -name '*.v' ! -name '*_tb.v' | sort)

if [[ ${#VERILOG_FILES[@]} -eq 0 ]]; then
	echo "no Verilog files found in vsrc" >&2
	exit 1
fi

verilator --cc "${VERILOG_FILES[@]}" \
    --exe "$CPP_FILE" --build \
	-Mdir obj_dir \
	--top-module "$TOPNAME" \
    "$WAVEFORM" --trace-params --trace-structs --trace-depth 100
cd "$PROJECT_DIR/obj_dir"
./V"$TOPNAME"

