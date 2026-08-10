create_clock -name wclk -period 5.00 [get_ports wclk]
create_clock -name rclk -period 6.00 [get_ports rclk]

set_clock_groups -asynchronous \
    -group [get_clocks wclk] \
    -group [get_clocks rclk]
    

