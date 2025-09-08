/*============================================================================
*
*  LOGIC CORE:          WM8731 寄存器初始化模块顶层	
*  MODULE NAME:         WM8731_Init()
*  COMPANY:             武汉芯路恒科�?有限公司
*                       http://xiaomeige.taobao.com
*	author:					小梅�?
*	Website:					www.corecourse.cn
*  REVISION HISTORY:  
*
*    Revision 1.0  04/10/2019     Description: Initial Release.
*
*  FUNCTIONAL DESCRIPTION:
===========================================================================*/


module WM8960_Init(
	Clk,
	Rst_n,

	I2C_Init_Done,
	i2c_sdat,
	i2c_sclk
);

	input Clk;
	input Rst_n;
	
	inout i2c_sdat;
	output i2c_sclk;
	output I2C_Init_Done;

	//产生初始化使能信�?
	reg [15:0]Delay_Cnt;
	reg Init_en;
	always@(posedge Clk)
	begin
		if(!Rst_n)
			Delay_Cnt <= 16'd0;
		else if(Delay_Cnt < 16'd60000)
			Delay_Cnt <= Delay_Cnt + 8'd1;
		else
			Delay_Cnt <= Delay_Cnt;
	end	
	
	always@(posedge Clk)
	begin
		if(!Rst_n)
			Init_en <= 1'b0;
		else if(Delay_Cnt == 16'd59999)
			Init_en <= 1'b1;
		else
			Init_en <= 1'b0;
	end

	I2C_Init_Dev I2C_Init_Dev(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.Go(Init_en),
		.Init_Done(I2C_Init_Done),
		.i2c_sclk(i2c_sclk),
		.i2c_sdat(i2c_sdat)
	);

endmodule
