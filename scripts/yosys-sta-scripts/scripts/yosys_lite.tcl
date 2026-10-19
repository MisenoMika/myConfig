# Lightweight synthesis flow for modules with very large memories (TAGE etc.).
#
# This is a SEPARATE flow.  scripts/yosys.tcl and run_sta.sh are left untouched.
#
# Why this exists
# ---------------
# The normal flow runs `synth -flatten` and then a fairly heavy ABC DELAY/AREA
# script on the whole design.  For a BPU with large predictor tables every
# memory is mapped to flip-flops, so the flattened gate netlist becomes huge and
# ABC can be killed by the OOM killer.
#
# This flow is lighter in three ways:
#   1. It synthesises the hierarchy WITHOUT `-flatten`, so ABC runs per module
#      (peak memory is per-module, not the whole BPU).  The gate-level design is
#      flattened again at the very end, so the written netlist is still flat and
#      readable by iEDA.
#   2. The memory-mux passes onehot/muxpack (plus plain share/opt_demorgan/
#      opt_ffinv) are kept because they shrink the netlist a lot; set
#      LITE_SKIP_OPT=1 to skip them.
#   3. A lightweight but timing-driven ABC script is used instead of the heavy
#      DELAY/AREA strategy scripts:
#          +strash; dretime; map {D}; topo; buffer -N 24; topo
#      Override with LITE_ABC_SCRIPT (use "+strash; map" for area-only).
#
# Usage (same arguments as scripts/yosys.tcl, run through yosys' tcl command):
#   echo tcl scripts/yosys_lite.tcl <top> <pdk> "<verilog files>" <out.netlist.v> \
#       | yosys -g -l <log> -s -
#
# Environment:
#   CLK_FREQ_MHZ       clock frequency for -D / the SDC (default 500)
#   RTL_INC            colon-separated include directories
#   YOSYS_KEEP         preserve all logic (keep attribute)
#   LITE_FLATTEN=1     flatten before ABC as well (old behaviour, more RAM)
#   LITE_SKIP_OPT=1    skip share/onehot/muxpack/opt_demorgan/opt_ffinv
#   LITE_ABC_SCRIPT    override the ABC script
#                      (default: "+strash; dretime; map {D}; topo; buffer -N 24; topo")
#   LITE_WRITE_SIM=0   do not write the .sim netlist
#   LITE_DUMP_PRE_ABC  write the pre-ABC RTLIL to this path and stop (debug)

#===========================================================
#   set parameter
#===========================================================
set DESIGN                  [lindex $argv 0]
set PDK                     [lindex $argv 1]
set VERILOG_FILES           [string map {"\"" ""} [lindex $argv 2]]
set NETLIST_SYN_V           [lindex $argv 3]
set RESULT_DIR              [file dirname $NETLIST_SYN_V]

source "[file dirname [info script]]/common.tcl"

set CLK_FREQ_MHZ            500
if {[info exists env(CLK_FREQ_MHZ)]} {
  set CLK_FREQ_MHZ          $::env(CLK_FREQ_MHZ)
} else {
  puts "Warning: Environment CLK_FREQ_MHZ is not defined. Use $CLK_FREQ_MHZ MHz by default."
}
set CLK_PERIOD_NS           [expr 1000.0 / $CLK_FREQ_MHZ]
set CLK_PERIOD_PS           [expr 1000.0 * $CLK_PERIOD_NS]

set LIBS [concat {*}[lmap lib $LIB_FILES {concat "-liberty" $lib}]]
set EXCLUDE_CELLS [concat {*}[lmap cell $DONT_USE_CELLS {concat "-dont_use" $cell}]]

#===========================================================
#   options
#===========================================================
set do_flatten 0
if {[info exists env(LITE_FLATTEN)] && $::env(LITE_FLATTEN) != 0} {
  set do_flatten 1
}
# onehot/muxpack are cheap compared to ABC and shrink the large memory mux
# network a lot; keep them enabled.  Set LITE_SKIP_OPT=1 to skip them.
set do_opt 1
if {[info exists env(LITE_SKIP_OPT)] && $::env(LITE_SKIP_OPT) != 0} {
  set do_opt 0
}
# Timing-driven but still lightweight ABC script.  `map {D}` maps for the clock
# period and `buffer -N 24` inserts buffer trees on high-fanout nets (without
# it, a control signal driving 100k+ flip-flops shows an absurd delay).  The
# final `topo` is needed before stime/topology queries.
# Use LITE_ABC_SCRIPT="+strash; map" for a faster, area-only mapping.
set abc_script "+strash; dretime; map {D}; topo; buffer -N 24; topo"
if {[info exists env(LITE_ABC_SCRIPT)] && $::env(LITE_ABC_SCRIPT) ne ""} {
  set abc_script $::env(LITE_ABC_SCRIPT)
}
set write_sim 1
if {[info exists env(LITE_WRITE_SIM)] && $::env(LITE_WRITE_SIM) == 0} {
  set write_sim 0
}

