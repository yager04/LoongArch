`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/04 13:58:55
// Design Name: 
// Module Name: my_int_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module my_int_ctrl(
    input sys_clk,
    input sys_resetn,
    input cpu_clk,
    input cpu_resetn,
    
    input [3:0] four_posedge,
    input [4:0] confreg_int_in,
    input [31:0] confreg_int_en,
    input [31:0] confreg_int_clr,
    input [31:0] confreg_int_edge,
    output [31:0] confreg_int_state,
    output confreg_int
    );
    
    wire [4:0] confreg_int_in;
    wire [31:0] confreg_int_en;
    wire [31:0] confreg_int_state;
    wire confreg_int;
    wire timer_state;
    wire ext_int0;
    wire ext_int1;
    wire ext_int2;
    wire ext_int3;
    assign timer_state = confreg_int_in[4] & confreg_int_en[4];
    assign ext_int0 = confreg_int_en[0] & confreg_int_edge[0] & four_posedge[0];
    assign ext_int1 = confreg_int_en[1] & confreg_int_edge[1] & four_posedge[1];
    assign ext_int2 = confreg_int_en[2] & confreg_int_edge[2] & four_posedge[2];
    assign ext_int3 = confreg_int_en[3] & confreg_int_edge[3] & four_posedge[3];
    assign confreg_int_state = {27'h0,timer_state,ext_int3,ext_int2,ext_int1,ext_int0};
    
    reg int_valid;
    always @(posedge sys_clk or negedge sys_resetn) begin
        if(~sys_resetn) begin
            int_valid <= 1'b0;
        end
        else begin
            int_valid <= |confreg_int_state;
        end
    end
    
    reg [1:0] int_valid_r;
    always @(posedge cpu_clk or negedge cpu_resetn) begin
        if(~cpu_resetn) begin
            int_valid_r <= 2'b0;
        end
        else begin
            int_valid_r <= {int_valid_r[0],int_valid};
        end
    end
    assign confreg_int = int_valid_r[1];
    
endmodule
