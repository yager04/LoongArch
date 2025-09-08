module ISP_top#(
parameter IMG_HDISP = 12'd58,
parameter IMG_VDISP = 12'd28,
parameter DELAY_NUM = 11'd5
)
(
	input				clk,  				//cmos video pixel clock
	input				rst,				//global reset
	input		[7:0]	thresh,
	

	input				per_frame_vsync,	//Prepared Image data vsync valid signal
	input				per_frame_href,		//Prepared Image data href vaild  signal
	input				per_frame_clken,	//Prepared Image data output/capture enable clock
	input		[7:0]	per_img_red,		//Prepared Image red data to be processed
	input		[7:0]	per_img_green,		//Prepared Image green data to be processed
	input		[7:0]	per_img_blue,		//Prepared Image blue data to be processed

	input		[10:0]	inhcnt,
	input		[9:0]	invcnt,

	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock
	output		[2:0]	post_img_red,		//Prepared Image red data to be processed
	output		[2:0]	post_img_green,		//Prepared Image green data to be processed
	output		[1:0]	post_img_blue		//Prepared Image blue data to be processed
);
wire				mid1_frame_vsync;
wire				mid1_frame_href;
wire				mid1_frame_clken;
wire		[7:0]	mid1_img_Y		;

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
	
	.post_frame_vsync	(mid1_frame_vsync),		//Processed Image frame data valid signal
	.post_frame_href	(mid1_frame_href),		//Processed Image hsync data valid signal
	.post_frame_clken	(mid1_frame_clken),		//Processed Image data output/capture enable clock
	.post_img_Y			(mid1_img_Y),			//Processed Image brightness output
	.post_img_Cb		(),			//Processed Image blue shading output
	.post_img_Cr		()			//Processed Image red shading output
);

wire		[7:0]	mid2_img_Y;			//Processed Image brightness output
wire 				mid2_img_bit;
wire				mid2_frame_vsync;
wire				mid2_frame_href;
wire				mid2_frame_clken;	
reg		[10:0]	hcnt[0:2];
reg		[9:0]	vcnt[0:2];
always@(posedge clk)
begin
	if(rst)
		begin
		hcnt[0] <= 0;
		vcnt[0] <= 0;
		hcnt[1] <= 0;
		vcnt[1] <= 0;
		hcnt[2] <= 0;
		vcnt[2] <= 0;
		end
	else
		begin
		hcnt[0] <= inhcnt;
		vcnt[0] <= invcnt;
		hcnt[1] <= hcnt[0];
		vcnt[1] <= vcnt[0];
		hcnt[2] <= hcnt[1];
		vcnt[2] <= vcnt[1];
		end
end

sobel_detector
#(
    .IMG_HDISP(IMG_HDISP),               
    .IMG_VDISP(IMG_VDISP),
	.DELAY_NUM(DELAY_NUM)
) u_sobel_detector
(
    .clk(clk),
    .rst(rst),
    
    .thresh(thresh),

    .per_img_vsync(mid1_frame_vsync),     
    .per_img_href (mid1_frame_href),       
    .per_img_clken(mid1_frame_clken),       
    .per_img_gray (mid1_img_Y),       
    
	.hcnt(hcnt[2]),
	.vcnt(vcnt[2]),
    .post_img_vsync(post_frame_vsync)  , 
    .post_img_href(post_frame_href)   ,    
    .post_img_clken(post_frame_clken)   ,     
    .post_img_bit(mid2_img_bit)            
);
assign post_img_red		={3{mid2_img_bit}};
assign post_img_green	={3{mid2_img_bit}};
assign post_img_blue	={2{mid2_img_bit}};

endmodule