# Create SDC file used by ABC for the driving cell / load
set sdc_file $RESULT_DIR/abc.sdc
set outfile [open ${sdc_file} w]
puts $outfile "set_driving_cell $BUF_CELL"
puts $outfile "set_load 1.6"
close $outfile

#===========================================================
#   main running
#===========================================================
yosys -import

set RTL_INC "/home/blossilver/ysyx-workbench/npc/vsrc/include"
if {[info exists env(RTL_INC)] && $::env(RTL_INC) ne ""} {
  set RTL_INC $::env(RTL_INC)
}
set INCLUDE_ARGS {}
foreach inc [split $RTL_INC ":"] {
  if {$inc ne ""} {
    lappend INCLUDE_ARGS -I$inc
  }
}

foreach file $VERILOG_FILES {
  read_verilog -sv {*}$INCLUDE_ARGS $file
}

if {[info exists env(YOSYS_KEEP)] && $::env(YOSYS_KEEP) != 0} {
  puts "\[INFO\]: YOSYS_KEEP is set: preserving all logic (keep attribute)."
  setattr -set keep 1 a:*
}

#===========================================================
#   generic synthesis (coarse)
#===========================================================
if {$do_flatten} {
  log "\[INFO\]: LITE: flattening before ABC (LITE_FLATTEN=1)."
  synth -top $DESIGN -flatten -run :fine
} else {
  log "\[INFO\]: LITE: hierarchical synthesis (no flatten); ABC runs per module."
  synth -top $DESIGN -run :fine
}

if {$do_opt} {
  log "\[INFO\]: LITE: running optional optimization passes (LITE_OPT=1)."
  if {[info exists env(YOSYS_SHARE_AGGRESSIVE)] && $::env(YOSYS_SHARE_AGGRESSIVE) != 0} {
    share -aggressive
  } else {
    share
  }
  onehot
  muxpack
  opt_demorgan
  opt_ffinv
}

#===========================================================
#   generic synthesis (fine), without the built-in (redundant) ABC
#===========================================================
opt -fast -full
memory_map
opt -full
techmap
opt -fast

opt_clean -purge

# split internal nets
splitnets -format __v
# rename DFFs from the driven signal
yosys rename -wire -suffix _reg_p t:*DFF*_P*
yosys rename -wire -suffix _reg_n t:*DFF*_N*
# rename all other cells
autoname t:*DFF* %n

# technology mapping for clockgate
clockgate {*}$LIBS {*}$EXCLUDE_CELLS

# technology mapping for flip-flops
dfflibmap {*}$LIBS {*}$EXCLUDE_CELLS

# optimize the design
opt -undriven -purge

# Debug hook: dump the pre-ABC netlist and stop.
if {[info exists env(LITE_DUMP_PRE_ABC)] && $::env(LITE_DUMP_PRE_ABC) ne ""} {
  log "\[INFO\]: LITE: writing pre-ABC netlist to $::env(LITE_DUMP_PRE_ABC)"
  write_rtlil $::env(LITE_DUMP_PRE_ABC)
  return
}

#===========================================================
#   lightweight technology mapping
#===========================================================
log "\[INFO\]: LITE ABC script: $abc_script"
abc -D "$CLK_PERIOD_PS" \
  -constr "$sdc_file" \
  {*}$LIBS {*}$EXCLUDE_CELLS \
  -script "$abc_script"

# technology mapping for constant hi- and/or lo-drivers
hilomap -singleton -hicell {*}$TIEHI_CELL_AND_PORT -locell {*}$TIELO_CELL_AND_PORT

# replace undef values with defined constants
setundef -zero

# remove unused cells and wires
opt_clean -purge

# Flatten at gate level (cheap compared to flattening before ABC) so the
# netlist handed to iEDA is flat even though ABC ran per module.
if {!$do_flatten} {
  log "\[INFO\]: LITE: flattening gate-level netlist for STA."
  flatten
  opt_clean -purge
}

autoname

if {$write_sim} {
  # netlist for simulation without splitting module ports
  write_verilog -noattr -noexpr -nohex -nodec -defparam $NETLIST_SYN_V.sim
}

# splitting nets resolves compound assign statements (assign {..} = {..})
splitnets -format __v -ports

opt_clean -purge

# Drop simulation-only cells ($print/$check) that iEDA cannot parse
delete t:\$print
delete t:\$check
opt_clean -purge

# load liberty file before checking
foreach l $LIB_FILES { read_liberty -lib $l }

# reports
tee -o $RESULT_DIR/synth_check.txt check -mapped
tee -o $RESULT_DIR/synth_stat.txt stat {*}$LIBS

# write synthesized design
write_verilog -noattr -noexpr -nohex -nodec -defparam $NETLIST_SYN_V
