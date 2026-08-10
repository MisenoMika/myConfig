#!/usr/bin/env bash

set -euo pipefail

PROJ_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

DEFAULT_FREQ=500
DEFAULT_CLK=clk

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] <DESIGN_PATH>

Run synthesis and STA for a Verilog design.

Arguments:
  DESIGN_PATH                Path to the top.v file, or a directory containing it

Options:
  -f, --freq <MHZ>           Clock frequency in MHz, "500MHz" also works
                             (default: $DEFAULT_FREQ)
  -c, --clock <NAME>         Clock port name (default: $DEFAULT_CLK)
  -o, --output <DIR>         Output directory (default: current directory)
  -h, --help                 Show this help and exit

Environment variables (overridden by options): CLK_FREQ_MHZ, CLK_PORT_NAME, O

Designs using SystemVerilog (.sv) are converted to Verilog via sv2v
(required: https://github.com/zachjs/sv2v) before synthesis, because yosys
cannot parse 'parameter type' or DPI-C declarations.

Examples:
  $0 path/to/top.v
  $0 --freq 250 --clock sys_clk --output build/ rtl/
  $0 rtl/                      # auto-detect the top module file
EOF
}

CLK_FREQ_MHZ="${CLK_FREQ_MHZ:-}"
CLK_PORT_NAME="${CLK_PORT_NAME:-}"
O="${O:-$PWD}"
DESIGN_PATH=""

while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -f | --freq)
        if [[ $# -lt 2 ]]; then
            echo "Error: option '$1' requires an argument" >&2
            exit 1
        fi
        CLK_FREQ_MHZ="$2"
        shift 2
        ;;
    --freq=*)
        CLK_FREQ_MHZ="${1#*=}"
        shift
        ;;
    -c | --clock)
        if [[ $# -lt 2 ]]; then
            echo "Error: option '$1' requires an argument" >&2
            exit 1
        fi
        CLK_PORT_NAME="$2"
        shift 2
        ;;
    --clock=*)
        CLK_PORT_NAME="${1#*=}"
        shift
        ;;
    -o | --output)
        if [[ $# -lt 2 ]]; then
            echo "Error: option '$1' requires an argument" >&2
            exit 1
        fi
        O="$2"
        shift 2
        ;;
    --output=*)
        O="${1#*=}"
        shift
        ;;
    -*)
        echo "Error: unknown option: $1" >&2
        usage >&2
        exit 1
        ;;
    *)
        if [[ -n "$DESIGN_PATH" ]]; then
            echo "Error: unexpected extra argument: $1" >&2
            usage >&2
            exit 1
        fi
        DESIGN_PATH="$1"
        shift
        ;;
    esac
done

if [[ -z "$DESIGN_PATH" ]]; then
    echo "Error: DESIGN_PATH is required" >&2
    usage >&2
    exit 1
fi

# normalize frequency: accept "500" or "500MHz"
if [[ -z "$CLK_FREQ_MHZ" ]]; then
    CLK_FREQ_MHZ="$DEFAULT_FREQ"
