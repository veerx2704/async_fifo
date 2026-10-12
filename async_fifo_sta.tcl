log_begin synth_logs/timing_report.log
read_liberty $::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog results/fifo_netlist.v
link_design async_fifo

read_sdc design_sky130/input_constr.xdc

check_setup

report_checks -path_delay max -digits 4
report_checks -path_delay min -digits 4

report_wns
report_tns
report_power

exit
log_end
