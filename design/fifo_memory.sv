`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Veer Mukadam
// 
// Create Date: 07/10/2026 04:30:24 PM
// Design Name: Asynchronous FIFO
// Module Name: fifo_memory
// Project Name: CDC Handling
// Target Devices: 
// Tool Versions: AMD-Xlinix Vivado 2024.2
// Description: This is the memory of asynchronous fifo
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo_memory #(parameter N = 16, parameter D = 32, localparam ptr_width = $clog2(N))(
    input wire [ptr_width-1:0] waddr,
    input wire [ptr_width-1:0] raddr,
    input wire clk,
    input wire rst,
    input wire wen,
    input wire ren,
    input wire [D-1:0] wdata,
    output wire [D-1:0] rdata
    );
    
    reg [D-1:0] mem [N-1:0];
    int i;
    always @(posedge clk) begin
        if(!rst) begin
            for (i = 0; i < N; i=i+1)
                mem[i] <= '0;               // Reset all data upon write reset
        end
        else begin
            if(wen) mem[waddr] <= wdata;
            else mem[waddr] <= mem[waddr];  // Update only when write is enabled
        end
    end
    
    assign rdata = ren ? mem[raddr] : 'z;   // Read data through a tristate-buffer
endmodule
