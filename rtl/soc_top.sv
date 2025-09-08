`include "config.h"
`include "iopad.svh"
module soc_top #(parameter SIMULATION=1'b0)
(
    input           clk,                //50MHz 时钟输入
    input           reset,              //BTN6手动复位按钮 ??????关，带消抖电 ??，按下时 ??1
    input           change_flag,

    //图像输出信号
    output [2:0]    video_red,          //红色像素 ??????3 ??????
    output [2:0]    video_green,        //绿色像素 ??????3 ??????
    output [1:0]    video_blue,         //蓝色像素 ??????2 ??????
    output          video_hsync,        //行同步（水平�? ? ）信 ????
    output          video_vsync,        //场同步（垂直�? ? ）信 ????
    output          video_clk,          //像素时钟输出
    output          video_de,           //行数 ??有效信号，用于区分消�? ????

    input           clock_btn,          //BTN5手动时钟按钮 ??????关，带消抖电 ??，按下时 ??1
    input  [3:0]    touch_btn,          //BTN1~BTN4，按 ?? ?关，按下时为1
    input  [31:0]   dip_sw,             //32位拨码开关，拨到“ON”时 ??????1
    output [15:0]   leds,               //16位LED，输出时1点亮
    output [7:0]    dpy,
    //ExtRAM信号
    inout  [31:0]   ram_data,       //ExtRAM数据
    output [19:0]   ram_addr,       //ExtRAM地址
    output [ 3:0]   ram_be_n,       //ExtRAM字节使能，低有效�? ? 果不使用字节使能，请保持 ????0
    output          ram_ce_n,       //ExtRAM�? ? ，低�? ??????
    output          ram_oe_n,       //ExtRAM读使能，低有 ??????
    output          ram_we_n,       //ExtRAM写使能，低有 ??????
	
	inout iic_0_scl,              
	inout iic_0_sda, 
	input I2S_ADCDAT,
	input I2S_ADCLRC,
	input I2S_BCLK,
    input uartrx,
	output I2S_DACDAT,
	input I2S_DACLRC,
	output I2S_MCLK,
    output cic_clk,

    //------uart-------
    inout           UART_RX,            //串口RX接收
    inout           UART_TX   
);
reg [31:0] ext_ram_data_i;
wire [31:0] ext_ram_data_o;
wire [19:0] ext_ram_addr_o;
wire [3:0] ext_ram_be_n_o;
wire ext_ram_ce_n_o;
wire ext_ram_oe_n_o;
wire ext_ram_we_n_o;

reg [31:0] base_ram_data_i;
wire [31:0] base_ram_data_o;
wire [19:0] base_ram_addr_o;
wire [3:0] base_ram_be_n_o;
wire base_ram_ce_n_o;
wire base_ram_oe_n_o;
wire base_ram_we_n_o;
wire [7:0] dpy0_o;
wire [7:0] dpy1_o;

wire cpu_clk;
wire cpu_resetn;
wire sys_clk;
wire sys_resetn;
wire [3:0] cpu_arid;
wire [31:0] cpu_araddr;
wire [7:0] cpu_arlen;
wire [2:0] cpu_arsize;
wire [1:0] cpu_arburst;
wire [0:0] cpu_arlock;
wire [3:0] cpu_arcache;
wire [2:0] cpu_arprot;
wire cpu_arvalid;
wire cpu_arready;

wire [3:0] cpu_rid;
wire [31:0] cpu_rdata;
wire [1:0] cpu_rresp;
wire cpu_rlast;
wire cpu_rvalid;
wire cpu_rready;

wire  [3:0] cpu_awid;
wire [31:0] cpu_awaddr;
wire  [7:0] cpu_awlen;
wire  [2:0] cpu_awsize;
wire  [1:0] cpu_awburst;
wire  [0:0] cpu_awlock;
wire  [3:0] cpu_awcache;
wire  [2:0] cpu_awprot;
wire cpu_awvalid;
wire cpu_awready;

wire  [3:0] cpu_wid;
wire  [31:0] cpu_wdata;
wire  [3:0] cpu_wstrb;
wire cpu_wlast;
wire cpu_wvalid;
wire cpu_wready;

wire [3:0] cpu_bid;
wire [1:0] cpu_bresp;
wire cpu_bvalid;
wire cpu_bready;
wire [31:0] debug_wb_pc;
wire [3:0] debug_wb_rf_wen;
wire [4:0] debug_wb_rf_wnum;
wire [31:0] debug_wb_rf_wdata;
wire [31:0] debug_wb_inst;

PX3W PAD_CLK_IN (.XIN(clk), .XOUT(clk_o), .XC(clk_i));
        `IPADU_GEN_SIMPLE(reset)
        `IPADU_GEN_SIMPLE(change_flag)
        `IPAD_GEN_VEC_SIMPLE(touch_btn)
        `OPAD_GEN_VEC_SIMPLE(leds)
        `OPAD_GEN_VEC_SIMPLE(dpy)
        `IOPAD_GEN_VEC_SIMPLE(ram_data)
        `OPAD_GEN_VEC_SIMPLE(ram_addr)
        `OPAD_GEN_VEC_SIMPLE(ram_be_n)
        `OPAD_GEN_SIMPLE(ram_ce_n)
        `OPAD_GEN_SIMPLE(ram_oe_n)
        `OPAD_GEN_SIMPLE(ram_we_n)
        `OPAD_GEN_VEC_SIMPLE(video_red)
        `OPAD_GEN_VEC_SIMPLE(video_green)
        `OPAD_GEN_VEC_SIMPLE(video_blue)
        `OPAD_GEN_SIMPLE(video_hsync)
        `OPAD_GEN_SIMPLE(video_vsync)
        `OPAD_GEN_SIMPLE(video_clk)
        `OPAD_GEN_SIMPLE(video_de)
        `IOPAD_GEN_SIMPLE(UART_RX)
        `IOPAD_GEN_SIMPLE(UART_TX)
        `IOPAD_GEN_SIMPLE(iic_0_scl)
        `IOPAD_GEN_SIMPLE(iic_0_sda)
        `IPAD_GEN_SIMPLE(I2S_ADCDAT)
        `IPAD_GEN_SIMPLE(I2S_ADCLRC)
        `IPAD_GEN_SIMPLE(I2S_BCLK)
        `IPAD_GEN_SIMPLE(uartrx)
        `OPAD_GEN_SIMPLE(I2S_DACDAT)
        `IPAD_GEN_SIMPLE(I2S_DACLRC)

