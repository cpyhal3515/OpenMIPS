//---------------------------- pc_reg.v ----------------------------//
// pc_reg.v 用来取址，主要有两个功能：
// 1. ce 作为指令寄存器的使能值
// 2. pc ，当 ce 使能后每个 clk，pc 自增 4
`include "../Include/define.v"
module pc_reg(
    input clk,
    input rst,
    input [5:0] stall,
    input branch_flag_i,
    input [`RegisterBus] branch_target_address_i,
    input flush,
    input [`InstAddressBus] new_pc,
    
    output reg [`InstAddressBus] pc,    
    output reg ce
);
    always @(posedge clk) begin
        if(rst == `ResetEnable)         // 复位时指令寄存器 disabled
            ce <= `ChipDisable;
        else                            // 复位完成后指令寄存器 enabled
            ce <= `ChipEnable;
    end

    always @(posedge clk) begin
        if(ce == `ChipDisable)          // 指令寄存器 disabled 时 pc = 0 
            pc <= `ZeroWord;
        else                            // 指令寄存器 enabled 时，每过一个 clk，pc 自增 4
            if(flush == 1'b1)
                pc <= new_pc;
            else if(stall[0] == `NoStop) begin
                // 如果跳转有效则将下一个 PC 地址赋值成目标跳转地址
                if(branch_flag_i == `Branch)
                    pc <= branch_target_address_i;
                else
                    pc <= pc + 4'd4;
            end
    end
endmodule