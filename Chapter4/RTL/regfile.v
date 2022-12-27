//---------------------------- regfile.v ----------------------------//
// 通用寄存器，包括写与读
`include "../Include/define.v"
module regfile (
    input clk,
    input rst,

    input re1,
    input [`RegisterAddressBus] raddr1,
    input re2,
    input [`RegisterAddressBus] raddr2,

    input we,
    input [`RegisterAddressBus] waddr,
    input [`RegisterBus] wdata,

    output reg [`RegisterBus] rdata1,
    output reg [`RegisterBus] rdata2

);


//------------------------------------------------------------------//
// 定义通用寄存器，一共 32 个通用寄存器，每个通用寄存器的大小为 32 bits
reg [`RegisterBus] InstMemory [0:`RegisterNum-1];

//------------------------------------------------------------------//
// 完成对寄存器的写操作
// 写寄存器操作是时序逻辑电路，写操作发生在时钟信号的上升沿

always@(posedge clk) begin 
    // 通用寄存器的 $0 寄存器是不用的，因此不要去写它
    if(rst == `ResetDisable && we == `WriteEnable && waddr != `RegisterNumLog2'h0)
        InstMemory[waddr] = wdata; 
end

//------------------------------------------------------------------//
// 完成对通用寄存器的读操作
// 读寄存器操作是组合逻辑电路，也就是一旦输入的要读取的寄存器地址 raddr1 或者
// raddr2 发生变化，那么会立即给出新地址对应的寄存器的值，这样可以保证在译码阶段
// 取得要读取的寄存器的值
always@(*) begin
    if(rst == `ResetEnable || re1 == `ReadDisable || raddr1 == `RegisterNumLog2'h0)
        rdata1 = `ZeroWord;
    else begin
        if(waddr == raddr1 && we == `WriteEnable)
            rdata1 = wdata;
        else
            rdata1 = InstMemory[raddr1];
    end
end


always@(*) begin
    if(rst == `ResetEnable || re2 == `ReadDisable || raddr2 == `RegisterNumLog2'h0)
        rdata2 = `ZeroWord;
    else begin
        if(waddr == raddr2 && we == `WriteEnable)
            rdata2 = wdata;
        else
            rdata2 = InstMemory[raddr2];
    end
end

endmodule