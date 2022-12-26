//---------------------------- id_ex.v ----------------------------//
// 根据指令完成运算
// 首先根据 id 模块输出的 OP 计算 logic 的结果或者 shift 的结果
// 后面再增加一级 MUX 
// 根据 EXE_RES 的值确定具体的选通逻辑，是输出 logic 的结果，还是输出 shift 的结果
`include "../Include/define.v"
module ex (

    input rst,
    input [`ALUOpBus] aluop_i,
    input [`ALUSelBus] alusel_i,
    input [`RegisterBus] reg1_i,
    input [`RegisterBus] reg2_i,
    input [`RegisterAddressBus] wd_i,
    input wreg_i,

    output reg [`RegisterBus] wdata_o,
    output [`RegisterAddressBus] wd_o,
    output wreg_o


);

    assign wreg_o = wreg_i;
    assign wd_o = wd_i;

    reg [`RegisterBus] logic_calu;
    reg [`RegisterBus] shift_calu;

    // 完成算数运算的计算结果
    always@(*) begin
        if(rst == `ResetEnable)
            logic_calu = `ZeroWord;
        else
            case (aluop_i)
                // 或
                `EXE_OR_OP:  logic_calu = reg1_i | reg2_i;
                // 与
                `EXE_AND_OP: logic_calu = reg1_i & reg2_i;
                // 异或
                `EXE_XOR_OP: logic_calu = reg1_i ^ reg2_i;
                // 或非
                `EXE_NOR_OP: logic_calu = ~(reg1_i | reg2_i); 
                default: logic_calu = `ZeroWord;
            endcase
    end

    // 完成移位操作的计算结果
    always@(*) begin
        if(rst == `ResetEnable)
            shift_calu = `ZeroWord;
        else
            case (aluop_i)
                // 逻辑左移
                `EXE_SLL_OP:  shift_calu = reg2_i << reg1_i[4:0];
                // 逻辑右移
                `EXE_SRL_OP:  shift_calu = reg2_i >> reg1_i[4:0];
                // 算数右移
                `EXE_SRA_OP:  shift_calu = ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
                default: shift_calu = `ZeroWord;
            endcase
    end

    // 选通输出 logic 还是 shift 的计算结果
    always@(*) begin
        if(rst == `ResetEnable)
            wdata_o = `ZeroWord;
        else
            case (alusel_i)
                `EXE_RES_LOGIC: wdata_o = logic_calu;
                `EXE_RES_SHIFT: wdata_o = shift_calu;
                default: wdata_o = `ZeroWord;
            endcase
    end

    
endmodule