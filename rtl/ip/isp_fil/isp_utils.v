`timescale 1 ns / 1 ps

/* Simple Dual-Port RAM */
module simple_dp_ram
#(
	parameter DW = 8,
	parameter AW = 4,
	parameter SZ = 2**AW
)
(
	input           clk,
	input           wen,
	input  [AW-1:0] waddr,
	input  [DW-1:0] wdata,
	input           ren,
	input  [AW-1:0] raddr,
	output [DW-1:0] rdata
);
	reg [DW-1:0] mem [SZ-1:0];
	always @ (posedge clk) begin
		if (wen) begin
			mem[waddr] <= wdata;
		end
	end
	reg [DW-1:0] q;
	always @ (posedge clk) begin
		if (ren) begin
			q <= mem[raddr];
		end
	end
	assign rdata = q;
endmodule


/* Shift Register based on Simple Dual-Port RAM */
module shift_register
#(
	parameter BITS = 8,
	parameter WIDTH = 480,
	parameter LINES = 3
)
(
	input                clock,
	input                clken,
	input  [BITS-1:0]    shiftin,
	output [BITS-1:0]    shiftout,
	output [BITS*LINES-1:0] tapsx
);

	localparam RAM_SZ = WIDTH - 1;
	localparam RAM_AW = clogb2(RAM_SZ);

	reg [RAM_AW-1:0] pos_r;
	wire [RAM_AW-1:0] pos = pos_r < RAM_SZ ? pos_r : (RAM_SZ[RAM_AW-1:0] - 1'b1);
	always @ (posedge clock) begin
		if (clken) begin
			if (pos_r < RAM_SZ - 1)
				pos_r <= pos_r + 1'b1;
			else
				pos_r <= 0;
		end
	end

	reg [BITS-1:0] in_r;
	always @ (posedge clock) begin
		if (clken) begin
			in_r <= shiftin;
		end
	end
	wire [BITS-1:0] line_out[LINES-1:0];
	generate
		genvar i;
		for (i = 0; i < LINES; i = i + 1) begin : gen_ram_inst
			simple_dp_ram #(BITS, RAM_AW, RAM_SZ) u_ram(clock, clken, pos, (i > 0 ? line_out[i-1] : in_r), clken, pos, line_out[i]);
		end
	endgenerate

	assign shiftout = line_out[LINES-1];
	generate
		genvar j;
		for (j = 0; j < LINES; j = j + 1) begin : gen_taps_assign
			assign tapsx[(BITS*j)+:BITS] = line_out[j];
		end
	endgenerate

	function integer clogb2;
	input integer depth;
	begin
		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
			depth = depth >> 1;
	end
	endfunction
endmodule

//移位正整数除法器，支持流水线，节拍数为BITS
//quo = num // den;  rem = num % den;
module shift_div_uint
#(
	parameter BITS = 32
)
(
	input clk,
	input rst,

	input [BITS-1:0] num, //被除数
	input [BITS-1:0] den, //除数
	
	output [BITS-1:0] quo, //商
	output [BITS-1:0] rem  //余数
);

	//被除数&除数buffer  因需要BITS级流水线 故需要BITS个寄存器
	reg  [BITS*2-1:0] num_tmp [BITS-1:0];
	reg  [BITS*2-1:0] den_tmp [BITS-1:0];
	wire [BITS*2-1:0] num_tmp_in = {{BITS{1'b0}}, num};
	wire [BITS*2-1:0] den_tmp_in = {den, {BITS{1'b0}}};
	always @ (posedge clk ) begin : _blk_run
		integer i;
		if (rst) begin
			for (i = 0; i < BITS; i = i + 1) begin
				num_tmp[i] <= 0;
				den_tmp[i] <= 0;
			end
		end
		else begin
			if ({num_tmp_in[BITS*2-2:0],1'b0} >= den_tmp_in) begin
				num_tmp[0] <= {num_tmp_in[BITS*2-2:0],1'b1} - den_tmp_in;
				den_tmp[0] <= den_tmp_in;
			end
			else begin
				num_tmp[0] <= {num_tmp_in[BITS*2-2:0],1'b0};
				den_tmp[0] <= den_tmp_in;
			end
				
			for (i = 0; i < BITS - 1; i = i + 1) begin
				if ({num_tmp[i][BITS*2-2:0],1'b0} >= den_tmp[i]) begin
					num_tmp[i+1] <= {num_tmp[i][BITS*2-2:0],1'b1} - den_tmp[i];
					den_tmp[i+1] <= den_tmp[i];
				end
				else begin
					num_tmp[i+1] <= {num_tmp[i][BITS*2-2:0],1'b0};
					den_tmp[i+1] <= den_tmp[i];
				end
			end
		end
	end

	assign quo = num_tmp[BITS-1][BITS-1:0];
	assign rem = num_tmp[BITS-1][BITS*2-1:BITS];
endmodule

module data_delay
#(
	parameter BITS = 8,
	parameter DELAY = 5
)
(
	input clk,
	input rst,

	input  [BITS-1:0] in_data,
	output [BITS-1:0] out_data
);

	reg [BITS-1:0] data_buff [DELAY-1:0];
	always @ (posedge clk ) begin : _blk_delay
		integer i;
		if (rst) begin
			for (i = 0; i < DELAY; i = i + 1)
				data_buff[i] <= 0;
		end
		else begin
			data_buff[0] <= in_data;
			for (i = 1; i < DELAY; i = i + 1)
				data_buff[i] <= data_buff[i-1];
		end
	end

	assign out_data = data_buff[DELAY-1];
endmodule