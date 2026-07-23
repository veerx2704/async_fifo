`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Veer Mukadam
// 
// Create Date: 07/10/2026 04:29:52 PM
// Design Name: Asynchronous FIFO
// Module Name: async_fifo
// Project Name: CDC Handling
// Target Devices: 
// Tool Versions: AMD-Xilinx Vivado 2024.2
// Description: This is the top level module of asynchronous fifo
// 
// Dependencies: single_flop, operation_control, fifo_memory
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module async_fifo #(parameter data_width = 32, N = 16)(
    input wire [data_width - 1:0] wdata,
    input wire wen,
    input wire wclk,
    input wrst,
    input rrst,
    input wire rclk,
    input wire ren,
    output wire [data_width - 1:0] rdata,
    output wire fifo_full,
    output wire fifo_empty
    );
    localparam ptr_width = $clog2(N);
    
    
    wire [data_width-1:0] rdata_mem;
    wire [ptr_width:0] wptr, rptr;
  wire [ptr_width:0] rptr_0;
  wire [ptr_width:0] rptr_1;
  wire [ptr_width:0] wptr_0;
  wire [ptr_width:0] wptr_1;
  wire [ptr_width:0] wptr_bin;
  wire [ptr_width:0] rptr_bin;
    
    operation_control #(.N(N)) write_handler (.clk(wclk),                   // The write pointer handler
                                              .in_addr(rptr_1),
                                              .rst(wrst),
                                              .wr('0),
                                              .en(wen),
                                              .out_addr(wptr_bin),
                                              .out_addr_gray(wptr),
                                              .fifo_status(fifo_full));
    operation_control #(.N(N)) read_handler (.clk(rclk),                    // The read pointer handler
                                              .in_addr(wptr_1),
                                              .rst(rrst),
                                              .wr('1),
                                              .en(ren),
                                              .out_addr(rptr_bin),
                                              .out_addr_gray(rptr),
                                              .fifo_status(fifo_empty));
                                              

     // 2-flop synchronizer for write pointer 
     single_flop #(.N(ptr_width+1)) W_CROSSED_0(.clk(rclk), .rst(rrst), .en('1), .d_in(wptr), .d_out(wptr_0));
     single_flop #(.N(ptr_width+1)) W_CROSSED_1(.clk(rclk), .rst(rrst), .en('1), .d_in(wptr_0), .d_out(wptr_1));

     // 2-flop synchronizer for read pointer
     single_flop #(.N(ptr_width+1)) R_CROSSED_0(.clk(wclk), .rst(wrst), .en('1), .d_in(rptr), .d_out(rptr_0));
     single_flop #(.N(ptr_width+1)) R_CROSSED_1(.clk(wclk), .rst(wrst), .en('1), .d_in(rptr_0), .d_out(rptr_1));
     
     
     assign wen_mem = wen & (~fifo_full);         //Handling data updation in memory when fifo is essentially not full
     assign ren_mem = ren & (~fifo_empty);        //Handling data fetching from memory when fifo is essentially not empty
     fifo_memory #(.N(N), .D(data_width)) FIFO (.clk(wclk),                     //The main memory of fifo
                                                .rst(wrst),
                                                .waddr(wptr_bin[ptr_width-1:0]),
                                                .wen(wen_mem),
                                                .ren(ren_mem),
                                                .wdata(wdata),
                                                .raddr(rptr_bin[ptr_width-1:0]),
                                                .rdata(rdata_mem));
     
     assign rdata = rdata_mem;
endmodule
