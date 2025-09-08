module Matrix_Generate_3X3_8Bit
#(
    parameter   [11:0]  IMG_HDISP = 12'd1280,            //  640*480
    parameter   [11:0]  IMG_VDISP = 12'd480,
    parameter   [11:0]  DELAY_NUM = 12'd10              //  Interval period from the penultimate row to the last row
)
(
    //  global clock & reset
    input  wire                 clk                     ,
    input  wire                 rst                   ,
    
    //  Image data prepared to be processed
    input  wire                 per_img_vsync           ,   //  Prepared Image data vsync valid signal
    input  wire                 per_img_href            ,   //  Prepared Image data href vaild  signal
    input  wire     [7:0]       per_img_gray            ,   //  Prepared Image brightness input
    
	input  wire     [10:0]      hcnt,      
	input  wire     [9:0]       vcnt,     

    //  Image data has been processed
    output wire                 matrix_img_vsync        ,   //  processed Image data vsync valid signal
    output wire                 matrix_img_href         ,   //  processed Image data href vaild  signal
    output wire                matrix_img_clken         , 
    output wire                 matrix_top_edge_flag    ,   //  processed Image top edge
    output wire                 matrix_bottom_edge_flag ,   //  processed Image bottom edge
    output wire                 matrix_left_edge_flag   ,   //  processed Image left edge
    output wire                 matrix_right_edge_flag  ,   //  processed Image right edge
    output reg      [7:0]       matrix_p11              ,   //  3X3 Matrix output
    output reg      [7:0]       matrix_p12              ,
    output reg      [7:0]       matrix_p13              ,
    output reg      [7:0]       matrix_p21              ,
    output reg      [7:0]       matrix_p22              ,
    output reg      [7:0]       matrix_p23              ,
    output reg      [7:0]       matrix_p31              ,  
    output reg      [7:0]       matrix_p32              ,
    output reg      [7:0]       matrix_p33              
);

//----------------------------------------------------------------------
//  two fifo for raw data buffer
reg             [11:0]          extend_last_row_cnt;

always @(posedge clk)begin
    if(rst)
        extend_last_row_cnt <= 'b0;
    else
    begin
        if((per_img_href == 1'b1)&&(vcnt == IMG_VDISP - 1'b1)&&(hcnt == IMG_HDISP - 1'b1))
            extend_last_row_cnt <= 'd1;
        else if((extend_last_row_cnt > 'b0)&&(extend_last_row_cnt < DELAY_NUM + IMG_HDISP))
            extend_last_row_cnt <= extend_last_row_cnt + 1'b1;
        else
            extend_last_row_cnt <= 'b0;
    end
end

wire extend_last_row_en ;
assign extend_last_row_en = (extend_last_row_cnt > DELAY_NUM) ? 1'b1 : 1'b0;

wire                            fifo1_wenb;
wire            [7:0]           fifo1_wdata;
wire                            fifo1_renb;
wire            [7:0]           fifo1_rdata;

wire                            fifo2_wenb;
wire            [7:0]           fifo2_wdata;
wire                            fifo2_renb;
wire            [7:0]           fifo2_rdata;

assign fifo1_wenb  = per_img_href;
assign fifo1_wdata = per_img_gray;
assign fifo1_renb  = per_img_href & (vcnt > 12'b0) | extend_last_row_en;

assign fifo2_wenb  = per_img_href & (vcnt > 12'b0);
assign fifo2_wdata = fifo1_rdata;
assign fifo2_renb  = per_img_href & (vcnt > 12'b1) | extend_last_row_en;

sync_fifo#(
    .WIDTH   (8),
    .DEPTH   (800)
)
u1_sync_fifo
(
    .rst        (rst     ),
    .clk        (clk        ),
    
    .wr_en      (fifo1_wenb ),
    .din        (fifo1_wdata), 
    .full       (           ),
    
    .rd_en      (fifo1_renb ),
    .dout       (fifo1_rdata),
    .empty      (           )/*,
    .data_count (           )*/
),
u2_sync_fifo
(
    .rst        (rst     ),
    .clk        (clk        ),
    
    .wr_en      (fifo2_wenb ),
    .din        (fifo2_wdata), 
    .full       (           ),
    
    .rd_en      (fifo2_renb ),
    .dout       (fifo2_rdata),
    .empty      (           )/*,
    .data_count (           )*/
);

//----------------------------------------------------------------------
//  Read data from fifo
always @(posedge clk)
begin
    if(rst)
    begin
        {matrix_p11, matrix_p12, matrix_p13} <= 24'h0;
        {matrix_p21, matrix_p22, matrix_p23} <= 24'h0;
        {matrix_p31, matrix_p32, matrix_p33} <= 24'h0;
    end
    else
    begin
        {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p12, matrix_p13, fifo2_rdata};      //  1st row input
        {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p22, matrix_p23, fifo1_rdata};      //  2nd row input
        {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p32, matrix_p33, per_img_gray};     //  3rd row input
    end
end

reg             [1:0]           top_edge_flag;
reg             [1:0]           bottom_edge_flag;
reg             [1:0]           left_edge_flag;
reg             [1:0]           right_edge_flag;


always @(posedge clk)
begin
    if(rst)
    begin
        top_edge_flag    <= 2'b0;
        bottom_edge_flag <= 2'b0;
        left_edge_flag   <= 2'b0;
        right_edge_flag  <= 2'b0;
    end
    else
    begin
        top_edge_flag[0]    <= per_img_href & (vcnt == 'd1);
        top_edge_flag[1]    <= top_edge_flag[0];
        bottom_edge_flag[0] <= extend_last_row_en;
        bottom_edge_flag[1] <= bottom_edge_flag[0];
        left_edge_flag[0]   <= per_img_href & (vcnt > 'b0) & (hcnt == 'b0) | (extend_last_row_cnt == DELAY_NUM + 1'b1);
        left_edge_flag[1]   <= left_edge_flag[0];
        right_edge_flag[0]  <= per_img_href & (vcnt > 'b0) & (hcnt == IMG_HDISP - 1'b1) | (extend_last_row_cnt == DELAY_NUM + IMG_HDISP);
        right_edge_flag[1]  <= right_edge_flag[0];
    end
end

assign matrix_img_vsync        =(vcnt >= IMG_VDISP + 37) && (vcnt < IMG_VDISP + 37 + 6) ? 1'b0 : 1'b1;
assign matrix_img_href         = (hcnt < IMG_HDISP) && (vcnt < IMG_VDISP)&&(vcnt>0);
assign matrix_img_clken=(hcnt >= IMG_HDISP + 56) && (hcnt < IMG_HDISP  +56+120 ) ? 1'b0 : 1'b1;
assign matrix_top_edge_flag    = top_edge_flag[1];
assign matrix_bottom_edge_flag = bottom_edge_flag[1];
assign matrix_left_edge_flag   = left_edge_flag[1];
assign matrix_right_edge_flag  = right_edge_flag[1];

endmodule