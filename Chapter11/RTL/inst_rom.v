//---------------------------- inst_rom.v ----------------------------//
// inst_rom.v 用来做指令寄存器
`include "../Include/define.v"
module inst_rom (
    input  ce,
    input  [`InstAddressBus] addr,
    output reg [`InstDataBus] inst
);

// inst_mem 为指令寄存器，指令宽�?? InstDataBus，寄存器深度 InstMemoryNum
reg [`InstDataBus] inst_mem [0:`InstMemoryNum-1];

// 指令寄存器使�?? readmemh 进行初始�??
// inst_rom.data 文件�??要在 Linux 下采�?? mips 相关的工�?? make
initial begin
    $readmemh("E:/Master/WorkSpace/OpenMIPS/Chapter10/Data/inst_rom10.data", inst_mem);
end

// 采用组合逻辑根据输入的地�??给出对应的指�??
// �??要注意的是，因为采用的是字寻�??，因此需要将 openmips 给出的地�??除以 4 （将指令地址右移 2 位）
always @(*) begin
    if(ce == `ChipDisable)
        inst = `ZeroWord;
    else
        inst = inst_mem[addr[`InstMemoryNumLog2+1:2]];
end

endmodule