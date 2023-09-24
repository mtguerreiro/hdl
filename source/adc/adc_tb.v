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

reg [31:0] clk_div = 3;

wire clk_spi;
wire cs_spi;
reg sd_spi_1 = 1'b1;
reg sd_spi_2 = 1'b1;
reg sd_spi_3 = 1'b1;
reg sd_spi_4 = 1'b1;
reg sd_spi_5 = 1'b1;
reg sd_spi_6 = 1'b1;
reg sd_spi_7 = 1'b1;
reg sd_spi_8 = 1'b1;

reg [63:0] counter_tb = 0;

wire done;
wire [127:0] data_adc;
reg [127:0] data;

wire dbg;

adc UUT (
    .clk(clk),
    .clk_div(clk_div),
    .start(start),
    .clk_spi(clk_spi),
    .cs_spi(cs_spi),
    .sd_spi_1(sd_spi_1),
    .sd_spi_2(sd_spi_2),
    .sd_spi_3(sd_spi_3),
    .sd_spi_4(sd_spi_4),
    .sd_spi_5(sd_spi_5),
    .sd_spi_6(sd_spi_6),
    .sd_spi_7(sd_spi_7),
    .sd_spi_8(sd_spi_8),
    .done(done),
    .data(data_adc),
    .dbg(dbg)
);

initial begin
    data[15:0] <= 16'b1000000000000000;
    data[31:16] <= 16'b1000000000000000;
    data[47:32] <= 16'b1100000000001000;
    data[63:48] <= 16'b1011010101010000;
    data[79:64] <= 16'b1100000000001000;
    data[95:80] <= 16'b1100000000001000;
    data[111:96] <= 16'b1000000000000000;
    data[127:112] <= 16'b1000000000000000;
end

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
    sd_spi_1 <= data[0];
    sd_spi_2 <= data[16];
    sd_spi_3 <= data[32];
    sd_spi_4 <= data[48];
    sd_spi_5 <= data[64];
    sd_spi_6 <= data[80];
    sd_spi_7 <= data[96];
    sd_spi_8 <= data[112];
    
    data <= data >> 1;
end

always @ (posedge clk)
begin
counter_tb <= counter_tb + 1;
end

endmodule
