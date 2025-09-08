module audio_lookback(
		input clk,                    
		input reset_n, 
		inout iic_0_scl,              
		inout iic_0_sda,  
		input en,
		input I2S_ADCDAT,
		input I2S_ADCLRC,
		input I2S_BCLK,
        input uart_rx,
		output I2S_DACDAT,
		input I2S_DACLRC,
		output I2S_MCLK,
        output cic_clk
);
	
	parameter DATA_WIDTH        = 32;     

    reg I2S_MCLK_reg;
    reg [1:0]cnt8;
    always @(posedge clk)
    if ((~reset_n)&en) begin
        I2S_MCLK_reg <= 1'b0;
        cnt8 <= 'b0;
    end
    else begin
        if(cnt8 == 3) begin
            I2S_MCLK_reg <= ~I2S_MCLK_reg;
        end
        else begin
            cnt8 <= cnt8 + 1'b1;
        end
    end
    assign I2S_MCLK=I2S_MCLK_reg;
	
 	wire Init_Done;
	WM8960_Init WM8960_Init(
		.Clk(clk),
		.Rst_n(reset_n|(~en)),
		.I2C_Init_Done(Init_Done),
		.i2c_sclk(iic_0_scl),
		.i2c_sdat(iic_0_sda)
	);
	
	//assign led = Init_Done;
	
	reg adcfifo_read;
	wire [DATA_WIDTH - 1:0] adcfifo_readdata;
	wire adcfifo_empty;

	reg dacfifo_write;
	reg [DATA_WIDTH - 1:0] dacfifo_writedata;
	wire dacfifo_full;
	

	always @ (posedge clk)
	begin
		if ((~reset_n)&en)
		begin
			adcfifo_read <= 1'b0;
		end
		else if (~adcfifo_empty)
		begin
			adcfifo_read <= 1'b1;  //当adcfifo非空时，adcfifo读信号置1
		end
		else
		begin
			adcfifo_read <= 1'b0;
		end
	end

	always @ (posedge clk)
	begin
		if((~reset_n)&en)
			dacfifo_write <= 1'd0;
		else if(~dacfifo_full && (~adcfifo_empty)) begin
			dacfifo_write <= 1'd1; //当且仅当dacfifo数据未满，adcfifo数据非空时，dacfifo写标志置1
			dacfifo_writedata <= adcfifo_readdata; //！！�? adcfifo读出的数据写给dacfifo
		end
		else begin
			dacfifo_write <= 1'd0;
		end
	end

wire [7:0] rx_data;
wire rx_done;
wire [31:0] disp_data;

uart_byte_rx uart_byte_rx(
    .Clk(clk),
    .Reset_n(reset_n|(~en)),
    .Baud_Set(3'd4),
    .uart_rx(uart_rx),
    .Data(rx_data),
    .Rx_Done(rx_done)  
); 

	i2s_rx 
	#(
		.DATA_WIDTH(DATA_WIDTH) 
	)i2s_rx
	(
		.reset_n(reset_n|(~en)),
		.bclk(I2S_BCLK),
		.adclrc(I2S_ADCLRC),
		.adcdat(I2S_ADCDAT),
		.adcfifo_rdclk(clk),
		.adcfifo_read(adcfifo_read),
		.adcfifo_empty(adcfifo_empty),
		.adcfifo_readdata(adcfifo_readdata),
        .cic_clk(cic_clk),
        .rx_data(rx_data),
        .rx_done(rx_done)    
	);
	i2s_tx
	#(
		 .DATA_WIDTH(DATA_WIDTH)
	)i2s_tx
	(
		 .reset_n(reset_n|(~en)),
		 .dacfifo_wrclk(clk),
		 .dacfifo_wren(dacfifo_write),
		 .dacfifo_wrdata(dacfifo_writedata),
		 .dacfifo_full(dacfifo_full),
		 .bclk(I2S_BCLK),
		 .daclrc(I2S_DACLRC),
		 .dacdat(I2S_DACDAT)
	);

endmodule
