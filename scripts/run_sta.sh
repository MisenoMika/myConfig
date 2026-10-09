#!/usr/bin/env bash

set -euo pipefail

PROJ_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

DEFAULT_FREQ=500
DEFAULT_CLK=clk

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] <DESIGN_PATH>
       $0 [OPTIONS] --top <NAME> --rtl <DIR>

Run synthesis and STA for a Verilog design.

Besides the whole top design, you can analyze a single module under rtl/ or
any existing module that is itself built from several submodules (e.g. 'ifu',
which contains 'icache'): point --rtl at the root directory that holds all the
sources and use --top to select which module becomes the synthesis top.

Arguments:
  DESIGN_PATH                Top file, a directory containing it, or the RTL
                             root directory. Optional when --top and --rtl
                             are both given.

Options:
  -f, --freq <MHZ>           Clock frequency in MHz, "500MHz" also works
                             (default: $DEFAULT_FREQ)
  -c, --clock <NAME>         Clock port name (default: $DEFAULT_CLK)
  -t, --top <NAME>           Module to use as the synthesis top (default: the
                             stem of DESIGN_PATH)
  -r, --rtl <DIR>            Root directory recursively scanned for RTL
                             sources (default: the directory of DESIGN_PATH)
  -o, --output <DIR>         Output directory (default: current directory)
  -k, --keep                 Preserve every cell/wire (YOSYS_KEEP). Needed only
                             when the top has no primary outputs, otherwise the
                             netlist is empty. Off by default because it
                             prevents memory optimization and can make yosys
                             crash (fsm_extract) on memory-heavy modules.
  -p, --power                Also run iEDA report_power (off by default; power
                             analysis can be OOM-killed on large netlists).
  -h, --help                 Show this help and exit

Environment variables (overridden by options): CLK_FREQ_MHZ, CLK_PORT_NAME, O,
YOSYS_KEEP, PWR_REPORT

Designs using SystemVerilog (.sv) are converted to Verilog via sv2v
(required: https://github.com/zachjs/sv2v) before synthesis, because yosys
cannot parse 'parameter type' or DPI-C declarations.

NOTE: a module that exposes a SystemVerilog interface as a port (e.g.
'decoupled_if', 'axi_if') cannot be used directly as --top, because sv2v
refuses to convert an interface port on the top module. Wrap such a module in
a plain-port module and analyze the wrapper instead.

Examples:
  $0 path/to/top.v
  $0 --freq 250 --clock sys_clk --output build/ rtl/
  $0 rtl/                      # auto-detect the top module file

  # STA for one module under vsrc/ (scan all of vsrc/, top = ifu)
  $0 -f 300 -t ifu -r vsrc

  # STA for a composite module built from several submodules (bpu pulls in
  # bimodal/ubtb/gen_pc automatically)
  $0 -f 500 -t bpu -r vsrc
EOF
}

CLK_FREQ_MHZ="${CLK_FREQ_MHZ:-}"
CLK_PORT_NAME="${CLK_PORT_NAME:-}"
O="${O:-$PWD}"
DESIGN_PATH=""
TOP_NAME="${TOP_NAME:-}"
RTL_ROOT="${RTL_ROOT:-}"
YOSYS_KEEP="${YOSYS_KEEP:-0}"
PWR_REPORT="${PWR_REPORT:-0}"

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
    -t | --top)
        if [[ $# -lt 2 ]]; then
            echo "Error: option '$1' requires an argument" >&2
            exit 1
        fi
        TOP_NAME="$2"
        shift 2
        ;;
    --top=*)
        TOP_NAME="${1#*=}"
        shift
        ;;
    -r | --rtl)
        if [[ $# -lt 2 ]]; then
            echo "Error: option '$1' requires an argument" >&2
            exit 1
        fi
        RTL_ROOT="$2"
        shift 2
        ;;
    --rtl=*)
        RTL_ROOT="${1#*=}"
        shift
        ;;
    -k | --keep)
        YOSYS_KEEP=1
        shift
        ;;
    -p | --power)
        PWR_REPORT=1
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

if [[ -z "$DESIGN_PATH" && -z "$RTL_ROOT" ]]; then
    echo "Error: a DESIGN_PATH or --rtl <DIR> is required" >&2
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
    -not -name 'tb_*'
    -not -name '*netlist.v'
    -not -path '*/obj_dir/*'
    -not -path '*/test/*'
    -not -path '*/*MHz*/*'
    -not -path '*/build/*'
)

# resolve the RTL root: --rtl wins, otherwise fall back to DESIGN_PATH
RTL_DIR=""
if [[ -n "$RTL_ROOT" ]]; then
    if [[ ! -d "$RTL_ROOT" ]]; then
        echo "Error: --rtl '$RTL_ROOT' does not exist or is not a directory" >&2
        exit 1
    fi
    RTL_DIR=$(realpath "$RTL_ROOT")
fi

