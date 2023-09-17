`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2023 03:32:39 PM
// Design Name: 
// Module Name: adc
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


module adc(
    clk,
    clk_div,
    start,
    clk_spi,
    cs_spi,
    sd_spi,
    done,
    data
    );

input wire clk;
input wire start;
input wire [31:0] clk_div;

output reg clk_spi = 1'b1;
output reg cs_spi = 1'b1;
input wire sd_spi;

output reg done = 1'b0;
output reg [15:0] data = 16'b0;

reg [31:0] counter = 32'b0;
reg busy = 1'b1;

reg clk_spi_en = 1'b1;
reg [31:0] clk_counter = 32'b0;


reg [31:0] clk_spi_en_t = 32'b0;
reg [31:0] sample_t = 32'b0;
reg [31:0] last_sample_t = 32'b0;

reg [15:0] data_temp = 15'b0;

always @ (posedge clk) begin

    if( (start == 1'b0) && (cs_spi == 1'b1) ) begin
    
        counter <= 0;
        
        done <= 0;

        cs_spi <= 1;
        clk_spi_en <= 0;
        
        clk_spi_en_t <= 2 - 1;
        sample_t <= clk_div + clk_spi_en_t + 1;
        last_sample_t <= clk_div * 32 + clk_spi_en_t;
        
        data_temp <= 0;
        
    end
    
    else begin
    
        if(counter != last_sample_t) begin
            counter <= counter + 1;
        end
        
        if( counter == 0 ) begin
            cs_spi <= 0;
        end
        
        if( counter == clk_spi_en_t ) begin
            clk_spi_en <= 1; 
        end
        
        if( (counter == sample_t) && (counter < (last_sample_t - clk_div)) ) begin
            data_temp <= (data_temp << 1) | sd_spi;
            sample_t <= sample_t + 2 * clk_div;
        end
        
        if( counter == last_sample_t ) begin
            data <= data_temp;
            cs_spi <= 1;
            clk_spi_en <= 0;
            done <= 1;
        end
        
    end

end

/* SPI clock */
always @ (posedge clk) begin

    if( (start == 1'b0) && (cs_spi == 1'b1) || (clk_spi_en == 1'b0) ) begin
        clk_spi <= 32'b1;
        clk_counter <= 32'b0;
    end
   
    else begin
       
        if( clk_counter == 0 ) begin
            clk_spi <= clk_spi ^ 1'b1;
        end
        
        if( clk_counter == (clk_div - 1) ) begin
            clk_counter <= 0;
        end
        else begin
            clk_counter <= clk_counter + 1;
        end
    
    end
end

endmodule
