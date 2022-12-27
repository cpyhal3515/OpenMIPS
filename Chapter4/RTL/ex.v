//---------------------------- id_ex.v ----------------------------//
// 根据指令完成运算
// 首先根据 id 模块输出的 OP 计算 logic 的结果
// 后面再增加一级 MUX 
// 根据 EXE_RES 的值确定具体的选通逻辑，输出 logic 的结果
`include "../Include/define.v"
module ex (

    // 译码阶段送到执行阶段的信息
    input rst,
    input [`ALUOpBus] aluop_i,
    input [`ALUSelBus] alusel_i,
    input [`RegisterBus] reg1_i,
    input [`RegisterBus] reg2_i,
    input [`RegisterAddressBus] wd_i,
    input wreg_i,

    // 执行的结果
    output reg [`RegisterBus] wdata_o,
    output [`RegisterAddressBus] wd_o,
    output wreg_o


);

    assign wreg_o = wreg_i;
    assign wd_o = wd_i;

    // 保存逻辑运算的结果
    reg [`RegisterBus] logic_calu;

    // 依据 aluop_i 指示的运算子类型进行运算
    always@(*) begin
        if(rst == `ResetEnable)
            logic_calu = `ZeroWord;
        else
            case (aluop_i)
                `EXE_OR_OP: logic_calu = reg1_i | reg2_i;
                default: logic_calu = `ZeroWord;
            endcase
    end

    // 依据 alusel_i 指示的运算类型，选择一个运算结果作为最终结果
    always@(*) begin
        if(rst == `ResetEnable)
            wdata_o = `ZeroWord;
        else
            case (alusel_i)
                `EXE_RES_LOGIC: wdata_o = logic_calu;
                default: wdata_o = `ZeroWord;
            endcase
    end

    
endmodule