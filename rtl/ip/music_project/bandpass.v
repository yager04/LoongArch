module bandpass(
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

parameter signed [15:0] filter1_b1 = 16'b0000_1010_0011_1101;
parameter signed [15:0] filter1_b2 = 16'b0000_0000_0000_0000;
parameter signed [15:0] filter1_b3 = 16'b0000_1010_0011_1101;
parameter signed [15:0] filter1_a1 = 16'b0100_0000_0000_0000; 
parameter signed [15:0] filter1_a2 = 16'b0110_1011_0010_1100; 
parameter signed [15:0] filter1_a3 = 16'b0010_1011_1000_0110; 

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
//wire signed [I+12:0] Xmult2;
wire signed [I+12:0] Xmult3;

assign Xmult1 = {{2{Xin_reg[0][15]}},Xin_reg[0],11'd0}
               +{{4{Xin_reg[0][15]}},Xin_reg[0],9'd0}
               +{{7{Xin_reg[0][15]}},Xin_reg[0],6'd0}
               -{{11{Xin_reg[0][15]}},Xin_reg[0],2'd0}
               +{{13{Xin_reg[0][15]}},Xin_reg[0]};
//multiply by filter1_b1 = 16'b0000_1010_0011_1101;
//CSD:0000_1010_0100_0-101

assign Xmult3 = {{2{Xin_reg[2][15]}},Xin_reg[2],11'd0}
               +{{4{Xin_reg[2][15]}},Xin_reg[2],9'd0}
               +{{7{Xin_reg[2][15]}},Xin_reg[2],6'd0}
               -{{11{Xin_reg[2][15]}},Xin_reg[2],2'd0}
               +{{13{Xin_reg[2][15]}},Xin_reg[2]};
//multiply by filter1_b3 = 16'b0000_1010_0011_1101;
//CSD:0000_1010_0100_0-101

wire signed [I+13:0] Xout;
assign Xout = Xmult1 - Xmult3;

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

assign Ymult1 = {{2{Yin_reg[0][N-1]}},Yin_reg[0],14'd0}
              + {{3{Yin_reg[0][N-1]}},Yin_reg[0],13'd0}
              + {{5{Yin_reg[0][N-1]}},Yin_reg[0],11'd0}
              + {{7{Yin_reg[0][N-1]}},Yin_reg[0],9'd0}
              + {{8{Yin_reg[0][N-1]}},Yin_reg[0],8'd0}
              + {{11{Yin_reg[0][N-1]}},Yin_reg[0],5'd0}
              + {{13{Yin_reg[0][N-1]}},Yin_reg[0],3'd0}
              + {{14{Yin_reg[0][N-1]}},Yin_reg[0],2'd0};
//multiply by filter1_a2 = 16'b0110_1011_0010_1100;

assign Ymult2 = {{3{Yin_reg[1][N-1]}},Yin_reg[1],13'd0}
              + {{5{Yin_reg[1][N-1]}},Yin_reg[1],11'd0}
              + {{7{Yin_reg[1][N-1]}},Yin_reg[1],9'd0}
              + {{8{Yin_reg[1][N-1]}},Yin_reg[1],8'd0}
              + {{9{Yin_reg[1][N-1]}},Yin_reg[1],7'd0}	      
              + {{14{Yin_reg[1][N-1]}},Yin_reg[1],2'd0}
              + {{15{Yin_reg[1][N-1]}},Yin_reg[1],1'd0};
//multiply by filter1_a3 = 16'b0010_1011_1000_0110;

assign Yout = Ymult2 - Ymult1;
wire signed [N+17:0] Ysum;
wire signed [N+17:0] Ydiv;
assign Ysum = {{5{Xout[I+13]}},Xout,{N-I{1'b0}}}-{Yout[N+17],Yout}; //37ä½?
assign Ydiv = {{14{Ysum[N+17]}},Ysum[N+17:14]};
assign Yin = (!reset)?{N-1{1'd0}}:Ydiv[N-1:0];

wire [15:0] filter_out1;
assign filter_out = Yin[N-1:2];
//assign filter_out = {{2{filter_out1[15]}},filter_out1[15:2]};

endmodule