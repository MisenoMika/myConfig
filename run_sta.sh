#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 <DESIGN_PATH> [OUTPUT_PATH] [CLK_FREQ] [CLK_PORT_NAME]"
    echo "DESIGN_PATH: The relative path to the top.v file"
    echo "[OUTPUT_PATH]: Optional output directory (default: current directory)"
    echo "[CLK_FREQ]: Optional clock frequency(MHz) (default: 500MHz)"
    echo "[CLK_PORT_NAME]: Optional clock port name (default: clk)"
}


O=${O:-"$PWD"}
DESIGN_PATH=""


if [[ $# -lt 1 ]]; then
    echo "DESIGN_PATH is required"
    usage
    exit 1
fi

if [[ $# -gt 2 ]]; then
    echo "Too many arguments"
    usage
    exit 1
fi

DESIGN_PATH="$1"
CLK_FREQ="$2"
CLK_PORT_NAME="$3"
if [[ -n "${4:-}" ]]; then
    O="$4"
fi

O=$(realpath -m "$O")

if [[ ! -f "$DESIGN_PATH" ]]; then
    echo "Error: DESIGN_PATH '$DESIGN_PATH' does not exist or is not a file"
    exit 1
fi

DESIGN_PATH=$(realpath "$DESIGN_PATH")

DESIGN=$(basename "$DESIGN_PATH" .v)

RTL_DIR=$(dirname "$DESIGN_PATH")

RTL_FILES=$(find "$RTL_DIR" -type f -name "*.v" -not -name "*_tb.v" | sort | tr '\n' ' ')

echo "================ SYN CONFIG ================"
echo "DESIGN      = $DESIGN"
echo "DESIGN_PATH  = $DESIGN_PATH"
echo "RTL_DIR     = $RTL_DIR"
echo "OUTPUT      = $O"
echo "RTL_FILES   = $RTL_FILES"
echo "CLK_FREQ    = ${CLK_FREQ:-N/A}"
echo "CLK_PORT_NAME = ${CLK_PORT_NAME:-500MHz}"
echo "CLK_PORT_NAME = ${CLK_PORT_NAME:-clk}"
echo "==========================================="


make -C "$HOME"/yosys-sta sta \
    DESIGN="$DESIGN" \
    O="$O" \
    RTL_FILES="$RTL_FILES" \
    CLK_FREQ="${CLK_FREQ:-500MHz}" \
    CLK_PORT_NAME="${CLK_PORT_NAME:-clk}" 