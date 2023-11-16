 //---------------------------- if_id.v ----------------------------//
// 就是一个寄存器，作为流水线不同功能模块之间打拍的部分
`include "../Include/define.v"
module if_id(
    input clk,
    input rst,
    input [`InstAddressBus] if_pc,
    input [`InstDataBus] if_inst,
    input [5:0] stall,
    input flush,
    output reg [`InstAddressBus] id_pc,
    output reg [`InstDataBus] id_inst
);
    always@(posedge clk) begin
        if(rst == `ResetEnable) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        else begin
            if(flush == 1'b1) begin
                id_pc <= `ZeroWord;
                id_inst <= `ZeroWord;
            end

            else if(stall[2] == `NoStop && stall[1] == `Stop) begin
                id_pc <= `ZeroWord;
                id_inst <= `ZeroWord;
            end
            else if(stall[1] == `NoStop) begin
                id_pc <= if_pc;
                id_inst <= if_inst;
            end
        end    
    end


    
endmodule