always @(*) begin
    if(reset_i) begin
        dpy_o = 8'd0;
        base_ram_data_i = 32'd0;
        ext_ram_data_i  = 32'd0;
        ram_data_o      = 32'd0;
        ram_addr_o      = 20'd0;
        ram_be_n_o      = 1'd0;
        ram_ce_n_o      = 1'd0;
        ram_oe_n_o      = 1'd0;
        ram_we_n_o      = 1'd0;
    end
    else if(change_flag_i)begin
        dpy_o           = dpy1_o;
        base_ram_data_i = ram_data_i;
        ext_ram_data_i  = 32'd0;
        ram_data_o      = base_ram_data_o;
        ram_addr_o      = base_ram_addr_o;
        ram_be_n_o      = base_ram_be_n_o;
        ram_ce_n_o      = base_ram_ce_n_o;
        ram_oe_n_o      = base_ram_oe_n_o;
        ram_we_n_o      = base_ram_we_n_o;
    end
    else if(!change_flag_i)begin    
        dpy_o           = dpy0_o;
        base_ram_data_i = 32'd0;
        ext_ram_data_i  = ram_data_i;
        ram_data_o      = ext_ram_data_o;
        ram_addr_o      = ext_ram_addr_o;
        ram_be_n_o      = ext_ram_be_n_o;
        ram_ce_n_o      = ext_ram_ce_n_o;
        ram_oe_n_o      = ext_ram_oe_n_o;
        ram_we_n_o      = ext_ram_we_n_o;
    end
end

