`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Veer Mukadam
// 
// Create Date: 07/07/2026 09:40:38 PM
// Design Name: Asynchronous FIFO
// Module Name: single_flop
// Project Name: CDC Handling
// Target Devices: 
// Tool Versions: AMD-Xilinx Vivado 2024.2
// Description: This is a singular flipflop, meant to discretely demonstrate a 2-flop synchronizer
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module single_flop #(parameter N = 1)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [N-1:0] d_in,
    output wire [N-1:0] d_out
    );
    reg [N-1:0] d_out_reg;
    always_ff @(posedge clk) begin
        if (!rst) d_out_reg <= '0;
        else if(en) d_out_reg <= d_in;
        else d_out_reg <= d_out_reg;
    end
    assign d_out = d_out_reg;
endmodule
