//---------------------------- id.v ----------------------------//
// Complete the operation decoding
`include "../Include/define.v"
module id (
    input rst,
    input [`InstAddressBus] pc_i,
    input [`InstDataBus] inst_i,
    input [`RegisterBus] reg1_data_i,
    input [`RegisterBus] reg2_data_i,

    output reg [`ALUOpBus] aluop_o,
    output reg [`ALUSelBus] alusel_o,

    
    output reg [`RegisterAddressBus] wd_o,
    output reg wreg_o,
    
    output reg [`RegisterBus] reg1_o,
    output reg [`RegisterAddressBus] reg1_addr_o,
    output reg reg1_read_o,

    output reg [`RegisterBus] reg2_o,
    output reg [`RegisterAddressBus] reg2_addr_o,
    output reg reg2_read_o
);

wire [5:0] op = inst_i[31:26];
reg  [`RegisterBus] immediate;

//------------------------------------------------------------------//
// do corresponding assignment according to the operand op
always@(*) begin
    if(rst == `ResetEnable) begin
        aluop_o = `EXE_NOR_OP;
        alusel_o = `EXE_RES_NOP;
        wd_o = `NOPRegisterAddress;
        wreg_o = `WriteDisable;

        reg1_addr_o = `NOPRegisterAddress;
        reg1_read_o = 1'b0;

        reg2_addr_o = `NOPRegisterAddress;
        reg2_read_o = 1'b0;

        immediate = `ZeroWord;
    end
    else
        case(op)
            `EXE_ORI: begin
                aluop_o = `EXE_OR_OP;
                alusel_o = `EXE_RES_LOGIC;
                wd_o = inst_i[20:16];
                wreg_o = `WriteEnable;

                reg1_addr_o = inst_i[25:21];
                reg1_read_o = 1'b1;

                reg2_addr_o = `NOPRegisterAddress;
                reg2_read_o = 1'b0;

                immediate = {16'd0, inst_i[15:0]};
            end
            default: begin

                aluop_o = `EXE_NOR_OP;
                alusel_o = `EXE_RES_NOP;
                wd_o = inst_i[15:11];
                wreg_o = `WriteDisable;

                reg1_addr_o = inst_i[25:21];
                reg1_read_o = 1'b0;

                reg2_addr_o = inst_i[20:16];
                reg2_read_o = 1'b0;

                immediate = `ZeroWord;

            end
        endcase

    end

//------------------------------------------------------------------//
// Complete the MUX output of the data
always@(*) begin
    if(rst == `ResetEnable) 
        reg1_o = `ZeroWord;
    else begin
        if(reg1_read_o == 1'b1) 
            reg1_o = reg1_data_i;
        else
           reg1_o = immediate;

    end

end
//------------------------------------------------------------------//
// Complete the MUX output of the data
always@(*) begin
    if(rst == `ResetEnable) 
        reg2_o = `ZeroWord;
    else begin
        if(reg2_read_o == 1'b1) 
            reg2_o = reg1_data_i;
        else
           reg2_o = immediate; 
    end

end

endmodule