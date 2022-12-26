`timescale 1ns/1ps
//---------------------------- Global Macro Definitions ----------------------------//
`define ResetEnable         1'b1
`define ResetDisable        1'b0
`define ZeroWord            32'h00000000
`define WriteEnable         1'b1
`define WriteDisable        1'b0
`define ReadEnable          1'b1
`define ReadDisable         1'b0
`define ALUOpBus            7:0
`define ALUSelBus           2:0
`define InstructionValid    1'b1
`define InstructionInvalid  1'b0
`define TrueValue           1'b1
`define FalseValue          1'b0
`define ChipEnable          1'b1
`define ChipDisable         1'b0

//---------------------------- Instruction ----------------------------//
// Logic EXE
`define EXE_NOP  6'b000000

`define EXE_AND  6'b100100      // 指令and的功能码
`define EXE_OR   6'b100101      // 指令ori的功能码
`define EXE_XOR  6'b100110      // 指令xor的功能码
`define EXE_NOR  6'b100111      // 指令nor的功能码
`define EXE_ANDI 6'b001100      // 指令andi的指令码
`define EXE_ORI  6'b001101      // 指令ori的指令码
`define EXE_XORI 6'b001110      // 指令xori的指令码
`define EXE_LUI  6'b001111      // 指令lui的指令码

`define EXE_SLL  6'b000000      // 指令sll的功能码
`define EXE_SLLV 6'b000100      // 指令sllv的功能码
`define EXE_SRL  6'b000010      // 指令srl的功能码
`define EXE_SRLV 6'b000110      // 指令srlv的功能码
`define EXE_SRA  6'b000011      // 指令sra的功能码
`define EXE_SRAV 6'b000111      // 指令srav的功能码
`define EXE_SYNC 6'b001111      // 指令sync的功能码
`define EXE_PREF 6'b110011      // 指令pref的功能码

`define EXE_MOVZ  6'b001010     //指令MOVZ的功能码
`define EXE_MOVN  6'b001011     //指令MOVN的功能码
`define EXE_MFHI  6'b010000     //指令MFHI的功能码
`define EXE_MTHI  6'b010001     //指令MTHI的功能码
`define EXE_MFLO  6'b010010     //指令MFLO的功能码
`define EXE_MTLO  6'b010011     //指令MTLO的功能码

`define EXE_SPECIAL_INST 6'b000000 //指令special的指令码
// AluOp
// 空指令
`define EXE_NOP_OP 8'b00000000
// 逻辑指令
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP   8'b00100110
`define EXE_NOR_OP   8'b00100111
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP   8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP   8'b01011100   
// 移位指令
`define EXE_SLL_OP   8'b01111100
`define EXE_SRL_OP   8'b00000010
`define EXE_SRA_OP   8'b00000011
// 转移指令
`define EXE_MOVZ_OP  8'b00001010
`define EXE_MOVN_OP  8'b00001011
`define EXE_MFHI_OP  8'b00010000
`define EXE_MTHI_OP  8'b00010001
`define EXE_MFLO_OP  8'b00010010
`define EXE_MTLO_OP  8'b00010011

// AluSel
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_SHIFT       3'b010
`define EXE_RES_MOVE        3'b011
`define EXE_RES_NOP         3'b000

//---------------------------- Instruction Memory ----------------------------//
`define InstAddressBus      31:0
`define InstDataBus         31:0      // The bus width of the instruction is 32 bits.
`define InstMemoryNum       131071
`define InstMemoryNumLog2   17

//---------------------------- General Purpose Registers ----------------------------//
`define RegisterAddressBus  4:0
`define RegisterBus         31:0
`define RegisterWidth       32
`define DoubleRegisterWidth 64
`define DoubleRegisterBus   63:0
`define RegisterNum         32
`define RegisterNumLog2     5
`define NOPRegisterAddress  5'b00000





