module eq_filter(
    clk,
    bclk,
    reset,
    filter_in,
    filter_out,
    rx_data,
    rx_done
);
input clk;
input bclk;
input reset;
input [15:0] filter_in;
input [7:0] rx_data;
input rx_done;

output [15:0] filter_out;

wire [15:0] filter_out1;
wire [15:0] filter_out2;
wire [15:0] filter_63_out;
wire [15:0] filter_125_out;
wire [15:0] filter_250_out;
wire [15:0] filter_500_out;
wire [15:0] filter_1000_out;
wire [15:0] filter_2000_out;
wire [15:0] filter_4000_out;
wire [15:0] filter_8000_out;
reg [15:0] rx_filter_63_out;
//reg [15:0] rx_filter_125_out;
reg [15:0] rx_filter_250_out;
reg [15:0] rx_filter_500_out;
reg [15:0] rx_filter_1000_out;
reg [15:0] rx_filter_2000_out;
reg [15:0] rx_filter_4000_out;
reg [15:0] rx_filter_8000_out;
reg [15:0] rx_filter_63_out_r;
//reg [15:0] rx_filter_125_out_r;
reg [15:0] rx_filter_250_out_r;
reg [15:0] rx_filter_500_out_r;
reg [15:0] rx_filter_1000_out_r;
reg [15:0] rx_filter_2000_out_r;
reg [15:0] rx_filter_4000_out_r;
reg [15:0] rx_filter_8000_out_r;

wire rx_done;
reg en;
reg [6:0] eq_state;
reg [7:0] data_str [4:0];
always@(posedge clk)
    if(rx_done)begin
        data_str[4] <=  rx_data;
        data_str[3] <=  data_str[4];
        data_str[2] <=  data_str[3];
        data_str[1] <=  data_str[2];
        data_str[0] <=  data_str[1];        
    end 

reg r_rx_done;
always@(posedge clk)
    r_rx_done <= rx_done;

