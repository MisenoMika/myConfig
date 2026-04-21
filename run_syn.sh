#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 <DESIGN_PATH> [OUTPUT_PATH]"
    echo "DESIGN_PATH: The relative path to the top.v file"
    echo "[OUTPUT_PATH]: Optional output directory (default: current directory)"
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

if [[ -n "${2:-}" ]]; then
    O="$2"
fi

O=$(realpath -m "$O")

if [[ ! -f "$DESIGN_PATH" ]]; then
    echo "Error: DESIGN_PATH '$DESIGN_PATH' does not exist or is not a file"
    exit 1
fi

DESIGN_PATH=$(realpath "$DESIGN_PATH")

DESIGN=$(basename "$DESIGN_PATH" .v)

RTL_DIR=$(dirname "$DESIGN_PATH")

RTL_FILES=$(find "$RTL_DIR" -type f -name "*.v" -not -name "*_tb.v" -not -path "*/*MHz*/*" | sort | tr '\n' ' ')

echo "================ SYN CONFIG ================"
echo "DESIGN      = $DESIGN"
echo "DESIGN_PATH  = $DESIGN_PATH"
echo "RTL_DIR     = $RTL_DIR"
echo "OUTPUT      = $O"
echo "RTL_FILES   = $RTL_FILES"
echo "==========================================="


make -C "$HOME"/yosys-sta syn \
    DESIGN="$DESIGN" \
    O="$O" \
    RTL_FILES="$RTL_FILES" -B