# resolve DESIGN_PATH: accept a file (its directory becomes the RTL root), a
# directory (auto-detect the top file unless --top is given), or nothing when
# --top and --rtl are supplied.
TOP_V=""
if [[ -n "$DESIGN_PATH" ]]; then
    if [[ -d "$DESIGN_PATH" ]]; then
        [[ -z "$RTL_DIR" ]] && RTL_DIR=$(realpath "$DESIGN_PATH")
        if [[ -z "$TOP_NAME" ]]; then
            mapfile -t CANDIDATES < <(find "$DESIGN_PATH" -type f \( "${RTL_NAME[@]}" \) "${RTL_EXCLUDE[@]}" | sort)
            if [[ -f "$DESIGN_PATH/top.v" ]]; then
                TOP_V=$(realpath "$DESIGN_PATH/top.v")
            elif [[ -f "$DESIGN_PATH/top.sv" ]]; then
                TOP_V=$(realpath "$DESIGN_PATH/top.sv")
            elif [[ ${#CANDIDATES[@]} -eq 1 ]]; then
                TOP_V=$(realpath "${CANDIDATES[0]}")
            elif [[ ${#CANDIDATES[@]} -eq 0 ]]; then
                echo "Error: no Verilog files found in '$DESIGN_PATH'" >&2
                exit 1
            else
                echo "Error: multiple Verilog files found in '$DESIGN_PATH'; use --top <NAME> or specify the top file explicitly:" >&2
                printf '  %s\n' "${CANDIDATES[@]}" >&2
                exit 1
            fi
            echo "Auto-detected top module file: $TOP_V"
        fi
    elif [[ -f "$DESIGN_PATH" ]]; then
        TOP_V=$(realpath "$DESIGN_PATH")
        [[ -z "$RTL_DIR" ]] && RTL_DIR=$(dirname "$TOP_V")
    else
        echo "Error: DESIGN_PATH '$DESIGN_PATH' does not exist or is not a file/directory" >&2
        exit 1
    fi
fi

if [[ -z "$RTL_DIR" ]]; then
    echo "Error: could not determine the RTL source directory; specify --rtl <DIR>" >&2
    exit 1
fi

# determine the top module name
if [[ -n "$TOP_NAME" ]]; then
    DESIGN="$TOP_NAME"
elif [[ -n "$TOP_V" ]]; then
    DESIGN=$(basename "$TOP_V")
    DESIGN="${DESIGN%.sv}"
    DESIGN="${DESIGN%.v}"
else
    echo "Error: could not determine the top module; specify --top <NAME>" >&2
    exit 1
fi

O=$(realpath -m "$O")
mkdir -p "$O"

# locate the file that defines the top module (diagnostic only)
if [[ -z "$TOP_V" ]]; then
    TOP_V=$(grep -rlE "^[[:space:]]*module[[:space:]]+$DESIGN\b" \
        --include='*.v' --include='*.sv' "$RTL_DIR" 2>/dev/null | sort | head -n1 || true)
fi

mapfile -t RTL_FILE_ARRAY < <(find "$RTL_DIR" -type f \( "${RTL_NAME[@]}" \) "${RTL_EXCLUDE[@]}" | sort)

# if the top file was given explicitly and lives outside the scanned RTL root
# (e.g. a hand-written wrapper), compile it too
if [[ -n "$TOP_V" && -f "$TOP_V" ]]; then
    _have_top=0
    for f in "${RTL_FILE_ARRAY[@]}"; do
        [[ "$f" == "$TOP_V" ]] && _have_top=1 && break
    done
    ((_have_top)) || RTL_FILE_ARRAY+=("$TOP_V")
fi
mapfile -t RTL_FILE_ARRAY < <(printf '%s\n' "${RTL_FILE_ARRAY[@]}" | sort)
RTL_FILES="${RTL_FILE_ARRAY[*]}"

# include directory exposed to sv2v and yosys (empty -> yosys uses its default)
RTL_INC=""
[[ -d "$RTL_DIR/include" ]] && RTL_INC="$RTL_DIR/include"

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

    # packages first: they hold `define macros that other files may rely on
    # (sv2v processes files in order, so e.g. npc_pkg.sv's TOURNAMENT_ON must be
    # seen before tournament.sv).
    mapfile -t SV2V_FILES < <(
        find "$SV2V_SRC" -type f -name '*_pkg.sv' | sort
        find "$SV2V_SRC" -type f \( -name '*.v' -o -name '*.sv' \) ! -name '*_pkg.sv' | sort
    )
    N_SRC=${#SV2V_FILES[@]}
    sv2v "${SV2V_ARGS[@]}" "${SV2V_FILES[@]}"
    echo "sv2v: converted $N_SRC sources to ${#RTL_FILE_ARRAY[@]} Verilog modules"

    mapfile -t RTL_FILE_ARRAY < <(find "$SV2V_OUT" -type f -name '*.v' | sort)
    RTL_FILES="${RTL_FILE_ARRAY[*]}"
fi

echo "=================== STA CONFIG ==================="
echo "DESIGN          = $DESIGN"
echo "TOP_V           = ${TOP_V:-<auto: $DESIGN>}"
echo "RTL_DIR         = $RTL_DIR"
echo "RTL_FILES       = $RTL_FILES"
echo "CLK_FREQ_MHZ    = $CLK_FREQ_MHZ"
echo "CLK_PORT_NAME   = $CLK_PORT_NAME"
echo "YOSYS_KEEP      = $YOSYS_KEEP"
echo "OUTPUT          = $O"
echo "=================================================="

make -C "$PROJ_DIR" sta \
    DESIGN="$DESIGN" \
    O="$O" \
    SDC_FILE="$PROJ_DIR/scripts/default.sdc" \
    CLK_FREQ_MHZ="$CLK_FREQ_MHZ" \
    CLK_PORT_NAME="$CLK_PORT_NAME" \
    RTL_FILES="$RTL_FILES" \
    RTL_INC="$RTL_INC" \
    YOSYS_KEEP="$YOSYS_KEEP" \
    PWR_REPORT="$PWR_REPORT" \
    -B

echo
echo "Timing report: $O/$DESIGN-${CLK_FREQ_MHZ}MHz/$DESIGN.rpt"
