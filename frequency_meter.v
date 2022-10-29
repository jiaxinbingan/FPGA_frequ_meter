#`include "src\seg_auto.v"
module frequency_meter 
#(
    parameter TIMER1500MS = 28'd72_000_000 - 1,
    parameter TIMER250MS = 28'd12_000_000 - 1,
    parameter TIMER1250MS = 28'd60_000_000 - 1,
    parameter CNT_STAND = 28'd48_000_000//标志时钟频率100M
)
(
    input sys_clk,
    input sys_rst_n,
    input clk_test,//待测信号
    output reg [31:0]freq//计算频率
);

// seg_auto seg_auto(
//     sys_clk,
//     sys_rst_n,
//     freq,
//     seg,
//     sel  
// );

//时序逻辑滞后一个时钟周期
reg[27:0] cnt_gate_s;//软件闸门计数器,1.5s => 72000000
reg gate_s;//软件闸门
reg gate_a;//实际闸门
reg [47:0] cnt_clk_test;//被测频率计数
reg [47:0] cnt_clk_test_reg;//寄存被测频率计数X
reg [47:0] cnt_clk_stand;//标准频率计数
reg [47:0] cnt_clk_stand_reg;//寄存被测频率计数Y
reg gate_a_test_reg;//在被测信号下,寄存实际闸门,找到下降沿
reg gate_a_stand_reg;//在标准信号下,寄存实际闸门,找到下降沿

wire gate_a_fall_t;//被测信号下软件闸门下降沿
wire gate_a_fall_s;//标准信号下软件闸门下降沿
wire clk_stand;//100mhz标准时钟信号

//得到了数据后什么时候计算呢?在软件闸门1.5s后
reg calc_flag;//计算标志信号
//----------第一部分------------//软件闸门gate_s
always @(posedge sys_clk or negedge sys_rst_n)//软件闸门计数器,前0.25s为准备,0.25~1.25设定为软件闸门,总计数1.25s
    if (!sys_rst_n)
        cnt_gate_s <= 28'd0;
    else if(cnt_gate_s >= TIMER1500MS)
        cnt_gate_s <= 28'd0;
    else
        cnt_gate_s <= cnt_gate_s + 28'd1;

always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        gate_s <= 1'd0;
    else if(cnt_gate_s >= TIMER250MS && cnt_gate_s <= TIMER1250MS)//设置为软件闸门
        gate_s <= 1'd1;
    else
        gate_s <= 1'd0;
//----------第二部分------------//实际闸门gate_a
always @(posedge clk_test or negedge sys_rst_n)//时钟信号为被测时钟信号
    if (!sys_rst_n)
        gate_a <= 1'b0;
    else//以被测上升沿为准开始设定实际闸门,实际闸门包括整数倍的被测信号周期
        gate_a <= gate_s;
//----------第三部分------------//被测信号计数
always @(posedge clk_test or negedge sys_rst_n)//时钟信号为被测时钟信号
    if (!sys_rst_n)
        cnt_clk_test <= 48'd0;
    else if(!gate_a)
        cnt_clk_test <= 48'd0;
    else if(gate_a)//在实际闸门下,计数被测信号的周期个数
        cnt_clk_test <= cnt_clk_test + 1'd1;

always @(posedge clk_test or negedge sys_rst_n)//时钟信号为被测时钟信号
    if (!sys_rst_n)
        gate_a_test_reg <= 1'd0;
    else//在实际闸门下,计数被测信号的时间
        gate_a_test_reg <= gate_a;
//得到实际闸门后一个被测信号上升沿(即被测信号下实际闸门下降沿标志信号):在这个上升沿时存储被测频率计数值
assign gate_a_fall_t = ((gate_a_test_reg) && (!gate_a)) ? 1'b1 : 1'b0;

always @(posedge clk_test or negedge sys_rst_n)//时钟信号为被测时钟信号
    if (!sys_rst_n)
        cnt_clk_test_reg <= 48'd0;
    else if(gate_a_fall_t)
        cnt_clk_test_reg <= cnt_clk_test;
//标准信号计数
always @(posedge clk_stand or negedge sys_rst_n)//时钟信号为标准时钟信号
    if (!sys_rst_n)
        cnt_clk_stand <= 48'd0;
    else if(!gate_a)
        cnt_clk_stand <= 48'd0;
    else if(gate_a)//当为实际闸门和标准信号上升沿时开始计数
        cnt_clk_stand <= cnt_clk_stand + 1'd1;

always @(posedge clk_stand or negedge sys_rst_n)//时钟信号为标准时钟信号
    if (!sys_rst_n)
        gate_a_stand_reg <= 1'd0;
    else//在实际闸门下,计数标准信号的时间
        gate_a_stand_reg <= gate_a;
        
assign gate_a_fall_s = ((gate_a_stand_reg) && (!gate_a)) ? 1'b1 : 1'b0;

always @(posedge clk_stand or negedge sys_rst_n)//时钟信号为被测时钟信号
    if (!sys_rst_n)
        cnt_clk_stand_reg <= 48'd0;
    else if(gate_a_fall_t)
        cnt_clk_stand_reg <= cnt_clk_stand;
//----------第四部分------------//计算频率
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