`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Veer Mukadam
// 
// Create Date: 07/10/2026 04:54:04 PM
// Design Name: Asynchronous FIFO
// Module Name: operation_control
// Project Name: CDC Handling
// Target Devices: 
// Tool Versions: AMD-Xilinx Vivado
// Description: This is the control logic and pointer generation logic block
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module operation_control #(parameter N = 16, localparam ptr_width = $clog2(N))(
    input wire [ptr_width:0] in_addr,
    input wire clk,
    input wire rst,
    input wire en,
    input wire wr,
    output wire [ptr_width:0] out_addr,
    output wire [ptr_width:0] out_addr_wire,
    output wire fifo_status
    );
    
function automatic [ptr_width:0] B2G(           // FOr binary to gray conversion
    input [ptr_width:0] in0);
    B2G = in0 ^ (in0 >> 1); 
endfunction
    reg [ptr_width:0] out_addr_reg;             // The current pointer register
    reg [ptr_width:0] gray_out;                 // Gray value of current pointer
    wire [ptr_width:0] next_out_addr;           // Next calculated address
    // wire [ptr_width:0] out_addr_wire;           // Current calculated pointer
    reg fifo_status_reg;                        // status register for full/empty
    wire flag;                                  // Actual status of full/empty

    always @(posedge clk) begin
        if (!rst) out_addr_reg <= '0;           // Reset condition
        else out_addr_reg <= next_out_addr;
    end

    always @(posedge clk) begin
        if (!rst) fifo_status_reg <= '0;        
        else fifo_status_reg <= flag;           // Update the value of fifo status (full or empty) in next cycle
    end
    
    // always @(posedge clk) begin
    //     if (!rst) gray_out <= '0;
    //     else gray_out <= out_addr_wire;         //assign next gray pointer
    // end
    //wr = 1 for read, wr = 0 for write
    // for write, if write pointer rolls over, it catches up to read pointer. Thus, wptr[MSB] = !rptr[MSB]
    // When rollover happens, the two MSBs are always toggled for the same address before toggling.
    // Example, 00000 becomes 11000, 00100 becomes 11100, 01100 beomes 10100 etc.
    assign flag = wr ? (out_addr_wire == in_addr ? '1 : '0) : (out_addr_wire == {~in_addr[ptr_width:ptr_width-1],in_addr[ptr_width-2:0]} ? '1 : '0);        
    
    //Calculate the next gray output
    assign out_addr_wire = next_out_addr;

    // Assert the current gray output
    // assign out_addr_gray = gray_out;

    // Calculate the next actual output, if fifo is not full or empty increment by 1 or else hold
    assign next_out_addr = (en && !fifo_status_reg) ? out_addr_reg + 1 : out_addr_reg;

    //Drive the current pointer
    assign out_addr = out_addr_reg;

    //Drive the fifo status
    assign fifo_status = fifo_status_reg;
    
    
    
endmodule
