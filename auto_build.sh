#!/usr/bin/env bash
set -e
read -r -p "Enter name of project: " project_name

if [ ! -d "$project_name" ]; then
    mkdir -p "$project_name"/{csrc,vsrc,constr}
    touch "$project_name/vsrc/top.v"
    touch "$project_name/csrc/main.cpp"
    touch "$project_name/constr/top.nxdc"
    cp "$NVBOARD_HOME/digit_lab/template/Makefile" "$project_name/Makefile"
    echo "Project '$project_name' successfully created"
else
    echo "Project '$project_name' existed"
fi