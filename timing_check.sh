#!/usr/bin/bash

if grep -i -q "\(VIOLATED\)" synth_logs/timing_report.log; then 
		echo "Error in Design! Timing constraint violated. Check power_timing_report.log for more details"; 
	else 
		echo "No Error in design! The synthesized design passes timing constraints. Check power_timing_report.log for a detailed analysis"; 
fi