core_top u_cpu(//外部信号
    .intrpt ({7'h0,confreg_int}),
    .aclk (cpu_clk),
    .aresetn (cpu_resetn),
    //读地通道
    .arid (cpu_arid),
    .araddr (cpu_araddr),
    .arlen (cpu_arlen),
    .arsize (cpu_arsize),
    .arburst (cpu_arburst),
    .arlock (cpu_arlock),
    .arcache (cpu_arcache),
    .arprot (cpu_arprot),
    .arvalid (cpu_arvalid),
    .arready (cpu_arready),
    //读数 ?? ??? �?
    .rid (cpu_rid),
    .rdata (cpu_rdata),
    .rresp (cpu_rresp),
    .rlast (cpu_rlast),
    .rvalid (cpu_rvalid),
    .rready (cpu_rready),
    //写地 ??????通道
    .awid (cpu_awid),
    .awaddr (cpu_awaddr),
    .awlen (cpu_awlen),
    .awsize (cpu_awsize),
    .awburst (cpu_awburst),
    .awlock(cpu_awlock),
    .awcache (cpu_awcache),
    .awprot (cpu_awprot),
    .awvalid (cpu_awvalid),
    .awready (cpu_awready),
    //写数 ?? ??? �?
    .wid  (cpu_wid),
    .wdata (cpu_wdata),
    .wstrb (cpu_wstrb),
    .wlast (cpu_wlast),
    .wvalid (cpu_wvalid),
    .wready (cpu_wready),
    //写响�? ? �?
    .bid (cpu_bid),
    .bresp (cpu_bresp),
    .bvalid (cpu_bvalid),
    .bready (cpu_bready),
    //弃用
    .break_point (1'b0),
    .infor_flag (1'b0),
    .reg_num (5'b0),
    .ws_valid (),
    .rf_rdata (),
    //写回�? ? 提供的调试信 ????
    .debug0_wb_pc (debug_wb_pc),
    .debug0_wb_inst (debug_wb_inst),
    .debug0_wb_rf_wen (debug_wb_rf_wen),
    .debug0_wb_rf_wnum (debug_Wb_rf_wnum),
    .debug0_wb_rf_wdata (debug_wb_rf_wdata)
);
  wire axiOut_awvalid;
  wire axiOut_awready;
  wire [31:0] axiOut_awaddr;
  wire [3:0] axiOut_awid;
  wire [7:0] axiOut_awlen;
  wire [2:0] axiOut_awsize;
  wire [1:0] axiOut_awburst;
  wire [0:0] axiOut_awlock;
  wire [3:0] axiOut_awcache;
  wire [2:0] axiOut_awprot;
  wire axiOut_wvalid;
  wire axiOut_wready;
  wire [31:0] axiOut_wdata;
  wire [3:0] axiOut_wstrb;
  wire axiOut_wlast;
  wire axiOut_bvalid;
  wire axiOut_bready;
  wire [3:0] axiOut_bid;
  wire [1:0] axiOut_bresp;
  wire axiOut_arvalid;
  wire axiOut_arready;
  wire [31:0] axiOut_araddr;
  wire [3:0] axiOut_arid;
  wire [7:0] axiOut_arlen;
  wire [2:0] axiOut_arsize;
  wire [1:0] axiOut_arburst;
  wire [0:0] axiOut_arlock;
  wire [3:0] axiOut_arcache;
  wire [2:0] axiOut_arprot;
  wire axiOut_rvalid;
  wire axiOut_rready;
  wire [31:0] axiOut_rdata;
  wire [3:0] axiOut_rid;
  wire [1:0] axiOut_rresp;
  wire axiOut_rlast;

  Axi_CDC u_Axi_CDC(
    .axiInClk (cpu_clk), //i
    .axiInRst (cpu_resetn), //i
    .axiOutClk (sys_clk), //i
    .axiOutRst (sys_resetn), //i
    .axiIn_awvalid (cpu_awvalid), //i
    .axiIn_awready (cpu_awready), //o
    .axiIn_awaddr (cpu_awaddr), //i
    .axiIn_awid (cpu_awid), //i
    .axiIn_awlen (cpu_awlen), //i
    .axiIn_awsize (cpu_awsize), //i
    .axiIn_awburst (cpu_awburst), //i
    .axiIn_awlock (cpu_awlock), //i
    .axiIn_awcache (cpu_awcache), //i
    .axiIn_awprot (cpu_awprot), //i
    .axiIn_wvalid (cpu_wvalid), //i
    .axiIn_wready (cpu_wready), //o
    .axiIn_wdata (cpu_wdata), //i
    .axiIn_wstrb (cpu_wstrb), //i
    .axiIn_wlast (cpu_wlast), //i
    .axiIn_bvalid (cpu_bvalid), //o
    .axiIn_bready (cpu_bready), //i
    .axiIn_bid (cpu_bid), //o
    .axiIn_bresp (cpu_bresp), //o
    .axiIn_arvalid (cpu_arvalid), //i
    .axiIn_arready (cpu_arready), //o
    .axiIn_araddr (cpu_araddr), //i
    .axiIn_arid (cpu_arid), //i
    .axiIn_arlen (cpu_arlen), //i
    .axiIn_arsize (cpu_arsize), //i
    .axiIn_arburst (cpu_arburst), //i
    .axiIn_arlock (cpu_arlock), //i
    .axiIn_arcache (cpu_arcache), //i
    .axiIn_arprot (cpu_arprot), //i
    .axiIn_rvalid (cpu_rvalid), //o
    .axiIn_rready (cpu_rready), //i
    .axiIn_rdata (cpu_rdata), //o
    .axiIn_rid (cpu_rid), //o
    .axiIn_rresp (cpu_rresp), //o
    .axiIn_rlast (cpu_rlast), //o
    .axiOut_awvalid (axiOut_awvalid), //o
    .axiOut_awready (axiOut_awready), //i
    .axiOut_awaddr (axiOut_awaddr), //o
    .axiOut_awid (axiOut_awid), //o
    .axiOut_awlen (axiOut_awlen), //o
    .axiOut_awsize (axiOut_awsize), //o
    .axiOut_awburst (axiOut_awburst), //o
    .axiOut_awlock (axiOut_awlock), //o
    .axiOut_awcache (axiOut_awcache), //o
    .axiOut_awprot (axiOut_awprot), //o
    .axiOut_wvalid (axiOut_wvalid), //o
    .axiOut_wready (axiOut_wready), //i
    .axiOut_wdata (axiOut_wdata), //o
    .axiOut_wstrb (axiOut_wstrb), //o
    .axiOut_wlast (axiOut_wlast), //o
    .axiOut_bvalid (axiOut_bvalid), //i
    .axiOut_bready (axiOut_bready), //o
    .axiOut_bid (axiOut_bid), //i
    .axiOut_bresp (axiOut_bresp), //i 
    .axiOut_arvalid (axiOut_arvalid), //o
    .axiOut_arready (axiOut_arready), //i
    .axiOut_araddr (axiOut_araddr), //o
    .axiOut_arid (axiOut_arid), //o
    .axiOut_arlen (axiOut_arlen), //o
    .axiOut_arsize (axiOut_arsize), //o
    .axiOut_arburst (axiOut_arburst), //o
    .axiOut_arlock (axiOut_arlock), //o
    .axiOut_arcache (axiOut_arcache), //o
    .axiOut_arprot (axiOut_arprot), //o
    .axiOut_rvalid (axiOut_rvalid), //i
    .axiOut_rready (axiOut_rready), //o
    .axiOut_rdata (axiOut_rdata), //i
    .axiOut_rid (axiOut_rid), //i
    .axiOut_rresp (axiOut_rresp), //i
    .axiOut_rlast (axiOut_rlast) //i
    );

//连接SRAM
wire ram_awvalid;
wire ram_awready;
wire [31:0] ram_awaddr;
wire [4:0] ram_awid;
wire [7:0] ram_awlen;
wire [2:0] ram_awsize;
wire [1:0] ram_awburst;
wire [0:0] ram_awlock;
wire [3:0] ram_awcache;
wire [2:0] ram_awprot;
wire ram_wvalid;
wire ram_wready;
wire [3:0] ram_wstrb;
wire ram_wlast;
wire ram_bready;
wire ram_bvalid;
wire [4:0] ram_bid;
wire [1:0] ram_bresp;
wire ram_arvalid;
wire ram_arready;
wire [31:0] ram_araddr;
wire [4:0] ram_arid;
wire [7:0] ram_arlen;
wire [2:0] ram_arsize;
wire [1:0] ram_arburst;
wire [0:0] ram_arlock;
wire [3:0] ram_arcache;
wire [2:0] ram_arprot;
wire ram_rvalid;
wire ram_rready;
wire [4:0] ram_rid;
wire [1:0] ram_rresp;
wire ram_rlast;

//连接ram_dp缓冲模块
wire [31:0] ram_raddr;
wire [31:0] ram_rdata;
wire [31:0] ram_waddr;
wire [31:0] ram_wdata;

//AXI2APB链接UART
wire uart_awvalid;
wire uart_awready;
wire [31:0] uart_awaddr;
wire [4:0] uart_awid;
wire [7:0] uart_awlen;
wire [2:0] uart_awsize;
wire [1:0] uart_awburst;
wire [0:0] uart_awlock;
wire [3:0] uart_awcache;
wire [2:0] uart_awprot;
wire uart_wvalid;
wire uart_wready;
wire [31:0] uart_wdata;
wire [3:0] uart_wstrb;
wire uart_wlast;
wire uart_bready;
wire uart_bvalid;
wire [4:0] uart_bid;
wire [1:0] uart_bresp;
wire uart_arvalid;
wire uart_arready;
wire [31:0] uart_araddr;
wire [4:0] uart_arid;
wire [7:0] uart_arlen;
wire [2:0] uart_arsize;
wire [1:0] uart_arburst;
wire [0:0] uart_arlock;
wire [3:0] uart_arcache;
wire [2:0] uart_arprot;
wire uart_rvalid;
wire uart_rready;
wire [31:0] uart_rdata;
wire [4:0] uart_rid;
wire [1:0] uart_rresp;
wire uart_rlast;

//连接�? ??
wire [4:0] confreg_awid;
wire [31:0] confreg_awaddr;
wire [7:0] confreg_awlen;
wire [2:0] confreg_awsize;
wire [1:0] confreg_awburst;
wire [0:0] confreg_awlock;
wire [3:0] confreg_awcache;
wire [2:0] confreg_awprot;
wire confreg_awvalid;
wire confreg_awready;
//wire [4:0] confreg_wid;
wire [31:0] confreg_wdata;
wire [3:0] confreg_wstrb;
wire confreg_wlast;
wire confreg_wready;
wire confreg_wvalid;
wire [4:0] confreg_bid;
wire [1:0] confreg_bresp;
wire confreg_bvalid;
wire confreg_bready;
wire [4:0] confreg_arid;
wire [31:0] confreg_araddr;
wire [7:0] confreg_arlen;
wire [2:0] confreg_arsize;
wire [1:0] confreg_arburst;
wire [0:0] confreg_arlock;
wire [3:0] confreg_arcache;
wire [2:0] confreg_arprot;
wire confreg_arvalid;
wire confreg_arready;
wire [4:0] confreg_rid;
wire [31:0] confreg_rdata;
wire [1:0] confreg_rresp;
wire confreg_rlast;
wire confreg_rvalid;
wire confreg_rready;

wire au_awvalid;
wire au_awready;
wire [31:0] au_awaddr;
wire [4:0] au_awid;
wire [7:0] au_awlen;
wire [2:0] au_awsize;
wire [1:0] au_awburst;
wire [0:0] au_awlock;
wire [3:0] au_awcache;
wire [2:0] au_awprot;
wire au_wvalid;
wire au_wready;
wire [31:0] au_wdata;
wire [3:0] au_wstrb;
wire au_wlast;
wire au_bready;
wire au_bvalid;
wire [4:0] au_bid;
wire [1:0] au_bresp;
wire au_arvalid;
wire au_arready;
wire [31:0] au_araddr;
wire [4:0] au_arid;
wire [7:0] au_arlen;
wire [2:0] au_arsize;
wire [1:0] au_arburst;
wire [0:0] au_arlock;
wire [3:0] au_arcache;
wire [2:0] au_arprot;
wire au_rvalid;
wire au_rready;
wire [31:0] au_rdata;
wire [4:0] au_rid;
wire [1:0] au_rresp;
wire au_rlast;
/* ??连接�? ???(Dummy Slave)
wire axiOut_2_arready;
wire axiOut_2_rid;
wire axiOut_2_rdata;
wire axiOut_2_rresp;
wire axiOut_2_rlast;
wire axiOut_2_rvalid;
wire axiOut_2_awready;
wire axiOut_2_wready;
wire axiOut_2_bid;
wire axiOut_2_bresp;
wire axiOut_2_bvalid;
//避免出现X�? ??
assign axiOut_2_arready = 1'b1;
assign axiOut_2_rid = 5'b0;
assign axiOut_2_rdata = 32'b0;
assign axiOut_2_rresp = 2'b0;
assign axiOut_2_rlast = 1'b0;
assign axiOut_2_rvalid = 1'b0;
assign axiOut_2_awready = 1'b1;
assign axiOut_2_wready = 1'b1;
assign axiOut_2_bid = 5'b0;
assign axiOut_2_bresp = 2'b0;
assign axiOut_2_bvalid = 1'b0;
*/
wire [17:0] fpga_sram_address;
wire [31:0] fpga_sram_raddr;
wire [31:0] fpga_sram_waddr;
wire [3:0] fpga_sram_wen;
wire [31:0] fpga_sram_wdata;
wire [31:0] fpga_sram_rdata;
wire [31:0] m_araddr;
wire [1:0] m_arburst;
wire [3:0] m_arcache;
wire [4:0] m_arid;
wire [7:0] m_arlen;
wire [1:0] m_arlock;
wire [2:0] m_arprot;
wire m_arready;
wire [2:0] m_arsize;
wire m_arvalid;
wire [31:0] m_awaddr;
wire [1:0] m_awburst;
wire [3:0] m_awcache;
wire [4:0] m_awid;
wire [7:0] m_awlen;
wire [1:0] m_awlock;
wire [2:0] m_awprot;
wire m_awready;
wire [2:0] m_awsize;
wire m_awvalid;
wire [4:0] m_bid;
wire m_bready;
wire [1:0] m_bresp;
wire m_bvalid;
wire [31:0] m_rdata;
wire [4:0] m_rid;
wire m_rlast;
wire m_rready;
wire [1:0] m_rresp;
wire m_rvalid;
wire [31:0] m_wdata;
wire m_wlast;
wire m_wready;
wire [3:0] m_wstrb;
wire m_wvalid;
AxiCrossbar_1x5 u_AxiCrossbar_1x5(
    .clk (sys_clk),
    .resetn (sys_resetn),

    //aw
    .axiIn_awvalid (axiOut_awvalid),
    .axiIn_awready (axiOut_awready),
    .axiIn_awaddr (axiOut_awaddr),
    .axiIn_awid (axiOut_awid),
    .axiIn_awlen (axiOut_awlen),
    .axiIn_awsize (axiOut_awsize),
    .axiIn_awburst (axiOut_awburst),
    .axiIn_awlock (axiOut_awlock),
    .axiIn_awcache (axiOut_awcache),
    .axiIn_awprot (axiOut_awprot),
    //w
    .axiIn_wvalid (axiOut_wvalid),
    .axiIn_wready (axiOut_wready),
    .axiIn_wdata (axiOut_wdata),
    .axiIn_wstrb (axiOut_wstrb),
    .axiIn_wlast (axiOut_wlast),
    //b
    .axiIn_bready (axiOut_bready),
    .axiIn_bvalid (axiOut_bvalid),
    .axiIn_bid (axiOut_bid),
    .axiIn_bresp (axiOut_bresp),
    //ar
    .axiIn_arvalid (axiOut_arvalid),
    .axiIn_arready (axiOut_arready),
    .axiIn_araddr (axiOut_araddr),
    .axiIn_arid (axiOut_arid),
    .axiIn_arlen (axiOut_arlen),
    .axiIn_arsize (axiOut_arsize),
    .axiIn_arburst (axiOut_arburst),
    .axiIn_arlock (axiOut_arlock),
    .axiIn_arcache (axiOut_arcache),
    .axiIn_arprot (axiOut_arprot),
    .axiIn_rvalid (axiOut_rvalid),
    .axiIn_rready (axiOut_rready),
    .axiIn_rdata (axiOut_rdata),
    .axiIn_rid (axiOut_rid),
    .axiIn_rresp (axiOut_rresp),
    .axiIn_rlast (axiOut_rlast),
    //aw0
    .axiOut_0_awvalid (ram_awvalid),
    .axiOut_0_awready (ram_awready),
    .axiOut_0_awaddr (ram_awaddr),
    .axiOut_0_awid (ram_awid),
    .axiOut_0_awlen (ram_awlen),
    .axiOut_0_awsize (ram_awsize),
    .axiOut_0_awburst (ram_awburst),
    .axiOut_0_awlock (ram_awlock),
    .axiOut_0_awcache (ram_awcache),
    .axiOut_0_awprot (ram_awprot),
    //w0
    .axiOut_0_wvalid (ram_wvalid),
    .axiOut_0_wready (ram_wready),
    .axiOut_0_wdata (ram_wdata),
    .axiOut_0_wstrb (ram_wstrb),
    .axiOut_0_wlast (ram_wlast),
    //b0
    .axiOut_0_bready (ram_bready),
    .axiOut_0_bvalid (ram_bvalid),
    .axiOut_0_bid (ram_bid),
    .axiOut_0_bresp (ram_bresp),
    //ar0
    .axiOut_0_arvalid (ram_arvalid),
    .axiOut_0_arready (ram_arready),
    .axiOut_0_araddr (ram_araddr),
    .axiOut_0_arid (ram_arid),
    .axiOut_0_arlen (ram_arlen),
    .axiOut_0_arsize (ram_arsize),
    .axiOut_0_arburst (ram_arburst),
    .axiOut_0_arlock(ram_arlock),
    .axiOut_0_arcache (ram_arcache),
    .axiOut_0_arprot (ram_arprot),
    //r0
    .axiOut_0_rvalid (ram_rvalid),
    .axiOut_0_rready (ram_rready),
    .axiOut_0_rdata (ram_rdata),
    .axiOut_0_rid (ram_rid),
    .axiOut_0_rresp (ram_rresp),
    .axiOut_0_rlast (ram_rlast),
    //aw1
    .axiOut_1_awvalid (uart_awvalid),
    .axiOut_1_awready (uart_awready),
    .axiOut_1_awaddr (uart_awaddr),
    .axiOut_1_awid (uart_awid),
    .axiOut_1_awlen (uart_awlen),
    .axiOut_1_awsize (uart_awsize),
    .axiOut_1_awburst (uart_awburst),
    .axiOut_1_awlock (uart_awlock),
    .axiOut_1_awcache (uart_awcache),
    .axiOut_1_awprot (uart_awprot),
    //w1
    .axiOut_1_wvalid (uart_wvalid),
    .axiOut_1_wready (uart_wready),
    .axiOut_1_wdata (uart_wdata),
    .axiOut_1_wstrb (uart_wstrb),
    .axiOut_1_wlast (uart_wlast),
    //b1
    .axiOut_1_bready (uart_bready),
    .axiOut_1_bvalid (uart_bvalid),
    .axiOut_1_bid (uart_bid),
    .axiOut_1_bresp (uart_bresp),
    //ar1
    .axiOut_1_arvalid (uart_arvalid),
    .axiOut_1_arready (uart_arready),
    .axiOut_1_araddr (uart_araddr),
    .axiOut_1_arid (uart_arid),
    .axiOut_1_arlen (uart_arlen),
    .axiOut_1_arsize (uart_arsize),
    .axiOut_1_arburst (uart_arburst),
    .axiOut_1_arlock(uart_arlock),
    .axiOut_1_arcache (uart_arcache),
    .axiOut_1_arprot (uart_arprot),
    //r1
    .axiOut_1_rvalid (uart_rvalid),
    .axiOut_1_rready (uart_rready),
    .axiOut_1_rdata (uart_rdata),
    .axiOut_1_rid (uart_rid),
    .axiOut_1_rresp (uart_rresp),
    .axiOut_1_rlast (uart_rlast),
    //aw2
    .axiOut_2_awvalid (m_awvalid),
    .axiOut_2_awready (m_awready),
    .axiOut_2_awaddr (m_awaddr),
    .axiOut_2_awid (m_awid),
    .axiOut_2_awlen (m_awlen),
    .axiOut_2_awsize (m_awsize),
    .axiOut_2_awburst (m_awburst),
    .axiOut_2_awlock (m_awlock),
    .axiOut_2_awcache (m_awcache),
    .axiOut_2_awprot (m_awprot),
    //w2
    .axiOut_2_wvalid (m_wvalid),
    .axiOut_2_wready (m_wready),
    .axiOut_2_wdata (m_wdata),
    .axiOut_2_wstrb (m_wstrb),
    .axiOut_2_wlast (m_wlast),
    //b2
    .axiOut_2_bready (m_bready),
    .axiOut_2_bvalid (m_bvalid),
    .axiOut_2_bid (m_bid),
    .axiOut_2_bresp (m_bresp),
    //ar2
    .axiOut_2_arvalid (m_arvalid),
    .axiOut_2_arready (m_arready),
    .axiOut_2_araddr (m_araddr),
    .axiOut_2_arid (m_arid),
    .axiOut_2_arlen (m_arlen),
    .axiOut_2_arsize (m_arsize),
    .axiOut_2_arburst (m_arburst),
    .axiOut_2_arlock(m_arlock),
    .axiOut_2_arcache (m_arcache),
    .axiOut_2_arprot (m_arprot),
    //r2
    .axiOut_2_rvalid (m_rvalid),
    .axiOut_2_rready (m_rready),
    .axiOut_2_rdata (m_rdada),
    .axiOut_2_rid (m_rid),
    .axiOut_2_rresp (m_rresp),
    .axiOut_2_rlast (m_rlast),
    //aw3
    .axiOut_3_awvalid (confreg_awvalid),
    .axiOut_3_awready (confreg_awready),
    .axiOut_3_awaddr (confreg_awaddr),
    .axiOut_3_awid (confreg_awid),
    .axiOut_3_awlen (confreg_awlen),
    .axiOut_3_awsize (confreg_awsize),
    .axiOut_3_awburst (confreg_awburst),
    .axiOut_3_awlock (confreg_awlock),
    .axiOut_3_awcache (confreg_awcache),
    .axiOut_3_awprot (confreg_awprot),
    //w3
    .axiOut_3_wvalid (confreg_wvalid),
    .axiOut_3_wready (confreg_wready),
    .axiOut_3_wdata (confreg_wdata),
    .axiOut_3_wstrb (confreg_wstrb),
    .axiOut_3_wlast (confreg_wlast),
    //b3
    .axiOut_3_bready (confreg_bready),
    .axiOut_3_bvalid (confreg_bvalid),
    .axiOut_3_bid (confreg_bid),
    .axiOut_3_bresp (confreg_bresp),
    //ar3
    .axiOut_3_arvalid (confreg_arvalid),
    .axiOut_3_arready (confreg_arready),
    .axiOut_3_araddr (confreg_araddr),
    .axiOut_3_arid (confreg_arid),
    .axiOut_3_arlen (confreg_arlen),
    .axiOut_3_arsize (confreg_arsize),
    .axiOut_3_arburst (confreg_arburst),
    .axiOut_3_arlock(confreg_arlock),
    .axiOut_3_arcache (confreg_arcache),
    .axiOut_3_arprot (confreg_arprot),
    //r3
    .axiOut_3_rvalid (confreg_rvalid),
    .axiOut_3_rready (confreg_rready),
    .axiOut_3_rdata (confreg_rdata),
    .axiOut_3_rid (confreg_rid),
    .axiOut_3_rresp (confreg_rresp),
    .axiOut_3_rlast (confreg_rlast),
	//aw3
    .axiOut_4_awvalid ( au_awvalid),
    .axiOut_4_awready ( au_awready),
    .axiOut_4_awaddr ( au_awaddr),
    .axiOut_4_awid ( au_awid),
    .axiOut_4_awlen ( au_awlen),
    .axiOut_4_awsize ( au_awsize),
    .axiOut_4_awburst ( au_awburst),
    .axiOut_4_awlock (au_awlock),
    .axiOut_4_awcache ( au_awcache),
    .axiOut_4_awprot ( au_awprot),
    //w3
    .axiOut_4_wvalid ( au_wvalid),
    .axiOut_4_wready ( au_wready),
    .axiOut_4_wdata ( au_wdata),
    .axiOut_4_wstrb ( au_wstrb),
    .axiOut_4_wlast ( au_wlast),
    //b3
    .axiOut_4_bready ( au_bready),
    .axiOut_4_bvalid ( au_bvalid),
    .axiOut_4_bid ( au_bid),
    .axiOut_4_bresp ( au_bresp),
    //ar3
    .axiOut_4_arvalid ( au_arvalid),
    .axiOut_4_arready ( au_arready),
    .axiOut_4_araddr ( au_araddr),
    .axiOut_4_arid ( au_arid),
    .axiOut_4_arlen ( au_arlen),
    .axiOut_4_arsize ( au_arsize),
    .axiOut_4_arburst ( au_arburst),
    .axiOut_4_arlock( au_arlock),
    .axiOut_4_arcache ( au_arcache),
    .axiOut_4_arprot ( au_arprot),
    //r3
    .axiOut_4_rvalid ( au_rvalid),
    .axiOut_4_rready ( au_rready),
    .axiOut_4_rdata ( au_rdata),
    .axiOut_4_rid ( au_rid),
    .axiOut_4_rresp ( au_rresp),
    .axiOut_4_rlast ( au_rlast)
);
//***************************************************
// 1. 定义 au_csr 寄存器（1位）
reg au_csr;

// 2. 定义寄存器地址常量
localparam AU_CSR_ADDR = 32'h0000_FFFF;

// 3. AXI 控制信号寄存器
reg aw_flag;   // 写地址接收标志
reg w_flag;    // 写数据接收标志
reg ar_flag;   // 读地址接收标志
reg [4:0] aw_id_saved;  // 保存写ID
reg [4:0] ar_id_saved;  // 保存读ID

// 4. 读数据寄存器
reg [31:0] au_rdata_reg;

// 5. 主控制逻辑（同步低电平复位）
always @(posedge sys_clk) begin
    if (!sys_resetn) begin
        // 同步复位
        au_csr <= 1'b0;
        aw_flag <= 1'b0;
        w_flag <= 1'b0;
        ar_flag <= 1'b0;
        aw_id_saved <= 5'b0;
        ar_id_saved <= 5'b0;
        au_rdata_reg <= 32'b0;
    end else begin
        // 写地址通道处理
        if (au_awvalid && au_awready) begin
            aw_flag <= 1'b1;
            aw_id_saved <= au_awid;
        end else if (au_bvalid && au_bready) begin
            aw_flag <= 1'b0;
        end
        
        // 写数据通道处理
        if (au_wvalid && au_wready) begin
            w_flag <= 1'b1;
            if ((au_awaddr == AU_CSR_ADDR) && au_wstrb[0]) begin
                au_csr <= au_wdata[0]; // 只更新最低位
            end
        end else if (au_bvalid && au_bready) begin
            w_flag <= 1'b0;
        end
        
        // 读地址通道处理
        if (au_arvalid && au_arready) begin
            ar_flag <= 1'b1;
            ar_id_saved <= au_arid;
            if (au_araddr == AU_CSR_ADDR) begin
                au_rdata_reg <= {31'b0, au_csr}; // 扩展为32位
            end else begin
                au_rdata_reg <= 32'b0; // 非目标地址返回0
            end
        end else if (au_rvalid && au_rready) begin
            ar_flag <= 1'b0;
        end
    end
end

// 6. AXI 响应信号生成
assign au_bvalid = aw_flag && w_flag;    // 写响应有效
assign au_bresp = 2'b00;                 // OKAY响应
assign au_bid = aw_id_saved;             // 返回保存的ID

assign au_rvalid = ar_flag;              // 读数据有效
assign au_rdata = au_rdata_reg;          // 读数据
assign au_rresp = 2'b00;                 // OKAY响应
assign au_rlast = 1'b1;                  // 单次传输
assign au_rid = ar_id_saved;             // 返回保存的ID

// 7. AXI 就绪信号生成（流控）
assign au_awready = ~aw_flag;            // 空闲时可接收写地址
assign au_wready = ~w_flag;              // 空闲时可接收写数据
assign au_arready = ~ar_flag;            // 空闲时可接收读地址

audio_lookback audioUNIT(
.clk(sys_clk),                    
.reset_n(sys_resetn), 
.iic_0_scl_i(iic_0_scl_i),   
.iic_0_scl_o (iic_0_scl_o),           
.iic_0_sda_i(iic_0_sda_i),  
.iic_0_sda_o(iic_0_sda_o),
.en(au_csr),
        
.I2S_ADCDAT(I2S_ADCDAT_i),
.I2S_ADCLRC(I2S_ADCLRC_i),
.I2S_BCLK(I2S_BCLK_i),
.uart_rx(uartrx_i),
.I2S_DACDAT(I2S_DACDAT_o),
.I2S_DACLRC(I2S_DACLRC_i),
.I2S_MCLK(I2S_MCLK_o),
.cic_clk(cic_clk_o)
);
//***************************************************
  axi_wrap_ram_sp_ext u_axi_ram(
    .aclk (sys_clk),
    .aresetn (sys_resetn),
    //ar
    .axi_arid (ram_arid),
    .axi_araddr (ram_araddr),
    .axi_arlen (ram_arlen),
    .axi_arsize (ram_arsize),
    .axi_arburst (ram_arburst),
    .axi_arlock (ram_arlock),
    .axi_arcache (ram_arcache),
    .axi_arprot (ram_arprot),
    .axi_arvalid (ram_arvalid),
    .axi_arready (ram_arready),
    //r
    .axi_rid (ram_rid),
    .axi_rdata (ram_rdata),
    .axi_rresp (ram_rresp),
    .axi_rlast (ram_rlast),
    .axi_rvalid (ram_rvalid),
    .axi_rready (ram_rready),
    //aw
    .axi_awid (ram_awid),
    .axi_awaddr (ram_awaddr),
    .axi_awlen (ram_awlen),
    .axi_awsize (ram_awsize),
    .axi_awburst (ram_awburst),
    .axi_awlock (ram_awlock),
    .axi_awcache (ram_awcache),
    .axi_awprot (ram_awprot),
    .axi_awvalid (ram_awvalid),
    .axi_awready (ram_awready),
    //w
    .axi_wdata (ram_wdata),
    .axi_wstrb (ram_wstrb),
    .axi_wlast (ram_wlast),
    .axi_wvalid (ram_wvalid),
    .axi_wready (ram_wready),
    //b
    .axi_bid (ram_bid),
    .axi_bresp (ram_bresp),
    .axi_bvalid (ram_bvalid),
    .axi_bready (ram_bready),
    .base_ram_addr (base_ram_addr_o), //??
    .base_ram_be_n (base_ram_be_n_o),
    .base_ram_ce_n (base_ram_ce_n_o),
    .base_ram_oe_n (base_ram_oe_n_o),
    .base_ram_we_n (base_ram_we_n_o),
    .ext_ram_addr (ext_ram_addr_o),
    .ext_ram_be_n (ext_ram_be_n_o),
    .ext_ram_ce_n (ext_ram_ce_n_o),
    .ext_ram_oe_n (ext_ram_oe_n_o),
    .ext_ram_we_n (ext_ram_we_n_o),

    .base_ram_data_i (base_ram_data_i),
    .base_ram_data_o (base_ram_data_o),
    .base_ram_data_oe (),
    .ext_ram_data_i  (ext_ram_data_i),
    .ext_ram_data_o  (ext_ram_data_o),
    .ext_ram_data_oe ()
  );

    axi_wrap_ram_dp u_axi_wrap_ram_dp(
    .aclk(sys_clk),
    .aresetn(sys_resetn),
    .axi_arid(m_arid),
    .axi_araddr(m_araddr),
    .axi_arlen(m_arlen),
    .axi_arsize(m_arsize),
    .axi_arburst(m_arburst),
    .axi_arlock(m_arlock),
    .axi_arcache(m_arcache),
    .axi_arprot(m_arprot),
    .axi_arvalid(m_arvalid),
    .axi_arready(m_arready),
    
    .axi_rid(m_rid),
    .axi_rdata(m_rdata),
    .axi_rresp(m_rresp),
    .axi_rlast(m_rlast),
    .axi_rvalid(m_rvalid),
    .axi_rready(m_rready),
    
    .axi_awid(m_awid),
    .axi_awaddr(m_awaddr),
    .axi_awlen(m_awlen),
    .axi_awsize(m_awsize),
    .axi_awburst(m_awburst),
    .axi_awlock(m_awlock),
    .axi_awcache(m_awcache),
    .axi_awprot(m_awprot),
    .axi_awvalid(m_awvalid),
    .axi_awready(m_awready),
    
    .axi_wdata(m_wdata),
    .axi_wstrb(m_wstrb),
    .axi_wlast(m_wlast),
    .axi_wvalid(m_wvalid),
    .axi_wready(m_wready),
    
    .axi_bid(m_bid),
    .axi_bresp(m_bresp),
    .axi_bvalid(m_bvalid),
    .axi_bready(m_bready),
	
	.dip_sw(dip_sw_i[7:0]),
	.vsync(video_vsync_o),
	.hsync(video_hsync_o),
	.de(video_de_o),
	.r(video_red_o),
	.g(video_green_o),
	.b(video_blue_o)
    );
	assign video_clk=sys_clk;

wire UART_CTS, UART_RTS;
wire UART_DIR, UART_DSR;
wire UART_RI, UART_DCD;
assign UART_CTS = 1'b0;
assign UART_DSR = 1'b0;
assign UART_DCD = 1'b0;
assign UART_RI = 1'b0;
wire uart0_int;
wire uart0_txd_o;
wire uart0_txd_i;
wire uart0_txd_oe;
wire uart0_rxd_o;
wire uart0_rxd_i;
wire uart0_rxd_oe;
wire uart0_rts_o;
wire uart0_cts_i;
wire uart0_dsr_i;
wire uart0_dcd_i;
wire uart0_dtr_o;
wire uart0_ri_i;
assign UART_RX = uart0_rxd_oe? 1'bz:uart0_rxd_o;
assign UART_TX = uart0_txd_oe? 1'bz:uart0_txd_o;
assign UART_RTS = uart0_rts_o;
assign UART_DTR = uart0_dtr_o;
assign uart0_txd_i = UART_TX;
assign uart0_rxd_i = UART_RX;
assign uart0_cts_i = UART_CTS;
assign uart0_dcd_i = UART_DCD;
assign uart0_dsr_i = UART_DSR;
assign uart0_ri_i = UART_RI;

//UART_CONTROLLER
axi_uart_controller u_axi_uart_controller
(
    .clk (sys_clk),
    .rst_n (sys_resetn),
    .axi_s_awid (uart_awid),
    .axi_s_awaddr (uart_awaddr),
    .axi_s_awlen (uart_awlen),
    .axi_s_awsize (uart_awsize),
    .axi_s_awburst (uart_awburst),
    .axi_s_awlock (uart_awlock),
    .axi_s_awcache (uart_awcache),
    .axi_s_awprot (uart_awprot),
    .axi_s_awvalid (uart_awvalid),
    .axi_s_awready (uart_awready),
    .axi_s_wid ('h0),
    .axi_s_wdata (uart_wdata),
    .axi_s_wstrb (uart_wstrb),
    .axi_s_wlast (uart_wlast),
    .axi_s_wvalid (uart_wvalid),
    .axi_s_wready (uart_wready),
    .axi_s_bid (uart_bid),
    .axi_s_bresp (uart_bresp),
    .axi_s_bvalid (uart_bvalid),
    .axi_s_bready (uart_bready),
    .axi_s_arid (uart_arid),
    .axi_s_araddr (uart_araddr),
    .axi_s_arlen (uart_arlen),
    .axi_s_arsize (uart_arsize),
    .axi_s_arburst (uart_arburst),
    .axi_s_arlock (uart_arlock),
    .axi_s_arcache (uart_arcache),
    .axi_s_arprot (uart_arprot),
    .axi_s_arvalid (uart_arvalid),
    .axi_s_arready (uart_arready),
    .axi_s_rid (uart_rid),
    .axi_s_rdata (uart_rdata),
    .axi_s_rresp (uart_rresp),
    .axi_s_rlast (uart_rlast),
    .axi_s_rvalid (uart_rvalid),
    .axi_s_rready (uart_rready),

    .apb_rw_dma (1'b0),
    .apb_psel_dma (1'b0),
    .apb_enab_dma (1'b0),
    .apb_addr_dma (20'b0),
    .apb_valid_dma (1'b0),
    .apb_wdata_dma (32'b0),
    .apb_rdata_dma (),
    .apb_ready_dma (),
    .dma_grant (),
    .dma_req_o (),
    .dma_ack_i (1'b0),

    //UART0
    .uart0_txd_i (uart0_txd_i),
    .uart0_txd_o (uart0_txd_o),
    .uart0_txd_oe (uart0_txd_oe),
    .uart0_rxd_i (uart0_rxd_i),
    .uart0_rxd_o (uart0_rxd_o),
    .uart0_rxd_oe (uart0_rxd_oe),
    .uart0_rts_o (uart0_rts_o),
    .uart0_dtr_o (uart0_dtr_o),
    .uart0_cts_i (uart0_cts_i),
    .uart0_dsr_i (uart0_dsr_i),
    .uart0_dcd_i (uart0_dcd_i),
    .uart0_ri_i (uart0_ri_i),
    .uart0_int (uart0_int)
);

confreg #(.SIMULATION(SIMULATION)) u_confreg(
    .aclk (sys_clk),
    .aresetn (sys_resetn),
    .cpu_clk (cpu_clk),
    .cpu_resetn (cpu_resetn),
    .s_awid (confreg_awid),
    .s_awaddr (confreg_awaddr),
    .s_awlen (confreg_awlen),
    .s_awsize (confreg_awsize),
    .s_awburst (confreg_awburst),
    .s_awlock (confreg_awlock),
    .s_awcache (confreg_awcache),
    .s_awprot (confreg_awprot),
    .s_awvalid (confreg_awvalid),
    .s_wid ('h0),
    .s_wdata (confreg_wdata),
    .s_wstrb (confreg_wstrb),
    .s_wlast (confreg_wlast),
    .s_wvalid (confreg_wvalid),
    .s_bready (confreg_bready),
    .s_arid (confreg_arid),
    .s_araddr (confreg_araddr),
    .s_arlen (confreg_arlen),
    .s_arsize (confreg_arsize),
    .s_arburst (confreg_arburst),
    .s_arlock (confreg_arlock),
    .s_arcache (confreg_arcache),
    .s_arprot (confreg_arprot),
    .s_arvalid (confreg_arvalid),
    .s_rready (confreg_rready),

    .s_awready (confreg_awready),
    .s_wready (confreg_wready),
    .s_bid (confreg_bid),
    .s_bresp (confreg_bresp),
    .s_bvalid (confreg_bvalid),
    .s_arready (confreg_arready),
    .s_rid (confreg_rid),
    .s_rdata (confreg_rdata),
    .s_rresp (confreg_rresp),
    .s_rlast (confreg_rlast),
    .s_rvalid (confreg_rvalid),

    .switch (dip_sw_i),
    .touch_btn (touch_btn_i),
    .led (leds_o),
    .dpy0 (dpy0_o),
    .dpy1 (dpy1_o),
    .confreg_int (confreg_int)
    );

assign cpu_clk = clk_i;
assign sys_clk = clk_i;
rst_sync u_rst_sys(
    .clk(sys_clk),
    .rst_n_in(~reset_i),
    .rst_n_out(sys_resetn)
);
rst_sync u_rst_cpu(
    .clk(cpu_clk),
    .rst_n_in(sys_resetn),
    .rst_n_out(cpu_resetn)
);



//TODO: add your code

endmodule

