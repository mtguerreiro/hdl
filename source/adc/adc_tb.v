`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2023 04:14:33 PM
// Design Name: 
// Module Name: adc_tb
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


module adc_tb(

    );

reg clk = 1'b0;
reg start = 1'b0;

reg [31:0] clk_div = 10;

wire clk_spi;
wire cs_spi;
reg sd_spi = 1'b1;

reg [63:0] counter_tb = 0;

wire done;
wire [15:0] data;

adc UUT (
    .clk(clk),
    .clk_div(clk_div),
    .start(start),
    .clk_spi(clk_spi),
    .cs_spi(cs_spi),
    .sd_spi(sd_spi),
    .done(done),
    .data(data)
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
        start <= 0;

    end
    
    else if( (counter_tb > 20) && (counter_tb < 80) ) begin
        start <= 1;
    end

    else if( (counter_tb > 40) && (counter_tb < 260) ) begin
        start <= 1;

    end
    
    else if( (counter_tb > 450) && (counter_tb < 460) ) begin

    end
end

always @ (negedge clk_spi) begin
    sd_spi <= sd_spi ^ 1; 
end

always @ (posedge clk)
begin
counter_tb <= counter_tb + 1;
end

endmodule
