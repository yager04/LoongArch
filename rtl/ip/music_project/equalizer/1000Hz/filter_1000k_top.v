module filter_1000k_top(
    input clk,
    input reset,
    input en,
    input [15:0] filter_in,
    output signed [15:0] filter1_out,
    output signed [15:0] filter2_out 
);
filter_1000k_1 filter_1(
    .clk(clk),
    .reset(reset),
    .en(en),
    .filter_in(filter_in),
    .filter_out(filter1_out)
);

filter_1000k_2 filter_2(
    .clk(clk),
    .reset(reset),
    .en(en),
    .filter_in(filter1_out),
    .filter_out(filter2_out)
);

endmodule