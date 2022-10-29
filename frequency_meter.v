#`include "src\seg_auto.v"
module frequency_meter 
#(
    parameter TIMER1500MS = 28'd72_000_000 - 1,
    parameter TIMER250MS = 28'd12_000_000 - 1,
    parameter TIMER1250MS = 28'd60_000_000 - 1,
    parameter CNT_STAND = 28'd48_000_000//��־ʱ��Ƶ��100M
)
(
    input sys_clk,
    input sys_rst_n,
    input clk_test,//�����ź�
    output reg [31:0]freq//����Ƶ��
);

// seg_auto seg_auto(
//     sys_clk,
//     sys_rst_n,
//     freq,
//     seg,
//     sel  
// );

//ʱ���߼��ͺ�һ��ʱ������
reg[27:0] cnt_gate_s;//���բ�ż�����,1.5s => 72000000
reg gate_s;//���բ��
reg gate_a;//ʵ��բ��
reg [47:0] cnt_clk_test;//����Ƶ�ʼ���
reg [47:0] cnt_clk_test_reg;//�Ĵ汻��Ƶ�ʼ���X
reg [47:0] cnt_clk_stand;//��׼Ƶ�ʼ���
reg [47:0] cnt_clk_stand_reg;//�Ĵ汻��Ƶ�ʼ���Y
reg gate_a_test_reg;//�ڱ����ź���,�Ĵ�ʵ��բ��,�ҵ��½���
reg gate_a_stand_reg;//�ڱ�׼�ź���,�Ĵ�ʵ��բ��,�ҵ��½���

wire gate_a_fall_t;//�����ź������բ���½���
wire gate_a_fall_s;//��׼�ź������բ���½���
wire clk_stand;//100mhz��׼ʱ���ź�

//�õ������ݺ�ʲôʱ�������?�����բ��1.5s��
reg calc_flag;//�����־�ź�
//----------��һ����------------//���բ��gate_s
always @(posedge sys_clk or negedge sys_rst_n)//���բ�ż�����,ǰ0.25sΪ׼��,0.25~1.25�趨Ϊ���բ��,�ܼ���1.25s
    if (!sys_rst_n)
        cnt_gate_s <= 28'd0;
    else if(cnt_gate_s >= TIMER1500MS)
        cnt_gate_s <= 28'd0;
    else
        cnt_gate_s <= cnt_gate_s + 28'd1;

always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        gate_s <= 1'd0;
    else if(cnt_gate_s >= TIMER250MS && cnt_gate_s <= TIMER1250MS)//����Ϊ���բ��
        gate_s <= 1'd1;
    else
        gate_s <= 1'd0;
//----------�ڶ�����------------//ʵ��բ��gate_a
always @(posedge clk_test or negedge sys_rst_n)//ʱ���ź�Ϊ����ʱ���ź�
    if (!sys_rst_n)
        gate_a <= 1'b0;
    else//�Ա���������Ϊ׼��ʼ�趨ʵ��բ��,ʵ��բ�Ű����������ı����ź�����
        gate_a <= gate_s;
//----------��������------------//�����źż���
always @(posedge clk_test or negedge sys_rst_n)//ʱ���ź�Ϊ����ʱ���ź�
    if (!sys_rst_n)
        cnt_clk_test <= 48'd0;
    else if(!gate_a)
        cnt_clk_test <= 48'd0;
    else if(gate_a)//��ʵ��բ����,���������źŵ����ڸ���
        cnt_clk_test <= cnt_clk_test + 1'd1;

always @(posedge clk_test or negedge sys_rst_n)//ʱ���ź�Ϊ����ʱ���ź�
    if (!sys_rst_n)
        gate_a_test_reg <= 1'd0;
    else//��ʵ��բ����,���������źŵ�ʱ��
        gate_a_test_reg <= gate_a;
//�õ�ʵ��բ�ź�һ�������ź�������(�������ź���ʵ��բ���½��ر�־�ź�):�����������ʱ�洢����Ƶ�ʼ���ֵ
assign gate_a_fall_t = ((gate_a_test_reg) && (!gate_a)) ? 1'b1 : 1'b0;

always @(posedge clk_test or negedge sys_rst_n)//ʱ���ź�Ϊ����ʱ���ź�
    if (!sys_rst_n)
        cnt_clk_test_reg <= 48'd0;
    else if(gate_a_fall_t)
        cnt_clk_test_reg <= cnt_clk_test;
//��׼�źż���
always @(posedge clk_stand or negedge sys_rst_n)//ʱ���ź�Ϊ��׼ʱ���ź�
    if (!sys_rst_n)
        cnt_clk_stand <= 48'd0;
    else if(!gate_a)
        cnt_clk_stand <= 48'd0;
    else if(gate_a)//��Ϊʵ��բ�źͱ�׼�ź�������ʱ��ʼ����
        cnt_clk_stand <= cnt_clk_stand + 1'd1;

always @(posedge clk_stand or negedge sys_rst_n)//ʱ���ź�Ϊ��׼ʱ���ź�
    if (!sys_rst_n)
        gate_a_stand_reg <= 1'd0;
    else//��ʵ��բ����,������׼�źŵ�ʱ��
        gate_a_stand_reg <= gate_a;
        
assign gate_a_fall_s = ((gate_a_stand_reg) && (!gate_a)) ? 1'b1 : 1'b0;

always @(posedge clk_stand or negedge sys_rst_n)//ʱ���ź�Ϊ����ʱ���ź�
    if (!sys_rst_n)
        cnt_clk_stand_reg <= 48'd0;
    else if(gate_a_fall_t)
        cnt_clk_stand_reg <= cnt_clk_stand;
//----------���Ĳ���------------//����Ƶ��
always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        calc_flag <= 1'b0;
    else if(cnt_gate_s == TIMER1500MS)
        calc_flag <= 1'b1;
    else
        calc_flag <= 1'b0;

always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        freq <= 32'd0;
    else if(calc_flag)
        freq <= (CNT_STAND / cnt_clk_stand_reg * cnt_clk_test_reg);

endmodule