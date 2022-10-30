module top_freq(
    input sys_clk,
    input sys_rst_n,
    input clk_test,
    output wire[7:0] seg,
    output wire[7:0] sel
);

wire [31:0] freq;
frequency_meter frequency_meter_top(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .clk_test(clk_test),//´ý²âÐÅºÅ
    .freq(freq)
);

seg_auto seg_auto_top(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .freq(freq),
    .seg(seg),
    .sel(sel)
);
endmodule