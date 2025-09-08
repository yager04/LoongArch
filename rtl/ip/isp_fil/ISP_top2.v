`timescale 1ns/1ns
module ISP_top2#(
parameter IMG_HDISP = 12'd800,
parameter IMG_VDISP = 12'd600
)
(
	//global clock
	input				clk,  				//cmos video pixel clock
	input				rst,				//global reset

	//Image data prepred to be processd
	input				per_frame_vsync,	//Prepared Image data vsync valid signal
	input				per_frame_href,		//Prepared Image data href vaild  signal
	input				per_frame_clken,	//Prepared Image data output/capture enable clock
	input		[7:0]	per_img_red,		//Prepared Image red data to be processed
	input		[7:0]	per_img_green,		//Prepared Image green data to be processed
	input		[7:0]	per_img_blue,		//Prepared Image blue data to be processed

	//Image data has been processd
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock
	output		[7:0]	post_img_red,
	output		[7:0]	post_img_green,
	output		[7:0]	post_img_blue
);

//___________________rgb2yuv_________________
wire 	   csc_href; 	 
wire 	   csc_vsync;	 	 
wire csc_clken;	 
wire [7:0] csc_y ;	 	 
wire [7:0] csc_u ;	 	 
wire [7:0] csc_v ; 

Image_RGB888_YCbCr444	u_VIP_RGB888_YCbCr444
(
	//global clock
	.clk				(clk),					//cmos video pixel clock
	.rst				(rst),				//system reset

	.per_frame_vsync	(per_frame_vsync),		//Prepared Image data vsync valid signal
	.per_frame_href		(per_frame_href),		//Prepared Image data href vaild  signal
	.per_frame_clken	(per_frame_clken),		//Prepared Image data output/capture enable clock
	.per_img_red		(per_img_red),			//Prepared Image red data input
	.per_img_green		(per_img_green),		//Prepared Image green data input
	.per_img_blue		(per_img_blue),			//Prepared Image blue data input
	
	.post_frame_vsync	(csc_vsync),		//Processed Image frame data valid signal
	.post_frame_href	(csc_href),		//Processed Image hsync data valid signal
	.post_frame_clken	(csc_clken),		//Processed Image data output/capture enable clock
	.post_img_Y			(csc_y),			//Processed Image brightness output
	.post_img_Cb		(csc_u),			//Processed Image blue shading output
	.post_img_Cr		(csc_v)			//Processed Image red shading output
);
//___________________2dnr_________________
wire nr2d_href	;
wire nr2d_vsync	;
wire nr2d_clken	;
wire [7:0] nr2d_y;
wire [7:0] nr2d_u;
wire [7:0] nr2d_v;
wire [7:0] nr2d_u_tmp;
wire [7:0] nr2d_v_tmp;
isp_2dnr#(
	.BITS 		 (8),
	.WIDTH 		 (IMG_HDISP),
	.HEIGHT 	 (IMG_VDISP),
	.WEIGHT_BITS (5)
) isp_2dnr_u1
(
	.pclk			(clk			),
	.rst			(rst			),
	.in_href		(csc_href		),
	.in_vsync		(csc_vsync		),
	.in_clken		(csc_clken),
	.in_data		(csc_y  		),
	.out_href		(nr2d_href		),
	.out_vsync		(nr2d_vsync		),
	.out_clken		(nr2d_clken		),
	.out_data		(nr2d_y		)
);
shift_register #(8, IMG_HDISP, 6) nr2d_shift_u (clk, csc_href, csc_u, nr2d_u_tmp, ); //由于2dnr内部使用6行linebuffer,这里UV会早Y�?6行数�?,造成亮度与色度不匹配问题
shift_register #(8, IMG_HDISP, 6) nr2d_shift_v (clk, csc_href, csc_v, nr2d_v_tmp, );
data_delay #(8, (11+8+2*5+6)) nr2d_delay_u (clk, rst, nr2d_u_tmp, nr2d_u);
data_delay #(8, (11+8+2*5+6)) nr2d_delay_v (clk, rst, nr2d_v_tmp, nr2d_v);

//____________________yuv2rgb_______________________
Image_YCbCr444_RGB888 u_Image_YCbCr444_RGB888
(
	.clk             (clk             ),  
	.rst			 (rst		 ),	
	.per_frame_vsync (nr2d_vsync ),	
	.per_frame_href	 (nr2d_href	 ),	
	.per_frame_clken (nr2d_clken),	
	.per_img_Y		 (nr2d_y		 ),	
	.per_img_Cb		 (nr2d_u		 ),	
	.per_img_Cr		 (nr2d_v		 ),	
	.post_frame_vsync(post_frame_vsync),	
	.post_frame_href (post_frame_href ),	
	.post_frame_clken(post_frame_clken),	
	.post_img_red	 (post_img_red	 ),	
	.post_img_green	 (post_img_green	 ),	
	.post_img_blue	 (post_img_blue	 )	
);
endmodule
