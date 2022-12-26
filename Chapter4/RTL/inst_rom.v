`include "../Include/define.v"
module inst_rom (
    input  ce,
    input  [`InstAddressBus] addr,
    output reg [`InstDataBus] inst
);

reg [`InstDataBus] inst_mem [0:`InstMemoryNum-1];

initial begin
    $readmemh("E:/Master/WorkSpace/OpenMIPS/Chapter4/Data/inst_rom.data", inst_mem);
end

always @(*) begin
    if(ce == `ChipDisable)
        inst = `ZeroWord;
    else
        inst = inst_mem[addr[`InstMemoryNumLog2+1:2]];
end



    
endmodule