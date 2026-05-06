#!/usr/bin/env bash
set -e
read -r -p "Enter name of project: " project_name

if [ ! -d "$project_name" ]; then
    mkdir -p "$project_name"/{csrc,vsrc,constr}
    touch "$project_name/vsrc/top.v"
    touch "$project_name/csrc/main.cpp"
    touch "$project_name/constr/top.nxdc"
    cp "$NVBOARD_HOME/example/Makefile" "$project_name/Makefile"
    cp "$NVBOARD_HOME/digit_lab/Reg.v" "$project_name/vsrc/Reg.v"
    cp "$NVBOARD_HOME/digit_lab/MuxKey.v" "$project_name/vsrc/MuxKey.v"
    cp "$NVBOARD_HOME/digit_lab/MuxKeyWithDefault.v" "$project_name/vsrc/MuxKeyWithDefault.v"
    cp "$NVBOARD_HOME/digit_lab/MuxKeyInternal.v" "$project_name/vsrc/MuxKeyInternal.v"
    cp "$NVBOARD_HOME/digit_lab/seg_driver.v" "$project_name/vsrc/seg_driver.v"
    cp "$NVBOARD_HOME/digit_lab/seg_digit.v" "$project_name/vsrc/seg_digit.v"
    #mkdir -p "$project_name/vsrc/inner_module"
    #find "$project_name/vsrc" -maxdepth 1 -type f -name "*.v" ! -name "top.v" -exec mv {} "$project_name/vsrc/inner_module/" \;
    echo "Project '$project_name' successfully created"
else
    echo "Project '$project_name' existed"
fi