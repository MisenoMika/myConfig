set SDC_FILE   [lindex $argv 0]
set NETLIST_V  [lindex $argv 1]
set DESIGN     [lindex $argv 2]
set PDK        [lindex $argv 3]
set RESULT_DIR [file dirname $NETLIST_V]

source "[file dirname [info script]]/common.tcl"

set_design_workspace $RESULT_DIR
read_netlist $NETLIST_V
read_liberty [concat $LIB_FILES]
link_design $DESIGN
read_sdc  $SDC_FILE
report_timing -max_path 5

# Power analysis is optional: on memory-heavy netlists iEDA's power engine can
# exhaust memory and get OOM-killed, which would abort the whole run even
# though the timing report is already written. Enable with PWR_REPORT=1.
set pwr_report 0
if {[info exists env(PWR_REPORT)] && $::env(PWR_REPORT) != 0} {
  set pwr_report 1
}
if {$pwr_report} {
  report_power -toggle 0.1
}
