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

    input [`RegisterBus] hi_i,
    input [`RegisterBus] lo_i,

    input wb_whilo_i,
    input [`RegisterBus] wb_hi_i,
    input [`RegisterBus] wb_lo_i,

    input mem_whilo_i,
    input [`RegisterBus] mem_hi_i,
    input [`RegisterBus] mem_lo_i,

    output reg [`RegisterBus] wdata_o,
    output [`RegisterAddressBus] wd_o,
    output wreg_o,

    output reg whilo_o,
    output reg [`RegisterBus] hi_o,
    output reg [`RegisterBus] lo_o


);

    assign wreg_o = wreg_i;
    assign wd_o = wd_i;

    reg [`RegisterBus] logic_calu;
    reg [`RegisterBus] shift_calu;
    reg [`RegisterBus] move_calu;

    reg [`RegisterBus] HI, LO;

    always @(*) begin
        if(rst == `ResetEnable) 
            {HI, LO} = {`ZeroWord, `ZeroWord};
        else
            if(mem_whilo_i == `WriteEnable)
                {HI, LO} = {mem_hi_i, mem_lo_i}; 
            else if(wb_whilo_i == `WriteEnable)
                {HI, LO} = {wb_hi_i, wb_lo_i};
            else
                {HI, LO} = {hi_i, lo_i};
    end

    always @(*) begin
        if(rst == `ResetEnable)
            move_calu = `ZeroWord;
        else
            case (aluop_i)
                `EXE_MFHI_OP: move_calu = HI;
                `EXE_MFLO_OP: move_calu = LO;
                `EXE_MOVN_OP: move_calu = reg1_i;
                `EXE_MOVZ_OP: move_calu = reg1_i;
                default: begin end
            endcase
    end

    always @(*) begin
        if(rst == `ResetEnable) begin
            whilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end
        else
            case (aluop_i)
                `EXE_MTHI_OP:  begin
                    hi_o = reg1_i;
                    lo_o = LO;
                    whilo_o = `WriteEnable;
                end
                `EXE_MTLO_OP:  begin
                    hi_o = HI;
                    lo_o = reg1_i;
                    whilo_o = `WriteEnable;
                end
                default: begin
                    hi_o = `ZeroWord;
                    lo_o = `ZeroWord;
                    whilo_o = `WriteDisable;
                end
            endcase
    end


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
                `EXE_RES_MOVE:  wdata_o = move_calu;
                default: wdata_o = `ZeroWord;
            endcase
    end

    
endmodule