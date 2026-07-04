#! /usr/bin/env bash
set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

input_file="$1"
output_file="${input_file%.*}.bin"

tail -n +2 "$input_file" | sed -e 's/.*: //' -e 's/ /\n/g' | sed -e 's/\(..\)\(..\)\(..\)\(..\)/\4 \3 \2 \1/' | xxd -r -p > "$output_file"