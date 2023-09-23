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
reg [31:0] dead_time_int = 32'b0;

reg [31:0] base_counter = 32'b0;
reg [31:0] base_period = 32'b0;

reg [31:0] pwm_counter = 32'b0;

reg pwm_signal = 1'b0;
reg pwm_cmp_signal = 1'b0;

reg ovf_signal = 1'b0;

/* Generates base counter and reload */
always @ (posedge clk)
begin
    if( reset == 1'b1 ) begin
        base_counter <= 32'b0;        
        duty_int <= duty;
        period_int <= period;
        dead_time_int <= dead_time;
        
        if( period == 0 ) base_period <= 0;
        else base_period <= (period << 1) - 1;
    end
    else begin
        
        if( base_counter < base_period ) begin
            base_counter <= base_counter + 1'b1;
        end
        else begin
            base_counter <= 32'b0;
            duty_int <= duty;
            period_int <= period;
            dead_time_int <= dead_time;

            if( period == 0 ) base_period <= 0;
            else base_period <= (period << 1) - 1;
        end
    end
end

/* Generates overflow signal */
always @ (posedge clk)
begin
    if( reset == 1'b1 ) begin
        ovf_signal <= 1'b0;
    end
    else begin
        if( base_counter == base_period ) ovf_signal <= 1'b1;
        else ovf_signal <= 1'b0;
    end
end

/* Generates PWM signals */
always @ (posedge clk)
begin
    if( reset == 1'b1 ) begin
        pwm_signal <= 1'b0;
        pwm_cmp_signal <= 1'b0;
    end
    else begin
    
        if( duty_int >= period_int) begin
            pwm_cmp_signal <= 1'b0;
            if( base_counter >= dead_time_int) pwm_signal <= 1'b1;
        end
        else if( duty_int == 0 ) begin
            pwm_signal <= 1'b0;
            if( base_counter >= dead_time_int) pwm_cmp_signal <= 1'b1;        
        end
        else begin
            if( base_counter < period_int ) begin
                if( base_counter < duty_int ) begin
                    pwm_signal <= 1'b1;
                    pwm_cmp_signal <= 1'b0;
                end
                else begin
                    pwm_signal <= 1'b0;
                    if( base_counter >= (duty_int + dead_time_int) ) pwm_cmp_signal <= 1'b1;
                end
            end
            else begin
                if( (duty_int + dead_time_int) >= base_period ) begin
                    pwm_cmp_signal <= 1'b0;
                    if( base_counter > (base_period - duty_int) ) pwm_signal <= 1'b1;
                end
                else if( base_counter <= (base_period - duty_int - dead_time_int) ) begin
                    pwm_signal <= 1'b0;
                    pwm_cmp_signal <= 1'b1;
                end
                else begin
                    pwm_cmp_signal <= 1'b0;
                    if( base_counter > (base_period - duty_int) ) pwm_signal <= 1'b1;
                end
            end
        end
    end
end

assign ovf_trigger = ovf_signal & ovf_trigger_enable;
assign pwm = pwm_signal & ~reset & pwm_enable;
assign pwm_cmp = pwm_cmp_signal & ~reset & pwm_enable;

endmodule
