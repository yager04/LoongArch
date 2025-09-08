module lowpass(
    clk,
    reset,
    en,
    filter_in,
    filter_out  
);
parameter I = 16;
parameter N = 18;  //simulink
input clk;
input reset;
input en;
input signed [I-1:0] filter_in;
output signed [I-1:0] filter_out;

parameter signed [15:0] filter1_b1 = 16'b0000_0011_0010_1011;
parameter signed [15:0] filter1_b2 = 16'b0000_0110_0101_0110;
parameter signed [15:0] filter1_b3 = 16'b0000_0011_0010_1011;
parameter signed [15:0] filter1_a1 = 16'b0100_0000_0000_0000; 
parameter signed [15:0] filter1_a2 = 16'b0101_0001_1110_0110; 
parameter signed [15:0] filter1_a3 = 16'b0001_1110_1001_0001; 

reg signed [I-1:0] Xin_reg [2:0];
always @(posedge clk)
begin
    if(!reset)
    begin
        Xin_reg[0] <= {I{1'd0}};
        Xin_reg[1] <= {I{1'd0}};
        Xin_reg[2] <= {I{1'd0}};
    end
    else 
    begin
        Xin_reg[0] <= filter_in;
        Xin_reg[1] <= Xin_reg[0];
        Xin_reg[2] <= Xin_reg[1];
    end
end

wire signed [I+12:0] Xmult1;
wire signed [I+12:0] Xmult2;
wire signed [I+12:0] Xmult3;

assign Xmult1 = {{4{Xin_reg[0][15]}},Xin_reg[0],9'd0}
               +{{5{Xin_reg[0][15]}},Xin_reg[0],8'd0}
               +{{8{Xin_reg[0][15]}},Xin_reg[0],5'd0}
               +{{10{Xin_reg[0][15]}},Xin_reg[0],3'd0}
               +{{12{Xin_reg[0][15]}},Xin_reg[0],1'd0}               
               +{{13{Xin_reg[0][15]}},Xin_reg[0]};
//multiply by filter1_b1 = 16'b0000_0011_0010_1011;

assign Xmult2 = {{3{Xin_reg[1][15]}},Xin_reg[1],10'd0}
               +{{4{Xin_reg[1][15]}},Xin_reg[1],9'd0}
               +{{7{Xin_reg[1][15]}},Xin_reg[1],6'd0}
               +{{9{Xin_reg[1][15]}},Xin_reg[1],4'd0}
               +{{11{Xin_reg[1][15]}},Xin_reg[1],2'd0}
               +{{12{Xin_reg[1][15]}},Xin_reg[1],1'd0};
//multiply by filter1_b2 = 16'b0000_0110_0101_0110;

assign Xmult3 = {{4{Xin_reg[2][15]}},Xin_reg[2],9'd0}
               +{{5{Xin_reg[2][15]}},Xin_reg[2],8'd0}
               +{{8{Xin_reg[2][15]}},Xin_reg[2],5'd0}
               +{{10{Xin_reg[2][15]}},Xin_reg[2],3'd0}
               +{{12{Xin_reg[2][15]}},Xin_reg[2],1'd0}               
               +{{13{Xin_reg[2][15]}},Xin_reg[2]};
//multiply by filter1_b3 = 16'b0000_0011_0010_1011;

wire signed [I+14:0] Xout;
assign Xout = Xmult1 + Xmult2 + Xmult3;

wire signed [N-1:0] Yin;
reg signed [N-1:0] Yin_reg [1:0];

always @(posedge clk)
    begin
        if(!reset)
        begin
            Yin_reg[0] <= {N{1'd0}};
            Yin_reg[1] <= {N{1'd0}};
        end
        else
        begin
            Yin_reg[0] <= Yin;
            Yin_reg[1] <= Yin_reg[0];
        end
    end
wire signed [N+16:0] Ymult1;
wire signed [N+16:0] Ymult2;
wire signed [N+17:0] Yout;

assign Ymult1 = {{3{Yin_reg[0][N-1]}},Yin_reg[0],14'd0}
              + {{5{Yin_reg[0][N-1]}},Yin_reg[0],12'd0}
              + {{8{Yin_reg[0][N-1]}},Yin_reg[0],9'd0}
              - {{12{Yin_reg[0][N-1]}},Yin_reg[0],5'd0}
              + {{14{Yin_reg[0][N-1]}},Yin_reg[0],3'd0}
              - {{16{Yin_reg[0][N-1]}},Yin_reg[0],1'd0};
//multiply by filter1_a2 = 16'b0101_0001_1110_0110;
//CSD:0101_0010_00-10_10-10

assign Ymult2 = {{4{Yin_reg[1][N-1]}},Yin_reg[1],13'd0}
              - {{8{Yin_reg[1][N-1]}},Yin_reg[1],9'd0}
              + {{10{Yin_reg[1][N-1]}},Yin_reg[1],7'd0}
              + {{13{Yin_reg[1][N-1]}},Yin_reg[1],4'd0}
              + {{17{Yin_reg[1][N-1]}},Yin_reg[1]};
//multiply by filter1_a3 = 16'b0001_1110_1001_0001;
//CSD:0010_00-10_1001_0001

assign Yout = Ymult2 - Ymult1;
wire signed [N+18:0] Ysum;
wire signed [N+18:0] Ydiv;
assign Ysum = {{4{Xout[I+14]}},Xout,{N-I{1'b0}}}-{Yout[N+17],Yout}; //37ä½?
assign Ydiv = {{14{Ysum[N+18]}},Ysum[N+18:14]};
assign Yin = (!reset)?{N-1{1'd0}}:Ydiv[N-1:0];

wire [15:0] filter_out1;
assign filter_out = Yin[N-1:2];
//assign filter_out = {{2{filter_out1[15]}},filter_out1[15:2]};

endmodule