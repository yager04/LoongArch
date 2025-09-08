module FIR_18(
    input wire clk,
    input wire rst_n,
    input wire En,
	input wire signed [15:0] in,
	output wire signed [15:0] out
	);
parameter DW = 16;
/*
FIRcsd编码
00-10_-100-1_0101
1000_0001_0000
1000_00-10_-100-1
10-10_0001_0000
10-10_0001_0101
10-10_-1000_1001
0100_1010_0000
0100_10-10_-1010
010-1_0001_0010
010-1_0010_-100-1
0100_-1000_-1001
010-1_00-10_0101
010-1_00-10_0010
010-1_00-10_0101
010-1_0-101_0001
0010_0100_10-10
010-1_0-10-1_0-100
0010_0010_0101
*/
	wire signed [DW-1:0] data_delay0,data_delay1,data_delay2,data_delay3,data_delay4,data_delay5;
	wire signed [DW-1:0] data_delay6,data_delay7,data_delay8,data_delay9,data_delay10,data_delay11;
	wire signed [DW-1:0] data_delay12,data_delay13,data_delay14,data_delay15,data_delay16,data_delay17;
	
	wire signed [DW+11:0] data_gain0,data_gain1,data_gain2,data_gain3,data_gain4,data_gain5;
	wire signed [DW+11:0] data_gain6,data_gain7,data_gain8,data_gain9,data_gain10,data_gain11;
	wire signed [DW+11:0] data_gain12,data_gain13,data_gain14,data_gain15,data_gain16,data_gain17;
	
	wire signed [DW+11:0] out_add,in_add;
//-----------------------信号延时---------------------------
//----------------------------------------------------------------------------------------
    wire [4:0]Wnum1;
	reg RdEn1;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn1=1'b0;
else if(Wnum1>=31)RdEn1=1'b1;
else RdEn1=1'b0;
end
/*
	fifo_sc_top FIR1_FIFO(
		.Data(in), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn1), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum1), //output [10:0] Wnum
		.Q(data_delay0), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
*/
	rev_fifo#(
	    .WIDTH   (16),
	    .DEPTH   (32)
	)
	u1_rev_fifo
	(
	    .rst        (~rst_n     ),
	    .clk        (clk        ),
	    
	    .wr_en      (En ),
	    .din        (in), 
	    
	    .rd_en      (En&RdEn1 ),
	    .dout       (data_delay0)
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,206)  delay1(clk,rst_n,in,    data_delay0);

//----------------------------------------------------------------------------------------
    wire [4:0]Wnum2;
	reg RdEn2;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn2=1'b0;
else if(Wnum2>=31)RdEn2=1'b1;
else RdEn2=1'b0;
end
/*
	fifo_sc_top FIR2_FIFO(
		.Data(data_delay0), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn2), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum2), //output [10:0] Wnum
		.Q(data_delay1), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
*/
	rev_fifo#(
	    .WIDTH   (16),
	    .DEPTH   (32)
	)
	u2_rev_fifo
	(
	    .rst        (~rst_n     ),
	    .clk        (clk        ),
	    
	    .wr_en      (En ),
	    .din        (data_delay0), 
	    
	    .rd_en      (En&RdEn2 ),
	    .dout       (data_delay1)
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,826)  delay2(clk,rst_n,data_delay0,   data_delay1);

//----------------------------------------------------------------------------------------
    wire [4:0]Wnum3;
    reg RdEn3;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn3=1'b0;
else if(Wnum3>=26)RdEn3=1'b1;
else RdEn3=1'b0;
end
/*
	fifo_sc_top FIR3_FIFO(
		.Data(data_delay1), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn3), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum3), //output [10:0] Wnum
		.Q(data_delay2), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	)*/
	rev_fifo#(
	    .WIDTH   (16),
	    .DEPTH   (32)
	)
	u3_rev_fifo
	(
	    .rst        (~rst_n     ),
	    .clk        (clk        ),
	    
	    .wr_en      (En ),
	    .din        (data_delay1), 
	    
	    .rd_en      (En&RdEn3 ),
	    .dout       (data_delay2)
	);

//----------------------------------------------------------------------------------------
//	sig_delay#(DW,48)   delay3(clk,rst_n,data_delay1,   data_delay2);

//----------------------------------------------------------------------------------------
    wire [4:0]Wnum4;
	reg RdEn4;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn4=1'b0;
else if(Wnum4>=24)RdEn4=1'b1;
else RdEn4=1'b0;
end
/*
	fifo_sc_top FIR4_FIFO(
		.Data(data_delay2), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn4), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum4), //output [10:0] Wnum
		.Q(data_delay3), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
*/
	rev_fifo#(
	    .WIDTH   (16),
	    .DEPTH   (32)
	)
	u4_rev_fifo
	(
	    .rst        (~rst_n     ),
	    .clk        (clk        ),
	    
	    .wr_en      (En ),
	    .din        (data_delay2), 
	    
	    .rd_en      (En&RdEn4 ),
	    .dout       (data_delay3)
	);

	
//-----------------------移位相加---------------------------
	//1101_0111_0101/00-10_-100-1_0101*
	assign data_gain0={{12{data_delay0[DW-1]}},data_delay0}+
	{{10{data_delay0[DW-1]}},data_delay0,2'b0}-
	{{8{data_delay0[DW-1]}},data_delay0,4'b0}-
	{{5{data_delay0[DW-1]}},data_delay0,7'b0}-
	{{3{data_delay0[DW-1]}},data_delay0,9'b0};
	
	//1000_0001_0000*
	assign data_gain1={{8{data_delay1[DW-1]}},data_delay1,4'b0}+{{1{data_delay1[DW-1]}},data_delay1,11'b0};
	
	//0111_1101_0111/1000_00-10_-100-1*
	assign data_gain2=-{{12{data_delay2[DW-1]}},data_delay2}-
	{{9{data_delay2[DW-1]}},data_delay2,3'b0}-
	{{7{data_delay2[DW-1]}},data_delay2,5'b0}+
	{data_delay2[DW-1],data_delay2,11'b0};
	
	//0110_0001_0000*
	assign data_gain3={{8{data_delay3[DW-1]}},data_delay3,4'b0}+
	{{3{data_delay3[DW-1]}},data_delay3,9'b0}+
	{{2{data_delay3[DW-1]}},data_delay3,10'b0};
	

	assign in_add={in,12'b0};
	assign out_add=in_add+data_gain0+data_gain1+data_gain2+data_gain3;
	
	assign out=out_add>>>12;
	
endmodule
