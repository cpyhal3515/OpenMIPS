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

    input [1:0] cnt_i,
    input [`DoubleRegisterBus] hilo_temp_i,

    input [`DoubleRegisterBus] div_result_i,
    input div_ready_i,

    output reg [`RegisterBus] wdata_o,
    output reg [`RegisterAddressBus] wd_o,
    output reg wreg_o,

    output reg whilo_o,
    output reg [`RegisterBus] hi_o,
    output reg [`RegisterBus] lo_o,

    output reg [1:0] cnt_o,
    output reg [`DoubleRegisterBus] hilo_temp_o,

    output reg stallreq,

    output reg div_start_o,
    output reg [`RegisterBus] div_opdata1_o,
    output reg [`RegisterBus] div_opdata2_o,
    output reg signed_div_o


);



    reg [`RegisterBus] logic_calu;
    reg [`RegisterBus] shift_calu;
    reg [`RegisterBus] move_calu;
    reg [`RegisterBus] arithmetic_calu;

    reg [`RegisterBus] HI, LO;

    // 简单运算对应的信号
    wire [`RegisterBus] reg1_i_not;
    wire [`RegisterBus] reg2_i_mux;
    wire [`RegisterBus] result_sum;
    wire ov_sum;
    reg reg1_lt_reg2;
    wire [`RegisterBus] opdata1_mult, opdata2_mult;
    wire [`DoubleRegisterBus] hilo_temp;
    reg [`DoubleRegisterBus]  mulres;
    reg [`DoubleRegisterBus] hilo_temp1;

    reg stallreq_for_madd_msub;
    reg stallreq_for_div;




    // 解决数据相关问题
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

//------------------------------------------------------------------//
    // 完成转移指令的相关操作
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
                `EXE_MULT_OP, `EXE_MULTU_OP: begin
                    hi_o = mulres[63:32];
                    lo_o = mulres[31:0];
                    whilo_o = `WriteEnable;
                end
                `EXE_MADD_OP, `EXE_MADDU_OP, `EXE_MSUB_OP, `EXE_MSUBU_OP: begin
                    hi_o = hilo_temp1[63:32];
                    lo_o = hilo_temp1[31:0];
                    whilo_o = `WriteEnable;
                end
                `EXE_DIV_OP, `EXE_DIVU_OP: begin
                    hi_o = div_result_i[63:32];
                    lo_o = div_result_i[31:0];
                    whilo_o = `WriteEnable;

                end

                default: begin
                    hi_o = `ZeroWord;
                    lo_o = `ZeroWord;
                    whilo_o = `WriteDisable;
                end
            endcase
    end
//------------------------------------------------------------------//

//------------------------------------------------------------------//
    // 完成逻辑运算指令的相关结果
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
//------------------------------------------------------------------//

//------------------------------------------------------------------//
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
//------------------------------------------------------------------//

//------------------------------------------------------------------//
// 完成加、减、比较这几个简单的计算指令
// Step1：计算 reg2_i 的补码
assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) || (aluop_i == `EXE_SLT_OP)) ? (~reg2_i + 1'b1) : reg2_i;
// Step2: 计算加和结果
assign result_sum = reg1_i + reg2_i_mux;
// Step3：根据加和结果以及输入数据的 + - 值判断是否有溢出
//        注意这里要根据 reg1_i 以及 reg2_i 的补码 reg2_i_mux 来判断
// assign ov_sum = ((!reg1_i[31] && !reg2_i[31] && result_sum[31]) || (reg1_i[31] && reg2_i[31] && !result_sum[31]));
assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31] && result_sum[31]) || (reg1_i[31] && reg2_i_mux[31] && !result_sum[31]));
// Step4：计算两个操作数的大小关系
always @(*) begin
    if(rst ==  `ResetEnable)
        reg1_lt_reg2 = 1'b0;
    else
        if(aluop_i == `EXE_SLTIU_OP)
            reg1_lt_reg2 = reg1_i < reg2_i;
        else if(aluop_i == `EXE_SLTI_OP)
            reg1_lt_reg2 = (reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && result_sum[31]) || (reg1_i[31] && reg2_i[31] && result_sum[31]);
end
// Step5: 对操作数 1 逐位取反
assign reg1_i_not = ~reg1_i;
// Step6：给 arithmetic_calu 变量赋值
always @(*) begin
    if(rst == `ResetEnable)
        arithmetic_calu = `ZeroWord;
    else
        case (aluop_i)
            // 加法
            `EXE_ADD_OP, `EXE_ADDI_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: arithmetic_calu = result_sum;
            // 减法
            `EXE_SUB_OP, `EXE_SUBU_OP: arithmetic_calu = result_sum;
            // 比较
            `EXE_SLT_OP, `EXE_SLTU_OP, `EXE_SLTI_OP, `EXE_SLTIU_OP: arithmetic_calu = reg1_lt_reg2;
            // 计数
            `EXE_CLZ_OP:begin //计数运算clz
				arithmetic_calu = reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
                                reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
                                reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
                                reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
                                reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
                                reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
                                reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
                                reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
                                reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
                                reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
                                reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
			end
			`EXE_CLO_OP:begin //计数运算clo
				arithmetic_calu = (reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 : reg1_i_not[29] ? 2 :
                                reg1_i_not[28] ? 3 : reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
                                reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 : reg1_i_not[23] ? 8 : 
                                reg1_i_not[22] ? 9 : reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
                                reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 : reg1_i_not[17] ? 14 : 
                                reg1_i_not[16] ? 15 : reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 : 
                                reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 : reg1_i_not[11] ? 20 :
                                reg1_i_not[10] ? 21 : reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 : 
                                reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 : reg1_i_not[5] ? 26 : 
                                reg1_i_not[4] ? 27 : reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 : 
                                reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32) ;
			end
            
            default: arithmetic_calu = `ZeroWord;
        endcase
    
