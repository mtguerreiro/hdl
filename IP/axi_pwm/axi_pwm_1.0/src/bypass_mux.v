`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2024 12:03:15
// Design Name: 
// Module Name: bypass_mux
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


module bypass_mux(
    bypass_control,
    bypass_duty,
    non_bypass_duty,
    selected_duty
    );
    
    input bypass_control;
    input [31:0] bypass_duty;
    input [31:0] non_bypass_duty;
    output reg [31:0] selected_duty;

    always @ (*)
    begin
        if ( bypass_control == 1'b1 ) selected_duty <= bypass_duty;
        else selected_duty <= non_bypass_duty;
    end
endmodule
