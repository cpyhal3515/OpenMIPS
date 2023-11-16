//---------------------------- data_ram.v ----------------------------//
// data_ram.v 用来做数据寄存器
`include "../Include/define.v"
module data_ram(
    input clk,
    input ce,
    input we,
    input [`DataBus] data_i,
    input [`DataAddressBus] addr,
    input [3:0] sel,
    output reg [`DataBus] data_o
);
    // 定义四个字节数组
    reg [`ByteWidth] data_mem0 [0:`DataMemoryNumber - 1];
    reg [`ByteWidth] data_mem1 [0:`DataMemoryNumber - 1];
    reg [`ByteWidth] data_mem2 [0:`DataMemoryNumber - 1];
    reg [`ByteWidth] data_mem3 [0:`DataMemoryNumber - 1];

    // 写的部分，注意写的部分需要与时钟同步
    always @(posedge clk) begin
        if(we == `WriteEnable) begin
            if(sel[3] == 1'b1) 
                data_mem3[addr[`DataMemoryNumLog2+1:2]] = data_i[32:24];
            if(sel[2] == 1'b1)
                data_mem2[addr[`DataMemoryNumLog2+1:2]] = data_i[23:16];
            if(sel[1] == 1'b1)
                data_mem1[addr[`DataMemoryNumLog2+1:2]] = data_i[15:8];
            if(sel[0] == 1'b1)
                data_mem0[addr[`DataMemoryNumLog2+1:2]] = data_i[7:0];
        end

    end


    // 读的部分
    always @(*) begin
        if(ce == `ChipDisable) 
            data_o = `ZeroWord;
        else begin
            if(we == `WriteDisable)
                data_o = {data_mem3[addr[`DataMemoryNumLog2+1:2]], data_mem2[addr[`DataMemoryNumLog2+1:2]], 
                            data_mem1[addr[`DataMemoryNumLog2+1:2]], data_mem0[addr[`DataMemoryNumLog2+1:2]]};
            else
                data_o = `ZeroWord;
        end

    end

    
endmodule