end
// 完成乘这个简单的计算指令
// Step1: 完成有符号运算的补码计算（当运算数为复数时才取补码）
// 注意这里逻辑符号的优先级，要注意增加括号
assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) && reg1_i[31] == 1'b1) ? (~reg1_i + 1'b1) : reg1_i; 
assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) && reg2_i[31] == 1'b1) ? (~reg2_i + 1'b1) : reg2_i;
// Step2：完成调整后的乘法运算
assign hilo_temp = opdata1_mult * opdata2_mult;
// Step3：对完成的乘法结果进行对应的调整
always @(*) begin
    if(rst == `ResetEnable)
        mulres = {`ZeroWord, `ZeroWord};
    else if(aluop_i == `EXE_MUL_OP || aluop_i == `EXE_MULT_OP || aluop_i == `EXE_MADD_OP || aluop_i == `EXE_MSUB_OP)
        if(reg1_i[31] ^ reg2_i[31])
            mulres =  ~hilo_temp + 1'b1;
        else
            mulres =  hilo_temp;
    else
        mulres = hilo_temp;
end
// Step4：实现累加、累乘部分
always @(*) begin
    if(rst == `ResetEnable) begin
        cnt_o = 2'b00;
        hilo_temp_o = {`ZeroWord, `ZeroWord};
        stallreq_for_madd_msub = `NoStop;
        hilo_temp1 = {`ZeroWord, `ZeroWord};
    end
    else begin
        case(aluop_i)
            `EXE_MSUBU_OP, `EXE_MSUB_OP: begin
                if(cnt_i == 2'b00) begin
                    cnt_o = 2'b01;
                    hilo_temp_o = ~mulres + 1'b1;
                    stallreq_for_madd_msub = `Stop;
                end
                else if(cnt_i == 2'b01) begin
                    cnt_o = 2'b10;
                    hilo_temp1 = hilo_temp_i + {HI, LO};
                    hilo_temp_o = {`ZeroWord, `ZeroWord};
                    stallreq_for_madd_msub = `NoStop;
                end
            end
            `EXE_MADDU_OP, `EXE_MADD_OP: begin
                if(cnt_i == 2'b00) begin
                    cnt_o = 2'b01;
                    hilo_temp_o = mulres;
                    stallreq_for_madd_msub = `Stop;
                end
                else if(cnt_i == 2'b01) begin
                    cnt_o = 2'b10;
                    hilo_temp1 = hilo_temp_i + {HI, LO};
                    hilo_temp_o = {`ZeroWord, `ZeroWord};
                    stallreq_for_madd_msub = `NoStop;
                end
            end
            default: begin
                cnt_o = 2'b00;
                hilo_temp_o = {`ZeroWord, `ZeroWord};
                stallreq_for_madd_msub = `NoStop;
            end
    endcase

    end
end
// Step5：实现除法部分
always@(*) begin
    if(rst == `ResetEnable) begin 
        div_start_o = `DivStop;
        div_opdata1_o = `ZeroWord;
        div_opdata2_o = `ZeroWord;
        signed_div_o = 1'b0;
        stallreq_for_div = `NoStop;
    end
    else begin
        case(aluop_i)
            `EXE_DIV_OP: begin
                div_opdata1_o = reg1_i;
                div_opdata2_o = reg2_i;
                signed_div_o = 1'b1;
                if(div_ready_i == `DivResultNotReady) begin
                    div_start_o = `DivStart;
                    stallreq_for_div = `Stop;
                end
                else if(div_ready_i == `DivResultReady) begin
                    div_start_o = `DivStop;
                    stallreq_for_div = `NoStop;
                end
            end
            `EXE_DIVU_OP: begin
                div_opdata1_o = reg1_i;
                div_opdata2_o = reg2_i;
                signed_div_o = 1'b0;
                if(div_ready_i == `DivResultNotReady) begin
                    div_start_o = `DivStart;
                    stallreq_for_div = `Stop;
                end
                else if(div_ready_i == `DivResultReady) begin
                    div_start_o = `DivStop;
                    stallreq_for_div = `NoStop;
                end
            end
            default: begin
                div_start_o = `DivStop;
                div_opdata1_o = `ZeroWord;
                div_opdata2_o = `ZeroWord;
                signed_div_o = 1'b0;
                stallreq_for_div = `NoStop;
            end
        endcase
    end

    
end

always @(*) begin
    
end

// Step6：实现流水线暂停部分
always @(*) begin
    if(rst == `ResetEnable)
        stallreq = `NoStop;
    else
        stallreq = stallreq_for_madd_msub || stallreq_for_div;
end


//------------------------------------------------------------------//



    // 选通输出 logic/shift/move/arithmetic 的计算结果
    always@(*) begin
        if(rst == `ResetEnable) begin
            wdata_o = `ZeroWord;
            wd_o = `ZeroWord;
            wreg_o =`WriteDisable;
        end
        else
            wd_o = wd_i;
            if((aluop_i == `EXE_ADD_OP || aluop_i == `EXE_ADDI_OP || aluop_i == `EXE_SUB_OP) && ov_sum == 1'b1)
                wreg_o = `WriteDisable;
            else
                wreg_o = wreg_i;

            case (alusel_i)
                `EXE_RES_LOGIC: wdata_o = logic_calu;
                `EXE_RES_SHIFT: wdata_o = shift_calu;
                `EXE_RES_MOVE:  wdata_o = move_calu;
                `EXE_RES_ARITHMETIC: wdata_o = arithmetic_calu;
                `EXE_RES_MUL: wdata_o = mulres[31:0];
                
                default: wdata_o = `ZeroWord;
            endcase
    end

    
endmodule