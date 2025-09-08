module filter_8000k_2(
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
output signed [I+15:0] Xout;
output signed [N-1:0] Yin;
output signed [N+15:0] Yout;
output signed [N+16:0] Ysum;
output signed [N+16:0] Ydiv;


parameter signed [15:0] filter1_b1 = 16'b0001_0000_0000_0000;
parameter signed [15:0] filter1_b2 = 16'b0000_0000_0000_0000;
parameter signed [15:0] filter1_b3 = 16'b0001_0000_0000_0000;
parameter signed [15:0] filter1_a1 = 16'b0001_0000_0000_0000;
parameter signed [15:0] filter1_a2 = 16'b0000_1001_0101_1000; //CSD:0000_1010_-10-10_-1000
parameter signed [15:0] filter1_a3 = 16'b0001_0001_1000_1010; //CSD:0001_0010_-1000_1010

reg signed [I-1:0] Xin_reg [2:0];
always @(posedge clk)
begin
    if(!reset)
    begin
        Xin_reg[0] <= {I{1'd0}};
        Xin_reg[1] <= {I{1'd0}};
        Xin_reg[2] <= {I{1'd0}};
    end
    else if(en)
    begin
        Xin_reg[0] <= filter_in;
        Xin_reg[1] <= Xin_reg[0];
        Xin_reg[2] <= Xin_reg[1];
    end
end

wire signed [I+13:0] Xmult1;
wire signed [I+13:0] Xmult2;
wire signed [I+13:0] Xmult3;

assign Xmult1 = {{2{Xin_reg[0][I-1]}},Xin_reg[0],12'd0};
//multiply by filter1_b1 = 16'b0001_0000_0000_0000;
assign Xmult3 = {{2{Xin_reg[2][I-1]}},Xin_reg[2],12'd0};
//multiply by filter1_b3 = 16'b0001_0000_0000_0000;

wire signed [I+15:0] Xout;
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
        else if(en)
        begin
            Yin_reg[0] <= Yin;
            Yin_reg[1] <= Yin_reg[0];
        end
    end
wire signed [N+13:0] Ymult1;
wire signed [N+13:0] Ymult2;
wire signed [N+15:0] Yout;

assign Ymult1 =  {{3{Yin_reg[0][N-1]}},Yin_reg[0],11'd0}
              + {{6{Yin_reg[0][N-1]}},Yin_reg[0],8'd0}
              + {{8{Yin_reg[0][N-1]}},Yin_reg[0],6'd0}
              + {{10{Yin_reg[0][N-1]}},Yin_reg[0],4'd0}  
              + {{11{Yin_reg[0][N-1]}},Yin_reg[0],3'd0};
//multiply by filter1_a2 = 16'b0000_1001_0101_1000; 
//multiply by 2392
//CSD:0000_1010_-10-10_-1000

assign Ymult2 = {{2{Yin_reg[1][N-1]}},Yin_reg[1],12'd0}
              + {{6{Yin_reg[1][N-1]}},Yin_reg[1],8'd0}
              + {{7{Yin_reg[1][N-1]}},Yin_reg[1],7'd0}
              + {{11{Yin_reg[1][N-1]}},Yin_reg[1],3'd0}
              + {{13{Yin_reg[1][N-1]}},Yin_reg[1],1'd0};
//multiply by filter1_a3 = 16'b0001_0001_1000_1010;
//multiply by 4490
//CSD:0001_0010_-1000_1010

assign Yout = Ymult2 - Ymult1;
wire signed [N+16:0] Ysum;
wire signed [N+16:0] Ydiv;
assign Ysum = {Xout[I+15],Xout,{N-I{1'b0}}}-{Yout[N+15],Yout};
assign Ydiv = {{12{Ysum[N+16]}},Ysum[N+16:12]};
assign Yin = (!reset)?{N-1{1'd0}}:{Ydiv[N+16],Ydiv[N-1:1]};

assign filter_out = Yin[N-2:N-17];

endmodule