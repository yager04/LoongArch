module keyshape(
    input   wire           clk,
    input   wire           rst,
    input   wire           key_in,
    output  wire           keyv
);

parameter MS_MAX = 20'd499_999;

reg [19:0]  ms_count;

always@(posedge clk) begin
    if(rst)ms_count <= 0;
    else if (~key_in)ms_count <= 0;
    else if(ms_count < MS_MAX)ms_count <= ms_count + 1;    
end

reg keyvr,keyvrr;
always@(posedge clk) begin
    if(rst)keyvr<=0;
	else if(ms_count == MS_MAX - 1)keyvr<=key_in;
	else if(~key_in)keyvr <= 0;
end

//通过keyvrr抓取按键的单次触发，即按下按键产生单个时钟周期的脉冲来启动FPGA内部其他事件
//如果要实现的是按键按下为启动，松�?为停止，删除与keyvrr相关的所有语句，将全部keyvr换成keyv,以及output reg keyv
always@(posedge clk) begin
    if(rst)keyvrr<=0;
	else keyvrr<=keyvr;
end

assign  keyv=(~keyvrr)&keyvr;

endmodule