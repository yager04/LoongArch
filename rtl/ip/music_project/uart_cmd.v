module uart_cmd(
    Clk,
    Reset_n,
    rx_data,
    rx_done,
    //ctrl,
    //time_set
    //eqgain_set,
    //eqchannel_set,
    led1,
    led2,
    led3,
    led4
);
    
    input Clk;
    input Reset_n;
    input [7:0]rx_data;
    input rx_done;
    //output reg[7:0]ctrl;
    //output reg[31:0]time_set;
    output reg led1;
    output reg led2;
    output reg led3;
    output reg led4;

    wire rx_done;
    reg [7:0] data_str [4:0];
    always@(posedge Clk)
/*
    if(rx_done)begin
        data_str[7] <= #1 rx_data;
        data_str[6] <= #1 data_str[7];
        data_str[5] <= #1 data_str[6];
        data_str[4] <= #1 data_str[5];
        data_str[3] <= #1 data_str[4];
        data_str[2] <= #1 data_str[3];
        data_str[1] <= #1 data_str[2];
        data_str[0] <= #1 data_str[1];        
    end
*/  
    if(rx_done)begin
        data_str[4] <=  rx_data;
        data_str[3] <=  data_str[4];
        data_str[2] <=  data_str[3];
        data_str[1] <=  data_str[2];
        data_str[0] <=  data_str[1];        
    end 
    reg r_rx_done;
    always@(posedge Clk)
        r_rx_done <= rx_done;
  /* 
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n) begin
        ctrl <= #1 0;
        time_set <= #1 0;
    
    else if(r_rx_done)begin
        if((data_str[0] == 8'h55) && (data_str[1] == 8'hA5) && (data_str[7] == 8'hF0))begin
            time_set[31:24] <= #1 data_str[2];
            time_set[23:16] <= #1 data_str[3];
            time_set[15:8] <= #1 data_str[4];
            time_set[7:0] <= #1 data_str[5];
            ctrl <= #1 data_str[6];
        end
    end  
*/
//assign led = r_rx_done;

always@(posedge Clk)
    if(r_rx_done)begin 
        if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h01) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            led1 <= ~led1;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h01) && (data_str[3] == 8'h02) && (data_str[4] == 8'hd2))begin
            led2 <= ~led2;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h01) && (data_str[3] == 8'h03) && (data_str[4] == 8'hd2))begin
            led3 <= ~led3;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h01) && (data_str[3] == 8'h04) && (data_str[4] == 8'hd2))begin
            led4 <= ~led4;
        end
    end
/*
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h02) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd1;
            eqgain_set <= 2'd0;  
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h02) && (data_str[3] == 8'h02) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd1;
            eqgain_set <= 2'd1;  
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h02) && (data_str[3] == 8'h03) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd1;
            eqgain_set <= 2'd2; 
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h02) && (data_str[3] == 8'h04) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd1;
            eqgain_set <= 2'd3;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h03) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd2;
            eqgain_set <= 2'd0; 
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h03) && (data_str[3] == 8'h02) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd2;
            eqgain_set <= 2'd1; 
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h03) && (data_str[3] == 8'h03) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd2;
            eqgain_set <= 2'd2;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h03) && (data_str[3] == 8'h04) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd2;
            eqgain_set <= 2'd3;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h04) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd3;
            eqgain_set <= 2'd0;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h04) && (data_str[3] == 8'h02) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd3;
            eqgain_set <= 2'd1;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h04) && (data_str[3] == 8'h03) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd3;
            eqgain_set <= 2'd2;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h04) && (data_str[3] == 8'h04) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd3;
            eqgain_set <= 2'd3;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h05) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd4;
            eqgain_set <= 2'd0;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h05) && (data_str[3] == 8'h02) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd4;
            eqgain_set <= 2'd1;  
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h05) && (data_str[3] == 8'h03) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd4;
            eqgain_set <= 2'd2;  
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h05) && (data_str[3] == 8'h04) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd4;
            eqgain_set <= 2'd3;  
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h06) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd5;
            eqgain_set <= 2'd0; 
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h06) && (data_str[3] == 8'h02) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd5;
            eqgain_set <= 2'd1;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h06) && (data_str[3] == 8'h03) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd5;
            eqgain_set <= 2'd2; 
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h06) && (data_str[3] == 8'h04) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd5;
            eqgain_set <= 2'd3;   
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h07) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd6;
            eqgain_set <= 2'd0; 
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h07) && (data_str[3] == 8'h02) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd6;
            eqgain_set <= 2'd1; 
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h07) && (data_str[3] == 8'h03) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd6;
            eqgain_set <= 2'd2; 
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h07) && (data_str[3] == 8'h04) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd6;
            eqgain_set <= 2'd3; 
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h08) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd7;
            eqgain_set <= 2'd0;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h08) && (data_str[3] == 8'h02) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd7;
            eqgain_set <= 2'd1;  
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h08) && (data_str[3] == 8'h03) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd7;
            eqgain_set <= 2'd2; 
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h08) && (data_str[3] == 8'h04) && (data_str[4] == 8'hd2))begin
            eqchannel_set <= 3'd7;
            eqgain_set <= 2'd3; 
        end
        else begin
            eqchannel_set <= 3'd0;
            eqgain_set <= 3'd0;
        end

    end
*/
endmodule

