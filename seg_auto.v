module seg_auto
#(
    parameter TIMER_1MS = 32'd48_000 - 1,//
    parameter TIMER_1S = 32'd48_000_000 - 1,//
    parameter MAX_num = 20'd999_999//后两位数码管最大显示数字
)
(
    input sys_clk,
    input sys_rst_n,
    //input freq,
    output reg[7:0] seg,
    output reg[7:0] sel
);

reg[31:0] cnt;
reg[31:0] cnt_1s;
reg[6:0] data;
reg[3:0] data_sel;//位选改变
reg[27:0] num;
//定时器1ms
always @(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt <= 0;
    else if(cnt <= TIMER_1MS)
        cnt <= cnt + 1;
    else
        cnt <= 0;
//定时器1s
always @(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt_1s <= 0;
    else if(cnt_1s <= TIMER_1S)
        cnt_1s <= cnt_1s + 1;
    else
        cnt_1s <= 0;
//计数量
always @(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        num <= 8'd0;
    else if( (cnt_1s == TIMER_1S) && (num == MAX_num) )
        num <= 8'd0;
    else if( cnt_1s == TIMER_1S )
        num <= num+ 8'd1;
    else
        num <= num;
//输出位选择
always @(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        data_sel <= 3'd0;
    else if( (cnt == TIMER_1MS) && (data_sel >= 3'd7) )
        data_sel <= 3'd0;
    else if( cnt == TIMER_1MS )
        data_sel <= data_sel + 3'd1;
//位选
always @(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n)
        sel <= 8'b1111_1111;
    else
        sel <= ~(8'b0000_0001 << data_sel);
//
always @(posedge sys_clk or negedge sys_rst_n) 
begin
    if(!sys_rst_n)
        seg <= 8'hff;//1111 1111
    else if(sel == 8'b1111_1110)//0
    begin
        data <= num % 10;
        case (data)
            0:   seg <= 8'hc0;//1010 0000
            1:   seg <= 8'hf9;
            2:   seg <= 8'ha4;
            3:   seg <= 8'hb0;
            4:   seg <= 8'h99;
            5:   seg <= 8'h92;
            6:   seg <= 8'h82;
            7:   seg <= 8'hf8;
            8:   seg <= 8'h80;
            9:   seg <= 8'h90;
            default:seg <= 8'hc0; 
        endcase
    end
    else if(sel == 8'b1111_1101)//1
    begin
        data <= num / 10 % 10;
        case (data)
            4'd0:   seg <= 8'hc0;//1010 0000
            4'd1:   seg <= 8'hf9;
            4'd2:   seg <= 8'ha4;
            4'd3:   seg <= 8'hb0;
            4'd4:   seg <= 8'h99;
            4'd5:   seg <= 8'h92;
            4'd6:   seg <= 8'h82;
            4'd7:   seg <= 8'hf8;
            4'd8:   seg <= 8'h80;
            4'd9:   seg <= 8'h90;
            default:seg <= 8'hc0; 
        endcase
    end
    else if(sel == 8'b1111_1011)//2
    begin
        data <= num / 100 % 10;
        case (data)
            4'd0:   seg <= 8'hc0;//1010 0000
            4'd1:   seg <= 8'hf9;
            4'd2:   seg <= 8'ha4;
            4'd3:   seg <= 8'hb0;
            4'd4:   seg <= 8'h99;
            4'd5:   seg <= 8'h92;
            4'd6:   seg <= 8'h82;
            4'd7:   seg <= 8'hf8;
            4'd8:   seg <= 8'h80;
            4'd9:   seg <= 8'h90;
            default:seg <= 8'hc0; 
        endcase
    end
    else if(sel == 8'b1111_0111)//3
    begin
        data <= num / 1000 % 10;
        case (data)
            0:   seg <= 8'hc0;//1010 0000
            1:   seg <= 8'hf9;
            2:   seg <= 8'ha4;
            3:   seg <= 8'hb0;
            4:   seg <= 8'h99;
            5:   seg <= 8'h92;
            6:   seg <= 8'h82;
            7:   seg <= 8'hf8;
            8:   seg <= 8'h80;
            9:   seg <= 8'h90;
            default:seg <= 8'hc0; 
        endcase
    end
    else if(sel == 8'b1110_1111)//4
    begin
        data = num / 10000 % 10;
        case (data)
            4'd0:   seg <= 8'hc0;//1010 0000
            4'd1:   seg <= 8'hf9;
            4'd2:   seg <= 8'ha4;
            4'd3:   seg <= 8'hb0;
            4'd4:   seg <= 8'h99;
            4'd5:   seg <= 8'h92;
            4'd6:   seg <= 8'h82;
            4'd7:   seg <= 8'hf8;
            4'd8:   seg <= 8'h80;
            4'd9:   seg <= 8'h90;
            default:seg <= 8'hc0; 
        endcase
    end
    else if(sel == 8'b1101_1111)//5
    begin
        data = num / 100000 % 10;
        case (data)
            4'd0:   seg <= 8'hc0;//1010 0000
            4'd1:   seg <= 8'hf9;
            4'd2:   seg <= 8'ha4;
            4'd3:   seg <= 8'hb0;
            4'd4:   seg <= 8'h99;
            4'd5:   seg <= 8'h92;
            4'd6:   seg <= 8'h82;
            4'd7:   seg <= 8'hf8;
            4'd8:   seg <= 8'h80;
            4'd9:   seg <= 8'h90;
            default:seg <= 8'hc0; 
        endcase
    end
    else if(sel == 8'b1011_1111)//6
    begin
        data = num / 1000000 % 10;
        case (data)
            0:   seg <= 8'hc0;//1010 0000
            1:   seg <= 8'hf9;
            2:   seg <= 8'ha4;
            3:   seg <= 8'hb0;
            4:   seg <= 8'h99;
            5:   seg <= 8'h92;
            6:   seg <= 8'h82;
            7:   seg <= 8'hf8;
            8:   seg <= 8'h80;
            9:   seg <= 8'h90;
            default:seg <= 8'hc0; 
        endcase
    end
    else if(sel == 8'b0111_1111)//7
    begin
        data = num / 10000000 % 10;
        case (data)
            4'd0:   seg <= 8'hc0;//1010 0000
            4'd1:   seg <= 8'hf9;
            4'd2:   seg <= 8'ha4;
            4'd3:   seg <= 8'hb0;
            4'd4:   seg <= 8'h99;
            4'd5:   seg <= 8'h92;
            4'd6:   seg <= 8'h82;
            4'd7:   seg <= 8'hf8;
            4'd8:   seg <= 8'h80;
            4'd9:   seg <= 8'h90;
            default:seg <= 8'hc0; 
        endcase
    end
    else  
        seg <= 8'b1111_1111;
end
endmodule
