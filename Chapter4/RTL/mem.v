//---------------------------- mem.v ----------------------------//
// 访存部分，这里暂时还没有用到，因此直接用 wire 连接输入与输出端口
`include "../Include/define.v"
module mem (
    input rst,
    input [`RegisterBus] wdata_i,
    input [`RegisterAddressBus] wd_i,
    input wreg_i,

    output reg [`RegisterBus] wdata_o,
    output reg [`RegisterAddressBus] wd_o,
    output reg wreg_o

);


always @(*) begin
    if(rst == `ResetEnable) begin
        wdata_o = `ZeroWord;
        wd_o = `NOPRegisterAddress;
        wreg_o = `WriteDisable;
    end
    else begin
        wdata_o = wdata_i;
        wd_o = wd_i;
        wreg_o = wreg_i;  
    end 

    
end




    
endmodule