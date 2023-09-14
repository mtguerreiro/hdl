`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2023 11:51:46 AM
// Design Name: 
// Module Name: pwm_tb
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


module pwm_tb(

    );

reg clk = 1'b0;
reg reset = 1'b1;

reg [31:0] period = 5;
reg [31:0] duty = 1;

reg pwm_enable = 1'b1;
wire pwm;
wire pwm_cmp;

reg [31:0] dead_time = 0;

reg ovf_trigger_enable = 1'b1;
wire ovf_trigger;

reg [63:0] counter_tb = 0;

pwm UUT (
    .clk(clk), 
    .reset(reset), 
    .period(period), 
    .duty(duty), 
    .pwm_enable(pwm_enable),
    .pwm(pwm), 
    .pwm_cmp(pwm_cmp),
    .dead_time(dead_time),
    .ovf_trigger_enable(ovf_trigger_enable),
    .ovf_trigger(ovf_trigger)
);


always
begin
clk = 1'b1;
#5; 

clk = 1'b0;
#5;
end

always @ (posedge clk)
begin

    if(counter_tb <= 20) begin
        reset <= 1;
        period <= 10;
        duty <= 3;
        dead_time <= 0;
    end
    
    else if( (counter_tb > 20) && (counter_tb < 80) ) begin
        reset <= 0;
    end

    else if( (counter_tb > 250) && (counter_tb < 260) ) begin
        duty <= 6;
        dead_time <= 1;
    end
    
    else if( (counter_tb > 450) && (counter_tb < 460) ) begin
        ovf_trigger_enable <= 0;
    end
end


always @ (posedge clk)
begin
counter_tb <= counter_tb + 1;
end


endmodule
