module blues(
    input clk,
    input reset_n,
    input [15:0] din,
    output [15:0] blues_out
);

wire [15:0] bandpass_out;
wire [15:0] brokenline_out;
wire [15:0] dout;
wire [16:0] predin;
wire [17:0] wetdout_temp;
wire [15:0] wetdout;
wire [15:0] drydout;
wire [15:0] blues_outtemp;

assign predin = din <<< 1;

bandpass bandpass1(
    .clk(clk),
    .reset(reset_n),
    .en(1'b1),
    .filter_in(din),
    .filter_out(bandpass_out)
);

broken_line broken_line1(
    .din(bandpass_out),
    .dout(brokenline_out)
);

lowpass lowpass1(
    .clk(clk),
    .reset(reset_n),
    .en(1'b1),
    .filter_in(brokenline_out),
    .filter_out(dout)
);

assign wetdout_temp = {dout[15],dout,1'b0} + {{2{dout[15]}},dout};
assign wetdout = wetdout_temp[17:2];
assign drydout = {{2{din[15]}},din[15:2]};
assign blues_outtemp = drydout + wetdout;
assign blues_out = blues_outtemp <<< 2;

endmodule
