`timescale 1ns/1ps
//---------------------------- 全局宏定义 ----------------------------//
`define ResetEnable         1'b1            // 复位信号有效
`define ResetDisable        1'b0            // 复位信号无效
`define ZeroWord            32'h00000000    // 32 位的数值 0
`define WriteEnable         1'b1            // 使能写
`define WriteDisable        1'b0            // 禁止写
`define ReadEnable          1'b1            // 使能读
`define ReadDisable         1'b0            // 禁止读
`define ALUOpBus            7:0             // 译码阶段的输出 aluop_o 的宽度
`define ALUSelBus           2:0             // 译码阶段的输出 alusel_o 的宽度
`define InstructionValid    1'b1            // 指令有效
`define InstructionInvalid  1'b0            // 指令无效
`define TrueValue           1'b1            // 逻辑 “真”
`define FalseValue          1'b0            // 逻辑 “假”
`define ChipEnable          1'b1            // 芯片使能
`define ChipDisable         1'b0            // 芯片禁止

//---------------------------- 与具体指令有关的宏定义 ----------------------------//
// Logic EXE
`define EXE_ORI          6'b001101          // 指令 ori 的指令码  
`define EXE_NOP          6'b000000

// AluOp
`define EXE_OR_OP           8'b00100101
`define EXE_NOR_OP          8'b00100111

// AluSel
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_NOP         3'b000

//---------------------------- 与指令存储器 ROM 有关的宏定义 ----------------------------//
`define InstAddressBus      31:0      // ROM 的地址总线宽度
`define InstDataBus         31:0      // ROM 的数据总线宽度
`define InstMemoryNum       131071    // ROM 的实际大小为 128KB
`define InstMemoryNumLog2   17        // ROM 实际使用的地址线宽度

//---------------------------- 与通用寄存器 Regfile 有关的宏定义 ----------------------------//
`define RegisterAddressBus  4:0       // Regfile 模块的地址线宽度
`define RegisterBus         31:0      // Regfile 模块的数据线宽度
`define RegisterWidth       32        // 通用寄存器的宽度
`define DoubleRegisterWidth 64        // 两倍的通用寄存器的宽度
`define DoubleRegisterBus   63:0      // 两倍的通用寄存器的数据线宽度
`define RegisterNum         32        // 通用寄存器的数量
`define RegisterNumLog2     5         // 寻址通用寄存器使用的地址位数
`define NOPRegisterAddress  5'b00000





