module digitaltube_controller(
    // �������üĴ��� Ĭ�� 32 λ
    // [1:0] �����ұߵ������ ��00���� 01������ʾ���� 10����ʾ���ֺ�С����
    // [3:2] ������������
    input wire [31:0] control_reg,
    
    // ���ݼĴ��� [15:0]
    // 0x0000_000X [3:0] ��Ӧ��һ���Ƶ���ʾ
    // 0x0000_00X0 [7:4] ��Ӧ�ڶ����Ƶ���ʾ
    inout wire [31:0] data_reg,
    
    input wire clk,
    input wire rst_n,
    
    output wire [7:0] dpy0, // dpy0
    output wire [7:0] dpy1  // dpy1
);
    
    // �ڲ��Ĵ�������
    reg [7:0] dpy0_reg; 
    reg [7:0] dpy1_reg; 
    
    assign dpy0 = dpy0_reg;
    assign dpy1 = dpy1_reg;
    
    reg [3:0] dpy0_data; // dpy0 ��ʾ���ݣ�4 λ��0-F��
    reg [3:0] dpy1_data; // dpy1 ��ʾ���ݣ�4 λ��0-F��
    
    // ����ܶ���洢
    reg [6:0] seg_code [0:15]; // �洢 0-F �ı���

    // ��ʼ������ܶ���
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            seg_code[0] <= 7'b1000000; // 0
            seg_code[1] <= 7'b1110110; // 1
            seg_code[2] <= 7'b0100001; // 2
            seg_code[3] <= 7'b0100100; // 3
            seg_code[4] <= 7'b0010110; // 4
            seg_code[5] <= 7'b0001100; // 5
            seg_code[6] <= 7'b0001000; // 6
            seg_code[7] <= 7'b1100110; // 7
            seg_code[8] <= 7'b0000000; // 8
            seg_code[9] <= 7'b0000110; // 9
            seg_code[10] <= 7'b0000010; // A
            seg_code[11] <= 7'b0011000; // B
            seg_code[12] <= 7'b1001001; // C
            seg_code[13] <= 7'b0110000; // D
            seg_code[14] <= 7'b0001001; // E
            seg_code[15] <= 7'b0001011; // F
        end
    end


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dpy0_reg <= 8'b0000_0000;
        end
        else begin
            // �������ݼĴ����е���ʾ����
            dpy0_data <= data_reg[3:0];  // dpy0 ��ʾ������
            
            // ���� control_reg ������ʾ
            case (control_reg[1:0])
                2'b01: begin
                    dpy0_reg <= {~seg_code[dpy0_data], 1'b0}; // ��ʾ dpy0
                end
                2'b10: begin
                    dpy0_reg <= {~seg_code[dpy0_data], 1'b1}; // ��ʾ dpy0��С����
                end
                default: begin
                    dpy0_reg <= 8'b0000_0000;
                end
            endcase    
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dpy1_reg <= 8'b0000_0000;
        end
        else begin
            // �������ݼĴ����е���ʾ����
            dpy1_data <= data_reg[7:4];  // dpy0 ��ʾ������
            
            // ���� control_reg ������ʾ
            case (control_reg[3:2])
                2'b01: begin
                    dpy1_reg <= {~seg_code[dpy1_data], 1'b0}; // ��ʾ dpy0
                end
                2'b10: begin
                    dpy1_reg <= {~seg_code[dpy1_data], 1'b1}; // ��ʾ dpy0��С����
                end
                default: begin
                    dpy1_reg <= 8'b0000_0000;
                end
            endcase    
        end
    end

endmodule