else
    CLK_FREQ_MHZ="${CLK_FREQ_MHZ%MHz}"
    CLK_FREQ_MHZ="${CLK_FREQ_MHZ%MHZ}"
    CLK_FREQ_MHZ="${CLK_FREQ_MHZ%mhz}"
    if [[ ! "$CLK_FREQ_MHZ" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: invalid clock frequency: '$CLK_FREQ_MHZ' (expected e.g. 500 or 500MHz)" >&2
        exit 1
    fi
fi

if [[ -z "$CLK_PORT_NAME" ]]; then
    CLK_PORT_NAME="$DEFAULT_CLK"
fi

# RTL source file names and files to exclude
RTL_NAME=(-name '*.v' -o -name '*.sv')
RTL_EXCLUDE=(
    -not -name '*_tb.v'
    -not -name '*netlist.v'
    -not -path '*/obj_dir/*'
    -not -path '*/*MHz*/*'
    -not -path '*/build/*'
)

# resolve DESIGN_PATH: accept a directory and auto-detect the top module file
if [[ -d "$DESIGN_PATH" ]]; then
    mapfile -t CANDIDATES < <(find "$DESIGN_PATH" -type f \( "${RTL_NAME[@]}" \) "${RTL_EXCLUDE[@]}" | sort)
    if [[ -f "$DESIGN_PATH/top.v" || -f "$DESIGN_PATH/top.sv" ]]; then
        DESIGN_PATH="$DESIGN_PATH/top.v"
    elif [[ ${#CANDIDATES[@]} -eq 1 ]]; then
        DESIGN_PATH="${CANDIDATES[0]}"
    elif [[ ${#CANDIDATES[@]} -eq 0 ]]; then
        echo "Error: no Verilog files found in '$DESIGN_PATH'" >&2
        exit 1
    else
        echo "Error: multiple Verilog files found in '$DESIGN_PATH', specify the top file explicitly:" >&2
        printf '  %s\n' "${CANDIDATES[@]}" >&2
        exit 1
    fi
    echo "Auto-detected top module file: $DESIGN_PATH"
fi

if [[ ! -f "$DESIGN_PATH" ]]; then
    echo "Error: DESIGN_PATH '$DESIGN_PATH' does not exist or is not a file" >&2
    exit 1
fi

DESIGN_PATH=$(realpath "$DESIGN_PATH")
O=$(realpath -m "$O")
mkdir -p "$O"

DESIGN=$(basename "$DESIGN_PATH")
DESIGN="${DESIGN%.sv}"
DESIGN="${DESIGN%.v}"
RTL_DIR=$(dirname "$DESIGN_PATH")

mapfile -t RTL_FILE_ARRAY < <(find "$RTL_DIR" -type f \( "${RTL_NAME[@]}" \) "${RTL_EXCLUDE[@]}" | sort)
RTL_FILES="${RTL_FILE_ARRAY[*]}"

RTL_INC="$RTL_DIR/include"

# --- convert SystemVerilog to Verilog via sv2v when the design uses .sv ---
HAVE_SV=0
for f in "${RTL_FILE_ARRAY[@]}"; do
    [[ "$f" == *.sv ]] && HAVE_SV=1 && break
done

if ((HAVE_SV)); then
    if ! command -v sv2v >/dev/null 2>&1; then
        echo "Error: the design uses SystemVerilog (.sv), but 'sv2v' is not installed." >&2
        echo "Yosys cannot parse 'parameter type' (used by npc's Reg/MuxKey modules)." >&2
        echo "Install sv2v, e.g.:" >&2
        echo "  curl -sL -o /tmp/sv2v.zip https://github.com/zachjs/sv2v/releases/download/v0.0.13/sv2v-Linux.zip" >&2
        echo "  unzip -o /tmp/sv2v.zip -d ~/.local/bin" >&2
        exit 1
    fi

    SV2V_SRC="$O/.sv2v-src"
    SV2V_OUT="$O/.sv2v-out"
    rm -rf "$SV2V_SRC" "$SV2V_OUT"
    mkdir -p "$SV2V_SRC" "$SV2V_OUT"

    for f in "${RTL_FILE_ARRAY[@]}"; do
        rel="${f#"$RTL_DIR"/}"
        mkdir -p "$SV2V_SRC/$(dirname "$rel")"
        if [[ "$f" == *.sv ]]; then
            # strip simulation-only DPI-C declarations, which yosys cannot parse
            perl -0pe 's/^\s*export\s+"DPI-C"\s+function\s+[\w]+;[\r\n]*//mg; s/import\s+"DPI-C"[^;]*;[\s]*//g' \
                "$f" >"$SV2V_SRC/$rel"
        else
            cp "$f" "$SV2V_SRC/$rel"
        fi
    done

    SV2V_ARGS=(-w "$SV2V_OUT" --top="$DESIGN")
    [[ -d "$RTL_INC" ]] && SV2V_ARGS+=(-I "$RTL_INC")

    mapfile -t SV2V_FILES < <(find "$SV2V_SRC" -type f \( -name '*.v' -o -name '*.sv' \) | sort)
    N_SRC=${#SV2V_FILES[@]}
    sv2v "${SV2V_ARGS[@]}" "${SV2V_FILES[@]}"
    echo "sv2v: converted $N_SRC sources to ${#RTL_FILE_ARRAY[@]} Verilog modules"

    mapfile -t RTL_FILE_ARRAY < <(find "$SV2V_OUT" -type f -name '*.v' | sort)
    RTL_FILES="${RTL_FILE_ARRAY[*]}"
fi

echo "=================== STA CONFIG ==================="
echo "DESIGN          = $DESIGN"
echo "TOP_V           = $DESIGN_PATH"
echo "RTL_DIR         = $RTL_DIR"
echo "RTL_FILES       = $RTL_FILES"
echo "CLK_FREQ_MHZ    = $CLK_FREQ_MHZ"
echo "CLK_PORT_NAME   = $CLK_PORT_NAME"
echo "OUTPUT          = $O"
echo "=================================================="

make -C "$PROJ_DIR" sta \
    DESIGN="$DESIGN" \
    O="$O" \
    SDC_FILE="$PROJ_DIR/scripts/default.sdc" \
    CLK_FREQ_MHZ="$CLK_FREQ_MHZ" \
    CLK_PORT_NAME="$CLK_PORT_NAME" \
    RTL_FILES="$RTL_FILES" \
    YOSYS_KEEP=1 \
    -B

echo
echo "Timing report: $O/$DESIGN-${CLK_FREQ_MHZ}MHz/$DESIGN.rpt"
