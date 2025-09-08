module axi_wrap_ram_dp #(
    parameter Init_File = "none"
)
(
  input         aclk,
  input         aresetn,
  //ar
  input  [4 :0] axi_arid   ,
  input  [31:0] axi_araddr ,
  input  [7 :0] axi_arlen  ,
  input  [2 :0] axi_arsize ,
  input  [1 :0] axi_arburst,
  input  [0 :0] axi_arlock ,
  input  [3 :0] axi_arcache,
  input  [2 :0] axi_arprot ,
  input         axi_arvalid,
  output        axi_arready,
  //r
  output [4 :0] axi_rid    ,
  output [31:0] axi_rdata  ,
  output [1 :0] axi_rresp  ,
  output        axi_rlast  ,
  output        axi_rvalid ,
  input         axi_rready ,
  //aw
  input  [4 :0] axi_awid   ,
  input  [31:0] axi_awaddr ,
  input  [7 :0] axi_awlen  ,
  input  [2 :0] axi_awsize ,
  input  [1 :0] axi_awburst,
  input  [0 :0] axi_awlock ,
  input  [3 :0] axi_awcache,
  input  [2 :0] axi_awprot ,
  input         axi_awvalid,
  output        axi_awready,
  //w
  input  [31:0] axi_wdata  ,
  input  [3 :0] axi_wstrb  ,
  input         axi_wlast  ,
  input         axi_wvalid ,
  output        axi_wready ,
  //b
  output [4 :0] axi_bid    ,
  output [1 :0] axi_bresp  ,
  output        axi_bvalid ,
  input         axi_bready ,
  
  
  /*output [17:0] fpga_sram_address,
  output [31:0] fpga_sram_raddr,
  output [31:0] fpga_sram_rdata,
  output [31:0] fpga_sram_waddr,
  output [3:0] fpga_sram_wen,
  output [31:0] fpga_sram_wdata,
  output        fpga_sram_ren,*/
  
  input[7:0]    dip_sw,
  output		vsync,
  output		hsync,
  output		de,
  output[2:0]	r,
  output[2:0]	g,
  output[1:0]	b
);


//ram axi
//ar
wire [4 :0] ram_arid   ;
wire [31:0] ram_araddr ;
wire [7 :0] ram_arlen  ;
wire [2 :0] ram_arsize ;
wire [1 :0] ram_arburst;
wire [1 :0] ram_arlock ;
wire [3 :0] ram_arcache;
wire [2 :0] ram_arprot ;
wire        ram_arvalid;
wire        ram_arready;
//r
wire [4 :0] ram_rid    ;
wire [31:0] ram_rdata  ;
wire [1 :0] ram_rresp  ;
wire        ram_rlast  ;
wire        ram_rvalid ;
wire        ram_rready ;
//aw
wire [4 :0] ram_awid   ;
wire [31:0] ram_awaddr ;
wire [7 :0] ram_awlen  ;
wire [2 :0] ram_awsize ;
wire [1 :0] ram_awburst;
wire [1 :0] ram_awlock ;
wire [3 :0] ram_awcache;
wire [2 :0] ram_awprot ;
wire        ram_awvalid;
wire        ram_awready;
//w
wire [31:0] ram_wdata  ;
wire [3 :0] ram_wstrb  ;
wire        ram_wlast  ;
wire        ram_wvalid ;
wire        ram_wready ;
//b
wire [4 :0] ram_bid    ;
wire [1 :0] ram_bresp  ;
wire        ram_bvalid ;
wire        ram_bready ;

//sram signal
wire  [31:0]    fpga_sram_raddr;
wire  [31:0]    fpga_sram_rdata;
reg            fpga_sram_ren;
wire  [31:0]    fpga_sram_waddr;
wire  [31:0]    fpga_sram_wdata;
wire  [3:0]     fpga_sram_wen;
wire  [17:0]    fpga_sram_address;

//wire		threshadd,threshsub;
wire		vsync;
wire		hsync;
wire		de;
wire[2:0]	r;
wire[2:0]	g;
wire[1:0]	b;


