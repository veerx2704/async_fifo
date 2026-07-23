`include "define.sv"
`ifndef FIFO_INTERFACE__SV
`define FIFO_INTERFCACE__SV

interface w_if(input wclk, input wrst);

logic [`DATA_SIZE-1:0] d_in;
logic wen;
logic full;

endinterface

interface r_if(input rclk, rrst);

logic [`DATA_SIZE-1:0] d_out;
logic ren;
logic empty;

endinterface

`endif
