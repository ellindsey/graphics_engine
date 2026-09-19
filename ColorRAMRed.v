`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2023 12:06:08 PM
// Design Name: 
// Module Name: ColorRAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ColorRAMRed(
    input [7:0] wdataA,
    input [7:0] addrA,
    input [7:0] addrB,
    input clkA,
    input weA,
    input clkB,
    output reg [7:0] rdataA,
    output reg [7:0] rdataB
    );
    
reg [7:0] mem [255:0];

initial begin
 // Initialize memory with external file
 $readmemh("memRed.mem", mem);
end
 
always@(posedge clkA) begin
    rdataA = mem[addrA];
    if (weA) begin
        mem[addrA] = wdataA;
    end
 end
 
 always@(posedge clkB) begin
    rdataB = mem[addrB];
 end
 
endmodule