//ar
assign fpga_sram_address = fpga_sram_waddr[10:2];
assign ram_arid    = axi_arid   ;
assign ram_araddr  = axi_araddr ;
assign ram_arlen   = axi_arlen  ;
assign ram_arsize  = axi_arsize ;
assign ram_arburst = axi_arburst;
assign ram_arlock  = axi_arlock ;
assign ram_arcache = axi_arcache;
assign ram_arprot  = axi_arprot ;
assign ram_arvalid = axi_arvalid;
assign axi_arready = ram_arready;
//r
assign axi_rid    = axi_rvalid ? ram_rid   :  5'd0 ;
assign axi_rdata  = axi_rvalid ? ram_rdata : 32'd0 ;
assign axi_rresp  = axi_rvalid ? ram_rresp :  2'd0 ;
assign axi_rlast  = axi_rvalid ? ram_rlast :  1'd0 ;
assign axi_rvalid = ram_rvalid;
assign ram_rready = axi_rready;
//aw
assign ram_awid    = axi_awid   ;
assign ram_awaddr  = axi_awaddr ;
assign ram_awlen   = axi_awlen  ;
assign ram_awsize  = axi_awsize ;
assign ram_awburst = axi_awburst;
assign ram_awlock  = axi_awlock ;
assign ram_awcache = axi_awcache;
assign ram_awprot  = axi_awprot ;
assign ram_awvalid = axi_awvalid;
assign axi_awready = ram_awready;
//w
assign ram_wdata  = axi_wdata  ;
assign ram_wstrb  = axi_wstrb  ;
assign ram_wlast  = axi_wlast  ;
assign ram_wvalid = axi_wvalid ;
assign axi_wready = ram_wready ;
//b
assign axi_bid    = axi_bvalid ? ram_bid   : 5'd0 ;
assign axi_bresp  = axi_bvalid ? ram_bresp : 2'd0 ;
assign axi_bvalid = ram_bvalid ;
assign ram_bready = axi_bready ;

