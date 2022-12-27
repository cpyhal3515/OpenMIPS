//---------------------------- ex_mem.v ----------------------------//
// 就是一个寄存器，作为流水线不同功能模块之间打拍的部分
`include "../Include/define.v"
module ex_mem (
    input clk,
    input rst,

    input [`RegisterBus] ex_wdata,
    input [`RegisterAddressBus] ex_wd,
    input ex_wreg,

    output reg [`RegisterBus] mem_wdata,
    output reg [`RegisterAddressBus] mem_wd,
    output reg mem_wreg

);



always@(posedge clk) begin
    if(rst == `ResetEnable) begin
        mem_wdata   <= `ZeroWord;
        mem_wd      <= `NOPRegisterAddress;
        mem_wreg    <= `WriteDisable;
    end
    else begin
        mem_wdata   <= ex_wdata;
        mem_wd      <= ex_wd;
        mem_wreg    <= ex_wreg;        

    end
end

    
endmodule