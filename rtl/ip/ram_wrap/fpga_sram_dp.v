module fpga_sram_dp #(
    parameter AW = 9,
    parameter Init_File = "none"
)
(
    input  wire          CLK,

    input  wire [AW-1:0] ram_raddr,
    output wire [31  :0] ram_rdata,
    input  wire          ram_ren  ,

    input  wire [AW-1:0] ram_waddr,
    input  wire [31  :0] ram_wdata,
    input  wire [3   :0] ram_wen
);
	/*
    localparam AWT = ((1<<(AW-0))-1);
    localparam V_STYLE = "block";
    localparam P_STYLE =    (V_STYLE == "ultra")        ? "uram" :
                            (V_STYLE == "distributed")  ? "select_ram" :
                            "block_ram";

    (*ram_style = V_STYLE*)reg [31:0] BRAM [AWT:0]/*synthesis syn_ramstyle=P_STYLE*/;
wire wen;
wire [31:0]	bwenb;
assign wen = |ram_wen;

assign bwenb[7:0] = ram_wen[0] ? 8'h00 : 8'hff ;
assign bwenb[15:8] = ram_wen[1] ? 8'h00 : 8'hff ;
assign bwenb[23:16] = ram_wen[2] ? 8'h00 : 8'hff ;
assign bwenb[31:24] = ram_wen[3] ? 8'h00 : 8'hff ;


 Bram2port Bram2port_u(
                          .QA(ram_rdata)   ,
			  .CLKA(CLK)  ,
			  .CLKB(CLK),
			  .CENA(~ram_ren),
			  .CENB(~wen),
                          .BWENB(bwenb),
			  .AA(ram_raddr),
			  .AB(ram_waddr),
			  .DB(ram_wdata)
			);

    
endmodule
