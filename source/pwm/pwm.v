`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2023 11:04:17 AM
// Design Name: 
// Module Name: pwm
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

module pwm(
    clk,
    reset,
    period,
    duty,
    pwm_enable,
    pwm,
    pwm_cmp,
    dead_time,
    ovf_trigger_enable,
    ovf_trigger
    );
    
input clk;
input reset;

input [31:0] period;
input [31:0] duty;

input [31:0] dead_time;

input pwm_enable;
output wire pwm;
output wire pwm_cmp;

input ovf_trigger_enable;
output wire ovf_trigger;

reg [31:0] period_int = 32'b0;
reg [31:0] duty_int = 32'b0;
reg[31:0] counter = 32'b0;
reg [31:0] dead_time_int = 32'b0;

reg pwm_signal = 1'b0;
reg pwm_cmp_signal = 1'b0;

reg dir = 1'b0;

reg ovf_signal = 1'b0;

reg [31:0] counter_inc = 32'b1;

/* Counter */
always @ (posedge clk)
begin
    if( reset == 1'b1 ) begin
        counter <= 32'b0;
    end
    else begin
        counter <= counter + counter_inc;
    end
end

/* Set counter increment/decrement */
always @(negedge clk)
begin
    if( reset == 1'b1 ) begin
        counter_inc <= -1;
    end
    else begin
        if( dir == 1'b1 ) begin
            counter_inc <= -counter_inc;
        end
    end
end

/* Change counter direction and ovf signal generation */
always @ (*)
begin
    if( reset == 1'b1 ) begin
        dir = 1'b0;
        ovf_signal = 1'b0;
    end
    else begin
        if( counter >= period_int ) begin
            dir = 1'b1;
            ovf_signal = 1'b1;
        end
        else if( counter == 0) begin
            dir = 1'b1;
            ovf_signal = 1'b0;
        end
        else begin
            ovf_signal = 1'b0;
            dir = 1'b0;
        end
    end
end

/* Reload */
always @(negedge clk)
begin
    if( reset == 1'b1 ) begin
        period_int <= period;
        duty_int <= duty;
        dead_time_int <= dead_time;
    end
    else begin
        if( (dir == 1'b1) && (counter_inc == -32'b1) ) begin
            period_int <= period;
            duty_int <= duty;
            dead_time_int <= dead_time;
        end
    end
end

/* PWM generation */
always @ (*)
begin
    if( reset == 1'b1 ) begin
        pwm_signal = 1'b0;
        pwm_cmp_signal = 1'b0;
    end
    else begin
        if( counter_inc == 32'b1 ) begin
            if( counter >= (duty_int - dead_time_int) ) begin
                if( counter >= duty_int ) begin
                    pwm_signal = 1'b0;
                    pwm_cmp_signal = 1'b1;
                end
                else begin
                    pwm_signal = 1'b0;
                    pwm_cmp_signal = 1'b0;                
                end
            end
            else begin
                pwm_cmp_signal = 1'b0;
                pwm_signal = 1'b1;
            end
        end
        else begin
            if( counter <= (duty_int + dead_time_int) ) begin
                if( counter <= duty_int ) begin
                    pwm_cmp_signal = 1'b0;
                    pwm_signal = 1'b1;
                end
                else begin
                    pwm_cmp_signal = 1'b0;
                    pwm_signal = 1'b0;                
                end
            end
            else begin
                pwm_cmp_signal = 1'b1;
                pwm_signal = 1'b0;
            end        
        end
    end
end

///* PWM output */
assign pwm = pwm_signal & ~reset & pwm_enable;
assign pwm_cmp = pwm_cmp_signal & ~reset & pwm_enable;
assign ovf_trigger = ovf_signal & ovf_trigger_enable;

endmodule
