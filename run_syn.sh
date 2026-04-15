#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 <DESIGN> <RTL_FILES> [OUTPUT_PATH]"

}

# =========================
# 默认参数
# =========================
O=${O:-"$PWD"}
DESIGN=""
RTL_FILES=""

# =========================
# 参数解析
# =========================
if [[ $# -lt 2 ]]; then
    echo "DESIGN and RTL_FILES are required"
    usage
    exit 1
fi

if [[ $# -gt 3 ]]; then
    echo "Too many arguments"
    usage
    exit 1
fi

DESIGN="$1"
RTL_FILES="$2"
RTL_FILES=$(realpath "$RTL_FILES")
if [[ -n "${3:-}" ]]; then
    O="$3"
fi

# =========================
# 检查输入
# =========================
if [[ -z "$DESIGN" || -z "$RTL_FILES" ]]; then
    echo "DESIGN and RTL_FILES could not be empty"
    usage
    exit 1
fi

# =========================
# 打印配置
# =========================
echo "================ SYN CONFIG ================"
echo "DESIGN    = $DESIGN"
echo "OUTPUT    = $O"
echo "RTL_FILES = $RTL_FILES"
echo "==========================================="

# =========================
# 运行 synthesis
# =========================
make -C "$HOME"/yosys-sta syn \
    DESIGN="$DESIGN" \
    O="$O" \
    RTL_FILES="$RTL_FILES"