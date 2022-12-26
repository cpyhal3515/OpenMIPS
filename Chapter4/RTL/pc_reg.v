//---------------------------- pc_reg.v ----------------------------//
// There are two main functions:
// 1. ce is enable value of instruction register.
// 2. pc adds 4 every clock when ce is enabled.
`include "../Include/define.v"
module pc_reg(
    input clk,
    input rst,
    output reg [`InstAddressBus] pc,    // Question: why InstAddressBus 31:0
    output reg ce
);
    always @(posedge clk) begin
        if(rst == `ResetEnable)         // Instruction memory is disabled when reset
            ce <= `ChipDisable;
        else                            // Instruction memory is enabled after reset
            ce <= `ChipEnable;
    end

    always @(posedge clk) begin
        if(ce == `ChipDisable)          // When instruction memory is disabled, pc is 0
            pc <= `ZeroWord;
        else                            // When instruction memory is enabled, pc adds 4 every clock
            pc <= pc + 4'd4;
    end
endmodule