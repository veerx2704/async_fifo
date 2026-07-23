`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "define.sv"
`include "fifo_interface.sv"
`include "transaction.sv"
`include "read_fifo_transaction.sv"
`include "write_fifo_sequencer.sv"
`include "read_fifo_sequencer.sv"
`include "write_fifo_seq.sv"
`include "read_fifo_seq.sv"
`include "virtual_sequencer.sv"
`include "write_fifo_driver.sv"
`include "read_fifo_driver.sv"
`include "write_fifo_monitor.sv"
`include "read_fifo_monitor.sv"
`include "write_fifo_agent.sv"
`include "read_fifo_agent.sv"
`include "reference_model.sv"
`include "scoreboard.sv"
`include "fifo_env.sv"
`include "base_test.sv"
`include "parallel_or_exclusive.sv"
`include "random_burst.sv"
`include "long_test.sv"
module top_tb;

  
reg wclk;
reg rclk;
reg wrst;
reg rrst;
reg ren;

w_if w_if(wclk, wrst);
r_if r_if(rclk, rrst);

  async_fifo  #(
    .data_width(`DATA_SIZE),
    .N(`DEPTH)
  )
  async_fifo(

    .rdata(r_if.d_out),
    .fifo_full(w_if.full),
    .fifo_empty(r_if.empty),
    .wdata(w_if.d_in),
    .wen(w_if.wen), 
    .wclk(wclk), 
    .wrst(wrst),
    .ren(r_if.ren), 
    .rclk(rclk), 
    .rrst(rrst)
  );


initial begin
   wclk = 0;
   forever begin
     #(`WPERIOD>>1) wclk = ~wclk;
   end
end

initial begin
   rclk = 0;
   forever begin
     #(`RPERIOD>>1) rclk = ~rclk;
   end
end

initial begin
   wrst = 1'b0;
   rrst = 1'b0;
   $display("DEPTH:%0d",`DEPTH);
   #1000;
   wrst = 1'b1;
   rrst = 1'b1;
end

initial begin
  run_test("parallel_or_exclusive");
  //run_test("random_burst");
  //run_test("long_test");
end

initial begin
  uvm_config_db#(virtual w_if)::set(null, "uvm_test_top.env.in_agent.drv", "w_if", w_if);
  uvm_config_db#(virtual w_if)::set(null, "uvm_test_top.env.in_agent.mon", "w_if", w_if);
  uvm_config_db#(virtual r_if)::set(null, "uvm_test_top.env.out_agent.drv", "r_if", r_if);
  uvm_config_db#(virtual r_if)::set(null, "uvm_test_top.env.out_agent.mon", "r_if", r_if);
end

// vcd
initial begin
  $dumpfile("top_tb.vcd");
  $dumpvars;
end

endmodule