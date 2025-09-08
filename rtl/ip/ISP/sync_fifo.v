module sync_fifo
#(
    parameter WIDTH      = 8 ,
    parameter DEPTH      = 16
)(
    input  wire                             rst         ,
    input  wire                             clk         ,
    
    input  wire                             wr_en       ,
    input  wire [WIDTH - 1:0]        din         , 
    output reg                              full        ,
    
    input  wire                             rd_en       ,
    output wire [WIDTH - 1:0]        dout        ,
    output reg                              empty
);
//------------------------------------------------------
//  signals define
reg     [WIDTH - 1:0]            mem [DEPTH - 1:0];
reg     [$clog2(DEPTH) - 1:0]  write_pointer;
reg     [$clog2(DEPTH) - 1:0]  read_pointer;
//------------------------------------------------------

 fifo_1024 fifo_1024_u (
        .QA(dout),
			  .CLKA(clk),
			  .CLKB(clk),
			  .CENA(rd_en),
			  .CENB(we_en),
			  .AA(read_pointer),
			  .AB(write_pointer ),
			  .DB(din));
//  fifo write
always @(posedge clk)begin
    if(rst)
        write_pointer <= 0;
    else
    begin
        if(wr_en&&(~full))
        begin
            if(write_pointer < DEPTH - 1'b1)
                write_pointer <= write_pointer + 1'b1;
            else
                write_pointer <= 0;
        end
    end
end

always @(posedge clk)
begin
    if(rst)
        full <= 1'b0;
    else
    begin
        if(((read_pointer == 0)&&(write_pointer == DEPTH - 1'b1)||(write_pointer == read_pointer - 1'b1))&&wr_en&&(~rd_en))
            full <= 1'b1;
        else if((full == 1'b1)&&(rd_en == 1'b1))
            full <= 1'b0;
    end
end

//------------------------------------------------------
//  fifo read
always @(posedge clk)begin
    if(rst)
        read_pointer <= 0;
    else
    begin
        if(rd_en&&(~empty))
        begin
            if(read_pointer < DEPTH - 1'b1)
                read_pointer <= read_pointer + 1'b1;
            else
                read_pointer <= 0;
        end
    end
end

always @(posedge clk)
begin
    if(rst)
        empty <= 1'b1;
    else
    begin
        if(((write_pointer == 0)&&(read_pointer == DEPTH - 1'b1)||(read_pointer == write_pointer - 1'b1))&&rd_en&&(~wr_en))
            empty <= 1'b1;
        else if((empty == 1'b1)&&wr_en)
            empty <= 1'b0;
    end
end
endmodule