axi2sram_dp #(
    .BUS_WIDTH  ( 32 ),
    .DATA_WIDTH ( 32 ),
    .CPU_WIDTH  ( 32 ))
 u_axi2sram_dp (
    .aclk                    ( aclk         ),
    .aresetn                 ( aresetn      ),

    .m_araddr                ( ram_araddr   ),
    .m_arburst               ( ram_arburst  ),
    .m_arcache               ( 4'h0         ),
    .m_arid                  ( ram_arid     ),
    .m_arlen                 ( ram_arlen    ),
    .m_arlock                ( 2'h0         ),
    .m_arprot                ( 3'h0         ),
    .m_arsize                ( ram_arsize   ),
    .m_arvalid               ( ram_arvalid  ),
    .m_arready               ( ram_arready  ),

    .m_rready                ( ram_rready   ),
    .m_rdata                 ( ram_rdata    ),
    .m_rid                   ( ram_rid      ),
    .m_rlast                 ( ram_rlast    ),
    .m_rresp                 ( ram_rresp    ),
    .m_rvalid                ( ram_rvalid   ),

    .m_awaddr                ( ram_awaddr   ),
    .m_awburst               ( ram_awburst  ),
    .m_awcache               ( 4'h0         ),
    .m_awid                  ( ram_awid     ),
    .m_awlen                 ( ram_awlen    ),
    .m_awlock                ( 2'h0         ),
    .m_awprot                ( 3'h0         ),
    .m_awsize                ( ram_awsize   ),
    .m_awvalid               ( ram_awvalid  ),
    .m_awready               ( ram_awready  ),

    .m_wdata                 ( ram_wdata    ),
    .m_wlast                 ( ram_wlast    ),
    .m_wstrb                 ( ram_wstrb    ),
    .m_wvalid                ( ram_wvalid   ),
    .m_wready                ( ram_wready   ),

    .m_bready                ( ram_bready   ),
    .m_bid                   ( ram_bid      ),
    .m_bresp                 ( ram_bresp    ),
    .m_bvalid                ( ram_bvalid   ),

    .ram_raddr               ( fpga_sram_raddr  ),
    .ram_ren                 ( fpga_sram_ren  ),
    .ram_waddr               ( fpga_sram_waddr  ),
    .ram_wdata               ( fpga_sram_wdata  ),
    .ram_wen                 ( fpga_sram_wen    ),
    .ram_rdata               ( fpga_sram_rdata  )
);
// VGA时序参数
localparam HTOTAL = 104; 
localparam HDISP = 80; 
localparam HFRONT_PORCH = 56; 
localparam HSYNC_PULSE = 120; 
localparam HBACKPORCH = 64; 

localparam VTOTAL = 66; 
localparam VDISP = 60; 
localparam VFRONT_PORCH = 37; 
localparam VSYNC_PULSE = 6;
localparam VBACKPORCH = 23;



localparam IMG_WIDTH = 66;
localparam IMG_HEIGHT = 60;
localparam DELAY_NUM = 20;

reg [10:0] hcnt;
reg [9:0] vcnt;
always @(posedge aclk) begin
    if (~aresetn) begin
        hcnt <= 11'b0;
        vcnt <= 10'b0;
    end else begin
        if (hcnt == HTOTAL - 1) begin
            hcnt <= 11'b0;
            if (vcnt == VTOTAL - 1)vcnt <= 10'b0; 
			else vcnt <= vcnt + 1'b1;
        end 
		else hcnt <= hcnt + 1'b1;
    end
end

wire video_hsync,video_vsync,video_de;
// 生成行同步信�?
assign video_hsync = (hcnt >= HDISP + HFRONT_PORCH) && (hcnt < HDISP + HFRONT_PORCH + HSYNC_PULSE) ? 1'b0 : 1'b1;

// 生成场同步信�?
assign video_vsync = (vcnt >= VDISP + VFRONT_PORCH) && (vcnt < VDISP + VFRONT_PORCH + VSYNC_PULSE) ? 1'b0 : 1'b1;

// 生成数据有效信号
assign video_de = (hcnt < HDISP) && (vcnt < VDISP);

wire [19:0]pixcnt;
assign pixcnt=(vcnt < IMG_HEIGHT) && (hcnt < IMG_WIDTH) ? (vcnt * IMG_WIDTH + hcnt) : 0;
assign fpga_sram_raddr=pixcnt>>2;

wire [7:0]rgbdata;
assign rgbdata=fpga_sram_rdata>>{pixcnt[1:0],3'b0};
//1MByte SRAM
fpga_sram_dp #(
.AW ( 9 ),
.Init_File (Init_File)
)u_fpga_sram (
    .CLK                     ( aclk              ),
    .ram_raddr               ( fpga_sram_raddr[8:0]   ),
    .ram_ren                 ( fpga_sram_ren     ),
    .ram_rdata               ( fpga_sram_rdata   ),
    .ram_waddr               ( fpga_sram_waddr[10:2]   ),
    .ram_wdata               ( fpga_sram_wdata   ),
    .ram_wen                 ( fpga_sram_wen     )
);
reg fpga_sram_ren_r,fpga_sram_ren_rr;
always@(posedge aclk)begin
    if(~aresetn)fpga_sram_ren_r<=0;
    else if(fpga_sram_waddr[10:2]==271)fpga_sram_ren_r<=1;
end
always@(posedge aclk)begin
    if(~aresetn)begin fpga_sram_ren<=0;fpga_sram_ren_rr<=0;end
    else begin fpga_sram_ren<=fpga_sram_ren_rr;fpga_sram_ren_rr<=fpga_sram_ren_r;end
end

reg [7:0] video_red,video_green,video_blue;
always @(posedge aclk) begin
    if (video_de && (vcnt < IMG_HEIGHT) && (hcnt < IMG_WIDTH)) begin
/*        video_red <= {fpga_sram_rdata[23:21],5'b0}; 
        video_green <= {fpga_sram_rdata[15:13],5'b0};
        video_blue <= {fpga_sram_rdata[7:6],6'b0};*/
        video_red <= {rgbdata[7:5],5'b0}; 
        video_green <= {rgbdata[4:2],5'b0};
        video_blue <= {rgbdata[1:0],6'b0};
    end else begin
        // 在非显示区域输出黑色
        video_red <= 0;
        video_green <=0;
        video_blue <=0;
    end
end

/*
reg[7:0]thresh;
always @(posedge aclk) begin
    if (~aresetn) thresh<=8'd120;
	else begin
		if(threshadd&&(thresh<=8'd245))thresh<=thresh+8'd10;
		else if(threshsub&&(thresh>=8'd10))thresh<=thresh-8'd10;
    end
end*/
wire [7:0]thresh;
assign thresh=  (dip_sw[0]?0:8'd100)+
                (dip_sw[1]?8'd20:0)+
                (dip_sw[2]?8'd20:0)+
                (dip_sw[3]?8'd20:0)+
                (dip_sw[4]?8'd20:0)+
                (dip_sw[5]?8'd20:0)+
                (dip_sw[6]?8'd20:0)+
                (dip_sw[7]?8'd20:0)+
                (dip_sw[8]?8'd20:0);

wire ovsync,ohsync,ode;
wire [2:0]o_r,o_g;
wire[1:0]o_b;
ISP_top#(
.IMG_HDISP(HDISP),
.IMG_VDISP(VDISP),
.DELAY_NUM(DELAY_NUM)
)ISP_UNIT
(
	.clk(aclk),  				//cmos video pixel clock
	.rst(~aresetn),				//global reset
	.thresh(thresh),
	
	.per_frame_vsync(video_vsync),	//Prepared Image data vsync valid signal
	.per_frame_href(video_de),		//Prepared Image data href vaild  signal
	.per_frame_clken(video_hsync),	//Prepared Image data ./capture enable clock
	.per_img_red(video_red),		//Prepared Image red data to be processed
	.per_img_green(video_green),		//Prepared Image green data to be processed
	.per_img_blue(video_blue),		//Prepared Image blue data to be processed

	.inhcnt(hcnt),
	.invcnt(vcnt),
	
	.post_frame_vsync(ovsync),	//Processed Image data vsync valid signal
	.post_frame_href(ode),	//Processed Image data href vaild  signal
	.post_frame_clken(ohsync),	//Processed Image data ./capture enable clock
	.post_img_red(o_r),		//Prepared Image red data to be processed
	.post_img_green(o_g),		//Prepared Image green data to be processed
	.post_img_blue(o_b)		//Prepared Image blue data to be processed
);


assign r=dip_sw[0]?video_red[7:5]:o_r;
assign g=dip_sw[0]?video_green[7:5]:o_g;
assign b=dip_sw[0]?video_blue[7:6]:o_b;
assign vsync=dip_sw[0]?video_vsync:ovsync;
assign hsync=dip_sw[0]?video_hsync:ohsync;
assign de=dip_sw[0]?video_de:ode;


/*
reg             [11:0]          extend_last_row_cnt;
always @(posedge aclk)begin
    if(~aresetn)
        extend_last_row_cnt <= 'b0;
    else
    begin
        if(video_de&&(vcnt == VDISP - 1'b1)&&(hcnt == HDISP - 1'b1))
            extend_last_row_cnt <= 'd1;
        else if((extend_last_row_cnt > 'b0)&&(extend_last_row_cnt < DELAY_NUM + HDISP))
            extend_last_row_cnt <= extend_last_row_cnt + 1'b1;
        else
            extend_last_row_cnt <= 'b0;
    end
end

wire extend_last_row_en = (extend_last_row_cnt > DELAY_NUM) ? 1'b1 : 1'b0;
reg extend_last_row_en_dly;
always @(posedge aclk)begin
    if(~aresetn)extend_last_row_en_dly <= 1'b0;
    else	extend_last_row_en_dly <= extend_last_row_en;
end

assign r=video_red[7:5];
assign g=video_green[7:5];
assign b=video_blue[7:6];
//assign vsync=video_vsync;

reg vsync_r;
always @(posedge aclk)
begin
    if(~aresetn)
        vsync_r <= 0;
    else
    begin
        if(video_de&&(vcnt == 12'd1)&&(hcnt == 12'b0))
            vsync_r <= 1'b1;
        else if((extend_last_row_en == 1'b0)&&(extend_last_row_en_dly == 1'b1))
            vsync_r <= 1'b0;
    end
end
assign vsync=video_vsync;
//assign hsync=video_hsync;
assign hsync=video_hsync;
//assign de=video_de;
assign de=video_de& (vcnt > 'b0) | extend_last_row_en;*/
endmodule
