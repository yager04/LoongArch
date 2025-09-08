module reverberator(
    clk,
    rst_n,
    reverberator_En,
    din,
    dout
    );
    input clk;
    input rst_n;
    input reverberator_En;
    input wire signed [15:0] din;
    output wire signed [15:0] dout;

//rever_MODE=1    //(MODE=1,T=0.5S)(MODE=2,T=1S)

    parameter DW=16;
    wire signed [DW-1:0] fir_out;



    FIR_18 Fir(clk,rst_n,reverberator_En,din,fir_out);



    assign dout=din+fir_out;

endmodule
