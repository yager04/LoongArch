module sobel_detector
#(
    parameter   [11:0]  IMG_HDISP = 12'd1280,                
    parameter   [11:0]  IMG_VDISP = 12'd480,
    parameter   [11:0]  DELAY_NUM = 12'd5
)
(
    input  wire                 clk             ,
    input  wire                 rst           ,
    
    input  wire     [7:0]       thresh          ,
    
    //  Image data prepared to be processed
    input  wire                 per_img_vsync   ,       //  Prepared Image data vsync valid signal
    input  wire                 per_img_href    ,       //  Prepared Image data href vaild  signal
    input  wire                 per_img_clken   ,
    input  wire     [7:0]       per_img_gray    ,       //  Prepared Image brightness input
    
	input  wire     [10:0]      hcnt,      
	input  wire     [9:0]       vcnt,     
//	input  wire     [11:0]      extend_last_row_cnt,
	
    //  Image data has been processed
    output reg                  post_img_vsync  ,       //  processed Image data vsync valid signal
    output reg                  post_img_href   ,       //  processed Image data href vaild  signal
    output reg                  post_img_clken  ,       //  processed Image data clken vaild  signal
    output reg                  post_img_bit            //  processed Image brightness output
);
//----------------------------------------------------------------------
//  Generate 8Bit 3X3 Matrix
wire                            matrix_img_vsync;
wire                            matrix_img_href;
wire                            matrix_top_edge_flag;
wire                            matrix_bottom_edge_flag;
wire                            matrix_left_edge_flag;
wire                            matrix_right_edge_flag;
wire            [7:0]           matrix_p11;
wire            [7:0]           matrix_p12;
wire            [7:0]           matrix_p13;
wire            [7:0]           matrix_p21;
wire            [7:0]           matrix_p22;
wire            [7:0]           matrix_p23;
wire            [7:0]           matrix_p31; 
wire            [7:0]           matrix_p32;
wire            [7:0]           matrix_p33;

wire matrix_img_clken;
Matrix_Generate_3X3_8Bit
#(
    .IMG_HDISP  (IMG_HDISP  ),
    .IMG_VDISP  (IMG_VDISP  ),
    .DELAY_NUM  (DELAY_NUM  )
)
u_Matrix_Generate_3X3_8Bit
(
    //  global clock & reset
    .clk                    (clk                    ),
    .rst                  (rst                  ),
    
    //  Image data prepared to be processed
    .per_img_vsync          (per_img_vsync          ),      //  Prepared Image data vsync valid signal
    .per_img_href           (per_img_href           ),      //  Prepared Image data href vaild  signal
    .per_img_gray           (per_img_gray           ),      //  Prepared Image brightness input
    
	.hcnt(hcnt),
	.vcnt(vcnt),
    //  Image data has been processed
    .matrix_img_vsync       (matrix_img_vsync       ),      //  processed Image data vsync valid signal
    .matrix_img_href        (matrix_img_href        ),      //  processed Image data href vaild  signal
    .matrix_img_clken(matrix_img_clken),
    .matrix_top_edge_flag   (matrix_top_edge_flag   ),      //  processed Image top edge
    .matrix_bottom_edge_flag(matrix_bottom_edge_flag),      //  processed Image bottom edge
    .matrix_left_edge_flag  (matrix_left_edge_flag  ),      //  processed Image left edge
    .matrix_right_edge_flag (matrix_right_edge_flag ),      //  processed Image right edge
    .matrix_p11             (matrix_p11             ),      //  3X3 Matrix output
    .matrix_p12             (matrix_p12             ),
    .matrix_p13             (matrix_p13             ),
    .matrix_p21             (matrix_p21             ),
    .matrix_p22             (matrix_p22             ),
    .matrix_p23             (matrix_p23             ),
    .matrix_p31             (matrix_p31             ),  
    .matrix_p32             (matrix_p32             ),
    .matrix_p33             (matrix_p33             )
);

