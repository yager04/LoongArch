module filter_63Hz(
    clk,
    reset,
    en,
    filter_in,
    filter_out,
    Xout,
    Yin,
    Yout,
    Ysum,
    Ydiv
    
);
parameter I = 16;
parameter N = 18;  //simulink
input clk;
input reset;
input en;
input signed [I-1:0] filter_in;
output signed [I-1:0] filter_out;
output signed [I+5:0] Xout;
output signed [N-1:0] Yin;
output signed [N+17:0] Yout;
output signed [N+18:0] Ysum;
output signed [N+18:0] Ydiv;


parameter signed [15:0] filter1_b1 = 16'b0000_0000_0000_0011;
parameter signed [15:0] filter1_b2 = 16'b0000_0000_0000_0110;
parameter signed [15:0] filter1_b3 = 16'b0000_0000_0000_0011;
parameter signed [15:0] filter1_a1 = 16'b0001_0000_0000_0000; 
parameter signed [15:0] filter1_a2 = 16'b0111_1110_1010_1111; //-32431
parameter signed [15:0] filter1_a3 = 16'b0011_1110_1011_1011; //16059

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

wire signed [I+3:0] Xmult1;
wire signed [I+3:0] Xmult2;
wire signed [I+3:0] Xmult3;

assign Xmult1 = {{3{Xin_reg[0][15]}},Xin_reg[0],1'd0}
               +{{4{Xin_reg[0][15]}},Xin_reg[0]};
//multiply by filter1_b1 = 16'b0000_0000_0000_0011;

assign Xmult2 = {{2{Xin_reg[1][15]}},Xin_reg[1],2'd0}
               +{{3{Xin_reg[1][15]}},Xin_reg[1],1'd0};
//multiply by filter1_b2 = 16'b0000_0000_0000_0110;

assign Xmult3 = {{3{Xin_reg[2][15]}},Xin_reg[2],1'd0}
               +{{4{Xin_reg[2][15]}},Xin_reg[2]};
//multiply by filter1_b3 = 16'b0000_0000_0000_0011;

wire signed [I+5:0] Xout;
assign Xout = Xmult1 + Xmult3 + Xmult2;

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

assign Ymult1 = {{2{Yin_reg[0][N-1]}},Yin_reg[0],15'd0}
              - {{9{Yin_reg[0][N-1]}},Yin_reg[0],8'd0}
              - {{11{Yin_reg[0][N-1]}},Yin_reg[0],6'd0}
              - {{13{Yin_reg[0][N-1]}},Yin_reg[0],4'd0}
              - {{17{Yin_reg[0][N-1]}},Yin_reg[0]};
//multiply by filter1_a2 = 16'b0111_1110_1010_1111;
//CSD:1000_000-1_0-10-1_000-1

assign Ymult2 = {{3{Yin_reg[1][N-1]}},Yin_reg[1],14'd0}
              - {{9{Yin_reg[1][N-1]}},Yin_reg[1],8'd0}
              - {{11{Yin_reg[1][N-1]}},Yin_reg[1],6'd0}
              - {{15{Yin_reg[1][N-1]}},Yin_reg[1],2'd0}
              - {{17{Yin_reg[1][N-1]}},Yin_reg[1]};
//multiply by filter1_a3 = 16'b0011_1110_1011_1011;
//CSD:0100_000-1_0-100_0-10-1

assign Yout = Ymult2 - Ymult1;
wire signed [N+18:0] Ysum;
wire signed [N+18:0] Ydiv;
assign Ysum = {{13{Xout[I+5]}},Xout,{N-I{1'b0}}}-{Yout[N+17],Yout}; //37ä½?
assign Ydiv = {{14{Ysum[N+18]}},Ysum[N+18:14]};
assign Yin = (!reset)?{N-1{1'd0}}:Ydiv[N-1:0];

wire [15:0] filter_out1;
assign filter_out = Yin[N-1:2];
//assign filter_out = {{2{filter_out1[15]}},filter_out1[15:2]};

endmodule