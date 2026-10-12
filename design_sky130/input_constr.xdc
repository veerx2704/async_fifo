create_clock -name wclk -period 2.00 [get_ports wclk]
create_clock -name rclk -period 2.00 [get_ports rclk]

set_clock_groups -asynchronous \
    -group [get_clocks wclk] \
    -group [get_clocks rclk]

set_input_delay -clock wclk -max 1.0 [get_ports {wdata[*] wen wrst}]
set_input_delay -clock wclk -min 0.0 [get_ports {wdata[*] wen wrst}]

set_input_delay -clock rclk -max 1.0 [get_ports {ren rrst}]
set_input_delay -clock rclk -min 0.0 [get_ports {ren rrst}]