//----------------------------------------------------------------------
//            [p11,p12,p13]   [-1,0,1]
//  Gx_data = [p21,p22,p23] * [-2,0,2] = (p13+2*p23+p33) - (p11+2*p21+p31)
//            [p31,p32,p33]   [-1,0,1]
//
//            [p11,p12,p13]   [-1,-2,-1]
//  Gy_data = [p21,p22,p23] * [ 0, 0, 0] = (p31+2*p32+p33) - (p11+2*p12+p13)
//            [p31,p32,p33]   [ 1, 2, 1]
//  
//  G_data = sqrt(Gx_data^2 + Gy_data^2)
reg             [ 9:0]          Gx_data_tmp1;
reg             [ 9:0]          Gx_data_tmp2;
reg             [ 9:0]          Gy_data_tmp1;
reg             [ 9:0]          Gy_data_tmp2;
reg signed      [10:0]          Gx_data;
reg signed      [10:0]          Gy_data;
reg signed      [21:0]          Gx_square_data;
reg signed      [21:0]          Gy_square_data;
reg             [20:0]          G_square_data;
//wire            [10:0]          G_data;

always @(posedge clk)
begin
    Gx_data_tmp1   <= matrix_p13 + {matrix_p23,1'b0} + matrix_p33;
    Gx_data_tmp2   <= matrix_p11 + {matrix_p21,1'b0} + matrix_p31;
    Gy_data_tmp1   <= matrix_p31 + {matrix_p32,1'b0} + matrix_p33;
    Gy_data_tmp2   <= matrix_p11 + {matrix_p12,1'b0} + matrix_p13;
    Gx_data        <= $signed({1'b0,Gx_data_tmp1}) - $signed({1'b0,Gx_data_tmp2});
    Gy_data        <= $signed({1'b0,Gy_data_tmp1}) - $signed({1'b0,Gy_data_tmp2});
    Gx_square_data <= $signed(Gx_data) * $signed(Gx_data);
    Gy_square_data <= $signed(Gy_data) * $signed(Gy_data);
    G_square_data  <= Gx_square_data[20:0] + Gy_square_data[20:0];
end

/*sqrt u_sqrt
(
    .sys_clk    (clk            ),
    .sys_rst    (rst         ),
    .din        (G_square_data  ),
    .din_valid  (1'b1           ),
    .dout       (G_data         ),
    .dout_valid (               )
);*/

//----------------------------------------------------------------------
//  lag 16 clocks signal sync
reg             [3:0]          matrix_img_vsync_r1;
reg             [3:0]          matrix_img_href_r1;
reg             [3:0]          matrix_edge_flag_r1;
reg             [3:0]          matrix_img_clken_r1;
always @(posedge clk)
begin
    if(rst)
    begin
        matrix_img_vsync_r1 <= 4'b0;
        matrix_img_href_r1  <= 4'b0;
        matrix_edge_flag_r1 <= 4'b0;
        matrix_img_clken_r1 <= 4'b0;
    end
    else
    begin
        matrix_img_vsync_r1 <= {matrix_img_vsync_r1[2:0],matrix_img_vsync};
        matrix_img_href_r1  <= {matrix_img_href_r1[2:0],matrix_img_href};
        matrix_edge_flag_r1 <= {matrix_edge_flag_r1[2:0],matrix_top_edge_flag | matrix_bottom_edge_flag | matrix_left_edge_flag | matrix_right_edge_flag};
        matrix_img_clken_r1 <= {matrix_img_clken_r1[2:0], matrix_img_clken};
    end
end

//----------------------------------------------------------------------
//  result output
always @(posedge clk)
begin
    if(matrix_edge_flag_r1[3] == 1'b1)
        post_img_bit <= 1'b0;
    //else if(G_data > thresh)
    else if(G_square_data > thresh*thresh)
        post_img_bit <= 1'b1;
    else
        post_img_bit <= 1'b0;
end

always @(posedge clk)
begin
    if(rst)
    begin
        post_img_vsync <= 1'b0;
        post_img_href  <= 1'b0;
        post_img_clken <= 1'b0;
    end
    else
    begin
        post_img_vsync <= matrix_img_vsync_r1[3];
        post_img_href  <= matrix_img_href_r1[3];
        post_img_clken <= matrix_img_clken_r1[3];
    end
end

endmodule