/*
rx_filter_63_out <= {{2{filter_63_out[15]}},filter_63_out[15:2]};
rx_filter_125_out <= rx_filter_125_out;
rx_filter_250_out <= rx_filter_250_out;
rx_filter_500_out <= rx_filter_500_out;
rx_filter_1000_out <= rx_filter_1000_out;
rx_filter_2000_out <= rx_filter_2000_out;
rx_filter_4000_out <= rx_filter_4000_out;
rx_filter_8000_out <= rx_filter_8000_out;
*/
wire judge1_00,judge1_02;
assign	judge1_00=(data_str[1] == 8'h00),
		judge1_02=(data_str[1] == 8'h02);
		
wire judge2_00,judge2_01,judge2_02,judge2_03,judge2_04,judge2_05,judge2_06,judge2_07,judge2_08;
assign  judge2_00=(data_str[2] == 8'h00),
        judge2_01=(data_str[2] == 8'h01),
        judge2_02=(data_str[2] == 8'h02),
        judge2_03=(data_str[2] == 8'h03),
        judge2_04=(data_str[2] == 8'h04),
        judge2_05=(data_str[2] == 8'h05),
        judge2_06=(data_str[2] == 8'h06),
        judge2_07=(data_str[2] == 8'h07),
        judge2_08=(data_str[2] == 8'h08);

wire judge3_00,judge3_01,judge3_02,judge3_03,judge3_04,judge3_05;
assign  judge3_00=(data_str[3] == 8'h00),
        judge3_01=(data_str[3] == 8'h01),
        judge3_02=(data_str[3] == 8'h02),
        judge3_03=(data_str[3] == 8'h03),
        judge3_04=(data_str[3] == 8'h04),
        judge3_05=(data_str[3] == 8'h05);
		
wire judge0000;
assign judge0000=judge2_00 && judge3_00;

wire judge0101,judge0102,judge0103,judge0104,judge0105;
assign	judge0101=judge2_01 && judge3_01,
		judge0102=judge2_01 && judge3_02,
		judge0103=judge2_01 && judge3_03,
		judge0104=judge2_01 && judge3_04,
		judge0105=judge2_01 && judge3_05;

wire judge0201,judge0202,judge0203,judge0204,judge0205;
assign	judge0201=judge2_02 && judge3_01,
		judge0202=judge2_02 && judge3_02,
		judge0203=judge2_02 && judge3_03,
		judge0204=judge2_02 && judge3_04,
		judge0205=judge2_02 && judge3_05;

wire judge0301,judge0302,judge0303,judge0304,judge0305;
assign	judge0301=judge2_03 && judge3_01,
		judge0302=judge2_03 && judge3_02,
		judge0303=judge2_03 && judge3_03,
		judge0304=judge2_03 && judge3_04,
		judge0305=judge2_03 && judge3_05;

wire judge0401,judge0402,judge0403,judge0404,judge0405;
assign	judge0401=judge2_04 && judge3_01,
		judge0402=judge2_04 && judge3_02,
		judge0403=judge2_04 && judge3_03,
		judge0404=judge2_04 && judge3_04,
		judge0405=judge2_04 && judge3_05;
		
wire judge0501,judge0502,judge0503,judge0504,judge0505;
assign	judge0501=judge2_05 && judge3_01,
		judge0502=judge2_05 && judge3_02,
		judge0503=judge2_05 && judge3_03,
		judge0504=judge2_05 && judge3_04,
		judge0505=judge2_05 && judge3_05;

wire judge0601,judge0602,judge0603,judge0604,judge0605;
assign	judge0601=judge2_06 && judge3_01,
		judge0602=judge2_06 && judge3_02,
		judge0603=judge2_06	&& judge3_03,
		judge0604=judge2_06 && judge3_04,
		judge0605=judge2_06 && judge3_05;

wire judge0701,judge0702,judge0703,judge0704,judge0705;
assign	judge0701=judge2_07 && judge3_01,
		judge0702=judge2_07 && judge3_02,
		judge0703=judge2_07	&& judge3_03,
		judge0704=judge2_07 && judge3_04,
		judge0705=judge2_07 && judge3_05;	

wire judge0801,judge0802,judge0803,judge0804,judge0805;
assign	judge0801=judge2_08 && judge3_01,
		judge0802=judge2_08 && judge3_02,
		judge0803=judge2_08	&& judge3_03,
		judge0804=judge2_08 && judge3_04,
		judge0805=judge2_08 && judge3_05;		
always @(posedge clk) begin
    if(r_rx_done)begin 
		if((data_str[0] == 8'hd1)&&(data_str[4] == 8'hd2))begin
			en <= judge1_00 && judge0000;
			/*if (judge1_00 && judge0000 ) begin
				eq_state <= 7'd0;            
			end
			else if(judge1_02 && judge0101 )begin
				eq_state <= 7'd1;
			end
			else if(judge1_02 && judge0102 )begin
				eq_state <= 7'd2;
			end
			else if(judge1_02 && judge0103 )begin
				eq_state <= 7'd3;
			end
			else if(judge1_02 && judge0104 )begin
				eq_state <= 7'd4;
			end
			else if(judge1_02 && judge0105 )begin
				eq_state <= 7'd5;
			end
			else if(judge1_02 && judge0201 )begin
				eq_state <= 7'd6;
			end
			else if(judge1_02 && judge0202 )begin
				eq_state <= 7'd7;
			end
			else if(judge1_02 && judge0203 )begin
				eq_state <= 7'd8;
			end
			else if(judge1_02 && judge0204 )begin
				eq_state <= 7'd9;
			end
			else if(judge1_02 && judge0205 )begin
				eq_state <= 7'd10;
			end
			else if(judge1_02 && judge0301 )begin
				eq_state <= 7'd11;
			end
			else if(judge1_02 && judge0302 )begin
				eq_state <= 7'd12;
			end
			else if(judge1_02 && judge0303 )begin
				eq_state <= 7'd13;
			end
			else if(judge1_02 && judge0304 )begin
				eq_state <= 7'd14;
			end
			else if(judge1_02 && judge0305 )begin
				eq_state <= 7'd15;
			end
			else if(judge1_02 && judge0401 )begin
				eq_state <= 7'd16;
			end
			else if(judge1_02 && judge0402 )begin
				eq_state <= 7'd17;
			end
			else if(judge1_02 && judge0403 )begin
				eq_state <= 7'd18;
			end
			else if(judge1_02 && judge0404 )begin
				eq_state <= 7'd19;
			end
			else if(judge1_02 && judge0405 )begin
				eq_state <= 7'd20;
			end
			else if(judge1_02 && judge0501 )begin
				eq_state <= 7'd21;
			end
			else if(judge1_02 && judge0502 )begin
				eq_state <= 7'd22;
			end
			else if(judge1_02 && judge0503 )begin
				eq_state <= 7'd23;
			end
			else if(judge1_02 && judge0504 )begin
				eq_state <= 7'd24;
			end
			else if(judge1_02 && judge0505 )begin
				eq_state <= 7'd25;
			end
			else if(judge1_02 && judge0601 )begin
				eq_state <= 7'd26;
			end
			else if(judge1_02 && judge0602 )begin
				eq_state <= 7'd27;
			end
			else if(judge1_02 && judge0603 )begin
				eq_state <= 7'd28;
			end
			else if(judge1_02 && judge0604 )begin
				eq_state <= 7'd29;
			end
			else if(judge1_02 && judge0605 )begin
				eq_state <= 7'd30;
			end
			else if(judge1_02 && judge0701 )begin
				eq_state <= 7'd31;
			end
			else if(judge1_02 && judge0702 )begin
				eq_state <= 7'd32;
			end
			else if(judge1_02 && judge0703 )begin
				eq_state <= 7'd33;
			end
			else if(judge1_02 && judge0704 )begin
				eq_state <= 7'd34;
			end
			else if(judge1_02 && judge0705 )begin
				eq_state <= 7'd35;
			end
			else if(judge1_02 && judge0801 )begin
				eq_state <= 7'd36;
			end
			else if(judge1_02 && judge0802 )begin
				eq_state <= 7'd37;
			end
			else if(judge1_02 && judge0803 )begin
				eq_state <= 7'd38;
			end
			else if(judge1_02 && judge0804 )begin
				eq_state <= 7'd39;
			end   
			else if(judge1_02 && judge0805 )begin
				eq_state <= 7'd40;
			end */
			/*eq_state <=	judge1_02?(
			{7{judge0101}}&7'd1|
			{7{judge0102}}&7'd2|
			{7{judge0103}}&7'd3|
			{7{judge0104}}&7'd4|
			{7{judge0105}}&7'd5|
			{7{judge0201}}&7'd6|
			{7{judge0202}}&7'd7|
			{7{judge0203}}&7'd8|
			{7{judge0204}}&7'd9|
			{7{judge0205}}&7'd10|
			{7{judge0301}}&7'd11|
			{7{judge0302}}&7'd12|
			{7{judge0303}}&7'd13|
			{7{judge0304}}&7'd14|
			{7{judge0305}}&7'd15|
			{7{judge0401}}&7'd16|
			{7{judge0402}}&7'd17|
			{7{judge0403}}&7'd18|
			{7{judge0404}}&7'd19|
			{7{judge0405}}&7'd20|
			{7{judge0501}}&7'd21|
			{7{judge0502}}&7'd22|
			{7{judge0503}}&7'd23|
			{7{judge0504}}&7'd24|
			{7{judge0505}}&7'd25|
			{7{judge0601}}&7'd26|
			{7{judge0602}}&7'd27|
			{7{judge0603}}&7'd28|
			{7{judge0604}}&7'd29|
			{7{judge0605}}&7'd30|
			{7{judge0701}}&7'd31|
			{7{judge0702}}&7'd32|
			{7{judge0703}}&7'd33|
			{7{judge0704}}&7'd34|
			{7{judge0705}}&7'd35|
			{7{judge0801}}&7'd36|
			{7{judge0802}}&7'd37|
			{7{judge0803}}&7'd38|
			{7{judge0804}}&7'd39|
			{7{judge0805}}&7'd40
			):((judge1_00 && judge0000)? 7'd0:eq_state);*/
			eq_state <= judge1_02?(
			// 第0位 (LSB): 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
			{6'b0, (judge0101 | judge0103 | judge0105 | judge0201 | judge0203 | judge0205 | 
            judge0301 | judge0303 | judge0305 | judge0401 | judge0403 | judge0405 | 
            judge0501 | judge0503 | judge0505 | judge0601 | judge0603 | judge0605 | 
            judge0701 | judge0703 | judge0705 | judge0801 | judge0803 | judge0805)} |

			// 第1位: 2,3,6,7,10,11,14,15,18,19,22,23,26,27,30,31,34,35,38,39
			{5'b0, (judge0102 | judge0103 | judge0202 | judge0203 | judge0302 | judge0303 | 
            judge0402 | judge0403 | judge0502 | judge0503 | judge0602 | judge0603 | 
            judge0702 | judge0703 | judge0802 | judge0803), 1'b0} |

			// 第2位: 4,5,6,7,12,13,14,15,20,21,22,23,28,29,30,31,36,37,38,39
			{4'b0, (judge0104 | judge0105 | judge0204 | judge0205 | judge0304 | judge0305 | 
            judge0404 | judge0405 | judge0504 | judge0505 | judge0604 | judge0605 | 
            judge0704 | judge0705 | judge0804 | judge0805), 2'b0} |

			// 第3位: 8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31,40
			{3'b0, (judge0201 | judge0202 | judge0203 | judge0204 | judge0205 | judge0301 | 
            judge0302 | judge0303 | judge0304 | judge0305 | judge0601 | judge0602 | 
            judge0603 | judge0604 | judge0605 | judge0801 | judge0802 | judge0803 | 
            judge0804 | judge0805), 3'b0} |

			// 第4位: 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
			{2'b0, (judge0401 | judge0402 | judge0403 | judge0404 | judge0405 | judge0501 | 
            judge0502 | judge0503 | judge0504 | judge0505 | judge0601 | judge0602 | 
            judge0603 | judge0604 | judge0605 | judge0701 | judge0702 | judge0703 | 
            judge0704 | judge0705 | judge0801 | judge0802 | judge0803 | judge0804 | 
            judge0805), 4'b0} |

			// 第5位: 32,33,34,35,36,37,38,39,40
			{1'b0, (judge0701 | judge0702 | judge0703 | judge0704 | judge0705 | judge0801 | 
            judge0802 | judge0803 | judge0804 | judge0805), 5'b0} |

			// 第6位 (MSB): 40
			{(judge0805), 6'b0}
			):((judge1_00 && judge0000)? 7'd0:eq_state);
		end
    end
end

/*
always @(posedge clk or negedge reset) begin
    if(!reset) begin    
            rx_filter_63_out <= filter_63_out;
            rx_filter_125_out <= filter_125_out;
            rx_filter_250_out <= filter_250_out;
            rx_filter_500_out <= filter_500_out;
            rx_filter_1000_out <= filter_1000_out;
            rx_filter_2000_out <= filter_2000_out;
            rx_filter_4000_out <= filter_4000_out;
            rx_filter_8000_out <= filter_8000_out;    
    end
    else begin
        case(eq_state) 
            7'd0:  begin
                rx_filter_63_out <= filter_63_out;
                rx_filter_125_out <= filter_125_out;
                rx_filter_250_out <= filter_250_out;
                rx_filter_500_out <= filter_500_out;
                rx_filter_1000_out <= filter_1000_out;
                rx_filter_2000_out <= filter_2000_out;
                rx_filter_4000_out <= filter_4000_out;
                rx_filter_8000_out <= filter_8000_out;
                end
            7'd1:  rx_filter_63_out <= {{2{filter_63_out[15]}},filter_63_out[15:2]};
            7'd2:   begin
                    rx_filter_63_out <= {filter_63_out[15],filter_63_out[15:1]};
                    end
            7'd3:  rx_filter_63_out <= filter_63_out <<< 1;
            7'd4:  rx_filter_63_out <= filter_63_out <<< 2;
            7'd5:  rx_filter_125_out <= {{2{filter_125_out[15]}},filter_125_out[15:2]};
            7'd6:  rx_filter_125_out <= {filter_125_out[15],filter_125_out[15:1]};
            7'd7:  rx_filter_125_out <= filter_125_out <<< 1;
            7'd8:  rx_filter_125_out <= filter_125_out <<< 2;
            7'd9:  rx_filter_250_out <= {{2{filter_250_out[15]}},filter_250_out[15:2]};
            7'd10:  rx_filter_250_out <= {filter_250_out[15],filter_250_out[15:1]};
            7'd11:  rx_filter_250_out <= filter_250_out <<< 1;
            7'd12:  rx_filter_250_out <= filter_250_out <<< 2;
            7'd13:  rx_filter_500_out <= {{2{filter_500_out[15]}},filter_500_out[15:2]};
            7'd14:  rx_filter_500_out <= {filter_500_out[15],filter_500_out[15:1]};
            7'd15:  rx_filter_500_out <= filter_500_out <<< 1;
            7'd16:  rx_filter_500_out <= filter_500_out <<< 2;     
            7'd17:  rx_filter_1000_out <= {{2{filter_1000_out[15]}},filter_1000_out[15:2]};
            7'd18:  rx_filter_1000_out <= {filter_1000_out[15],filter_1000_out[15:1]};
            7'd19:  rx_filter_1000_out <= filter_1000_out <<< 1;
            7'd20:  rx_filter_1000_out <= filter_1000_out <<< 2;
            7'd21:  rx_filter_2000_out <= {{2{filter_2000_out[15]}},filter_2000_out[15:2]};
            7'd22:  rx_filter_2000_out <= {filter_2000_out[15],filter_2000_out[15:1]};
            7'd23:  rx_filter_2000_out <= filter_2000_out <<< 1;
            7'd24:  rx_filter_2000_out <= filter_2000_out <<< 2;
            7'd25:  rx_filter_4000_out <= {{2{filter_4000_out[15]}},filter_4000_out[15:2]};
            7'd26:  rx_filter_4000_out <= {filter_4000_out[15],filter_4000_out[15:1]};
            7'd27:  rx_filter_4000_out <= filter_4000_out <<< 1;
            7'd28:  rx_filter_4000_out <= filter_4000_out <<< 2;
            7'd29:  rx_filter_8000_out <= {{2{filter_8000_out[15]}},filter_8000_out[15:2]};
            7'd30:  rx_filter_8000_out <= {filter_8000_out[15],filter_8000_out[15:1]};
            7'd31:  rx_filter_8000_out <= filter_8000_out <<< 1;
            7'd32:  rx_filter_8000_out <= filter_8000_out <<< 2;
        endcase
    end
end
*/
always@(posedge clk)begin
rx_filter_63_out_r<=rx_filter_63_out;
rx_filter_250_out_r<=rx_filter_250_out;
rx_filter_500_out_r<=rx_filter_500_out;
rx_filter_1000_out_r<=rx_filter_1000_out;
rx_filter_2000_out_r<=rx_filter_2000_out;
rx_filter_4000_out_r<=rx_filter_4000_out;
rx_filter_8000_out_r<=rx_filter_8000_out;
end

always @(eq_state or filter_63_out) begin
    case(eq_state)
        7'd0: rx_filter_63_out = filter_63_out;
        7'd1: rx_filter_63_out = {{2{filter_63_out[15]}},filter_63_out[15:2]};
        7'd2: rx_filter_63_out = {filter_63_out[15],filter_63_out[15:1]};
        7'd3: rx_filter_63_out = filter_63_out;
        7'd4: rx_filter_63_out = filter_63_out <<< 1;
        7'd5: rx_filter_63_out = filter_63_out <<< 2;
        default: rx_filter_63_out = rx_filter_63_out_r;
    endcase
end

/*always @(eq_state or filter_125_out) begin
    case(eq_state)
        7'd0: rx_filter_125_out <= filter_125_out;
        7'd6: rx_filter_125_out <= {{2{filter_125_out[15]}},filter_125_out[15:2]};
        7'd7: rx_filter_125_out <= {filter_125_out[15],filter_125_out[15:1]};
        7'd8: rx_filter_125_out <= filter_125_out;        
        7'd9: rx_filter_125_out <= filter_125_out <<< 1;
        7'd10: rx_filter_125_out <= filter_125_out <<< 2;
        default: rx_filter_125_out <= rx_filter_125_out;
    endcase
end*/

always @(eq_state or filter_250_out) begin
    case(eq_state)
        7'd0: rx_filter_250_out = filter_250_out;
        7'd11: rx_filter_250_out = {{2{filter_250_out[15]}},filter_250_out[15:2]};
        7'd12: rx_filter_250_out = {filter_250_out[15],filter_250_out[15:1]};
        7'd13: rx_filter_250_out = filter_250_out;
        7'd14: rx_filter_250_out = filter_250_out <<< 1;
        7'd15: rx_filter_250_out = filter_250_out <<< 2;
        default: rx_filter_250_out = rx_filter_250_out_r;
    endcase
end

always @(eq_state or filter_500_out) begin
    case(eq_state)
        7'd0: rx_filter_500_out = filter_500_out;
        7'd16: rx_filter_500_out = {{2{filter_500_out[15]}},filter_500_out[15:2]};
        7'd17: rx_filter_500_out = {filter_500_out[15],filter_500_out[15:1]};
        7'd18: rx_filter_500_out = filter_500_out;
        7'd19: rx_filter_500_out = filter_500_out <<< 1;
        7'd20: rx_filter_500_out = filter_500_out <<< 2;
        default: rx_filter_500_out = rx_filter_500_out_r;
    endcase
end

always @(eq_state or filter_1000_out) begin
    case(eq_state)
        7'd0: rx_filter_1000_out = filter_1000_out;
        7'd21: rx_filter_1000_out = {{2{filter_1000_out[15]}},filter_1000_out[15:2]};
        7'd22: rx_filter_1000_out = {filter_1000_out[15],filter_1000_out[15:1]};
        7'd23: rx_filter_1000_out = filter_1000_out;
        7'd24: rx_filter_1000_out = filter_1000_out <<< 1;
        7'd25: rx_filter_1000_out = filter_1000_out <<< 2;
        default: rx_filter_1000_out = rx_filter_1000_out_r;
    endcase
end

always @(eq_state or filter_2000_out) begin
    case(eq_state)
        7'd0: rx_filter_2000_out = filter_2000_out;
        7'd26: rx_filter_2000_out = {{2{filter_2000_out[15]}},filter_2000_out[15:2]};
        7'd27: rx_filter_2000_out = {filter_2000_out[15],filter_2000_out[15:1]};
        7'd28: rx_filter_2000_out = filter_2000_out;
        7'd29: rx_filter_2000_out = filter_2000_out <<< 1;
        7'd30: rx_filter_2000_out = filter_2000_out <<< 2;
        default: rx_filter_2000_out = rx_filter_2000_out_r;
    endcase
end

always @(eq_state or filter_4000_out) begin
    case(eq_state)
        7'd0: rx_filter_4000_out = filter_4000_out;
        7'd31: rx_filter_4000_out = {{2{filter_4000_out[15]}},filter_4000_out[15:2]};
        7'd32: rx_filter_4000_out = {filter_4000_out[15],filter_4000_out[15:1]};
        7'd33: rx_filter_4000_out = filter_4000_out;
        7'd34: rx_filter_4000_out = filter_4000_out <<< 1;
        7'd35: rx_filter_4000_out = filter_4000_out <<< 2;
        default: rx_filter_4000_out = rx_filter_4000_out_r;
    endcase
end   

always @(eq_state or filter_8000_out) begin
    case(eq_state)
        7'd0: rx_filter_8000_out = filter_8000_out;
        7'd36: rx_filter_8000_out = {filter_8000_out[15],filter_8000_out[15:1]};
        7'd37: rx_filter_8000_out = filter_8000_out;
        7'd38: rx_filter_8000_out = filter_8000_out <<< 1;
        7'd39: rx_filter_8000_out = filter_8000_out * 3;
        7'd40: rx_filter_8000_out = filter_8000_out <<< 2;
        default: rx_filter_8000_out = rx_filter_8000_out_r;
    endcase
end      
filter_63Hz filter_63Hz(
    .clk(bclk),
    .reset(reset),
    .en(1'b1),
    .filter_in(filter_in),
    .filter_out(filter_63_out)
);

/*filter_125_top filter_125(
    .clk(bclk),
    .reset(reset),
    .en(1'b1),
    .filter_in(filter_in),
    .filter2_out(filter_125_out)
);*/

filter_250_top filter_250(
    .clk(bclk),
    .reset(reset),
    .en(1'b1),
    .filter_in(filter_in),
    .filter2_out(filter_250_out)
);

filter_500_top filter_500(
    .clk(bclk),
    .reset(reset),
    .en(1'b1),
    .filter_in(filter_in),
    .filter2_out(filter_500_out)
);

filter_1000k_top filter_1000k(
    .clk(bclk),
    .reset(reset),
    .en(1'b1),
    .filter_in(filter_in),
    .filter2_out(filter_1000_out)
);

filter_2000k_1top filter_2000k(
    .clk(bclk),
    .reset(reset),
    .en(1'b1),
    .filter_in(filter_in),
    .filter2_out(filter_2000_out)
);

filter_4000k_top filter_4000k(
    .clk(bclk),
    .reset(reset),
    .en(1'b1),
    .filter_in(filter_in),
    .filter2_out(filter_4000_out)
);

filter_8000k_top filter_8000k(
    .clk(bclk),
    .reset(reset),
    .en(1'b1),
    .filter_in(filter_in),
    .filter2_out(filter_8000_out)
);
/*
always @(posedge bclk) begin
    if(en == 1'b1) 
        filter_out <=  rx_filter_63_out + rx_filter_125_out + rx_filter_250_out 
                       + rx_filter_500_out + rx_filter_1000_out + rx_filter_2000_out 
                       + rx_filter_4000_out + rx_filter_8000_out;
    else 
        filter_out <=  filter_63_out + filter_125_out + filter_250_out 
                       + filter_500_out + filter_1000_out + filter_2000_out 
                       + filter_4000_out + filter_8000_out;        
end
*/
/*
assign filter_out =  filter_63_out + filter_125_out + filter_250_out 
               + filter_500_out + filter_1000_out + filter_2000_out 
               + filter_4000_out + filter_8000_out; 
*/
assign filter_out1 = filter_63_out + filter_250_out + filter_500_out + filter_1000_out + filter_2000_out + filter_4000_out + filter_8000_out;
assign filter_out2 = rx_filter_63_out + rx_filter_250_out + rx_filter_500_out + rx_filter_1000_out + rx_filter_2000_out + rx_filter_4000_out + rx_filter_8000_out;
assign filter_out = (en)? filter_out2:filter_out1;
endmodule