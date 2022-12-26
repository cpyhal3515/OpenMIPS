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
`define EXE_ORI          6'b001101
`define EXE_NOP          6'b000000

// AluOp
`define EXE_OR_OP           8'b00100101
`define EXE_NOR_OP          8'b00100111

// AluSel
`define EXE_RES_LOGIC       3'b001
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





