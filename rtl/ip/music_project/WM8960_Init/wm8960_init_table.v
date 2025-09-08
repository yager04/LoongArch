/*============================================================================
*
*  LOGIC CORE:          WM8960初始化寄存器表
*  MODULE NAME:         wm8960_init_table()
*  COMPANY:             武汉芯路恒科技有限公司
*                       http://xiaomeige.taobao.com
*	author:					小梅哥
*	Website:					www.corecourse.cn
*  REVISION HISTORY:  
*
*    Revision 1.0  04/10/2019     Description: Initial Release.
*
*  FUNCTIONAL DESCRIPTION:
===========================================================================*/

module wm8960_init_table
#(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=8)
(
	input [(ADDR_WIDTH-1):0] addr,
	input clk, 
	output reg [(DATA_WIDTH-1):0] q,
	output [7:0]dev_id,
	output [7:0]lut_size
);

	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];
	
	assign dev_id = 8'h34;		//WM8960 IIC接口器件地址
	assign lut_size = 8'd16;	//WM8960 寄存器初始化数量

	//Line IN	
	always @ (*) begin
		rom[0 ][15:0] = {7'h0f,9'h000}; //  reset  WM8960    
		rom[1 ][15:0] = {7'h19,9'h0FC};  
		rom[2 ][15:0] = {7'h1A,9'h1E1};
		rom[3 ][15:0] = {7'h2F,9'h00C};
		rom[4 ][15:0] = {7'h22,9'h100};
		rom[5 ][15:0] = {7'h25,9'h100};
		rom[6 ][15:0] = {7'h05,9'h000};
		rom[7 ][15:0] = {7'h02,9'h179};
		rom[8 ][15:0] = {7'h03,9'h179};
		rom[9 ][15:0] = {7'h2B,9'h050}; 
		rom[10][15:0] = {7'h2C,9'h00A};
		rom[11][15:0] = {7'h07,9'h042}; 
		rom[12][15:0] = {7'h04,9'h005}; 
		rom[13][15:0] = {7'h34,9'h028}; 
		rom[14][15:0] = {7'h08,9'h1C4}; 
		rom[15][15:0] = {7'h09,9'h000}; 
	end
	always @ (posedge clk)
	begin
		q <= rom[addr];
	end

endmodule
