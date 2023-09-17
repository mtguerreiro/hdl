`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2022 03:14:31 PM
// Design Name: 
// Module Name: adc_hdl
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

module adc_hdl(adc_clk, adc_cs, adc_new, adc_data, adc_sd, CLK100MHZ, adc_en, adc_clk_div, adc_sample_test);

// Inverts adc_cs and adc_clk logic levels
parameter adc_out_inv = 1'b0;

// Inverts adc_sd logic levels
parameter adc_sd_inv = 1'b0;

output reg adc_sample_test = 1'b0;
output adc_clk;
output reg adc_cs = 1'b1;
output reg adc_new = 1'b1;
output reg [14:0] adc_data = 15'b0;

input [31:0] adc_clk_div;
input adc_en;
input adc_sd;
input CLK100MHZ;

integer clk_count = 32'b0;
integer adc_clk_count = 32'b0;

reg adc_clk_en = 1'b1;
reg [14:0] adc_data_temp = 15'b0;

reg clk_int = 1'b0;

wire clk;

assign clk = CLK100MHZ;
assign adc_clk = (clk_int | adc_clk_en) ^ adc_out_inv;

//initial
//begin    

//    //clk_count = 0;
//    //clk_int = 0;
        
//    //adc_cs = 0 ^ adc_out_inv;
//    //adc_clk_count = 0;
//    //adc_clk_en = 1;
    
//    //adc_new = 1;
    
//    //adc_data = 0;
//    //adc_data_temp = 0;
    
//    //adc_sample_test = 0;
//end

always @ (posedge clk)
begin

if( (adc_en == 0) && ((adc_cs ^ adc_out_inv) == 1) )
    begin
    clk_count = 0;
    adc_clk_count = 0;
    clk_int = 0;
    end
else
    begin
    
    if( adc_clk_count == 0 )
        begin
        adc_cs = 0 ^ adc_out_inv;
        adc_new = 0;
        end
    else if (adc_clk_count == 1) adc_clk_en = 0;
    else if (adc_clk_count == 17)
        begin
            adc_clk_en = 1;
            adc_new = 1;
        end
    else if (adc_clk_count == 18)
        begin
            adc_cs = 1 ^ adc_out_inv;
        end
            
    /* Internal clock */
    clk_count = clk_count + 1;
    
    if( clk_count == adc_clk_div )
        begin
        clk_int = clk_int ^ 1'b1;
        clk_count = 0;
        if( (clk_int == 1) && (adc_clk_count <= 21) ) adc_clk_count = adc_clk_count + 1;
        end   
    end
         
end

always @ (posedge clk_int)
begin

//if( adc_clk_count == 1 )
//    begin 
//    //adc_new = 0;
//    //adc_cs = 0 ^ adc_out_inv;
//    end 

//if( adc_clk_count == 2 ) adc_clk_en = 0;

if( ( adc_clk_count >= 1 ) && ( adc_clk_count <= 15 ) )
    begin
    adc_data_temp = adc_data_temp << 1;
    adc_data_temp[0] = adc_sd ^ adc_sd_inv;
    end

if( adc_clk_count == 16 )
    begin
    //adc_clk_en = 1;
    //adc_cs = 1 ^ adc_out_inv;
    adc_data = adc_data_temp;
    adc_data_temp = 0;
    //adc_new = 1;
    end

if( ( adc_clk_count >= 1 ) && ( adc_clk_count <= 15 ) ) adc_sample_test = 1;
else adc_sample_test = 0;
//if( adc_clk_count == 18 )
//    begin
//    adc_clk_en = 1;
//    adc_data = adc_data_temp;
//    adc_new = 1;
//    end
    
//if( adc_clk_count == 19 )
//    begin
//    adc_cs = 1 ^ adc_out_inv;
//    adc_data_temp = 0;
//    end

end

endmodule
