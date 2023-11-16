//---------------------------- id.v ----------------------------//
// 完成操作码解码的部分
`include "../Include/define.v"
module id (
    input rst,
    input [`InstAddressBus] pc_i,
    input [`InstDataBus] inst_i,
    input [`RegisterBus] reg1_data_i,
    input [`RegisterBus] reg2_data_i,

    input [`RegisterBus] mem_wdata_i,
    input [`RegisterAddressBus] mem_wd_i,
    input mem_wreg_i,

    input [`RegisterBus] ex_wdata_i,
    input [`RegisterAddressBus] ex_wd_i,
    input ex_wreg_i,

    input is_in_delayslot_i,

    input [`ALUOpBus] ex_aluop_i,

    output reg [`ALUOpBus] aluop_o,
    output reg [`ALUSelBus] alusel_o,

    
    output reg [`RegisterAddressBus] wd_o,
    output reg wreg_o,
    
    output reg [`RegisterBus] reg1_o,
    output reg [`RegisterAddressBus] reg1_addr_o,
    output reg reg1_read_o,

    output reg [`RegisterBus] reg2_o,
    output reg [`RegisterAddressBus] reg2_addr_o,
    output reg reg2_read_o,

    output stallreq,

    output reg is_in_delayslot_o,
    output reg [`RegisterBus] link_addr_o,
    output reg next_inst_in_delayslot_o,
    output reg [`RegisterBus] branch_target_address_o,
    output reg branch_flag_o,

    output [`InstDataBus] inst_o
);

reg instvalid;


// assign stallreq = `NoStop;

assign inst_o = inst_i;

// 指令码、功能码：需要对应 P11 页的指令格式
// R 类型的指令由 inst_i[31:26] 以及 inst_i[5:0] 指定
// I 类型的指令由 inst_i[31:26] 指定
wire [5:0] op = inst_i[31:26];
wire [4:0] op2 = inst_i[10:6];
wire [5:0] op3 = inst_i[5:0];
wire [4:0] op4 = inst_i[20:16];
// 立即数
reg  [`RegisterBus] immediate;

wire [`RegisterBus] pc_add_8;
wire [`RegisterBus] pc_add_4;
wire [`RegisterBus] signed_extend_offset;


assign pc_add_8 = pc_i + 8; // 保存当前译码阶段指令后面第2条指令的地址
assign pc_add_4 = pc_i + 4; // 保存当前译码阶段指令后面紧接着的指令的地址
// 对应分支指令中的offset左移两位，再符号扩展至32位的值
assign signed_extend_offset = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};

//------------------------------------------------------------------//
// 根据操作码完成对应的配置
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

        link_addr_o = `ZeroWord;
        next_inst_in_delayslot_o = `NotInDelaySlot;
        branch_target_address_o = `ZeroWord;
        branch_flag_o = `NotInDelaySlot;

    end
    else
        aluop_o = `EXE_NOR_OP;
        alusel_o = `EXE_RES_NOP;

        // 配置地址为 rd 的通用寄存器保存运算结果
        wd_o = inst_i[15:11];
        wreg_o = `WriteDisable;
        // 配置为源寄存器 rs
        reg1_addr_o = inst_i[25:21];
        reg1_read_o = 1'b0;
        // 配置为目的寄存器 rt
        reg2_addr_o = inst_i[20:16];
        reg2_read_o = 1'b0;

        immediate = `ZeroWord;

        link_addr_o = `ZeroWord;
        next_inst_in_delayslot_o = `NotInDelaySlot;
        branch_target_address_o = `ZeroWord;
        branch_flag_o = `NotInDelaySlot;

        case(op)
            `EXE_SPECIAL_INST: begin
                case(op2)
                    5'b00000:
                        case(op3)
                            `EXE_OR: begin
                                // 允许写通用寄存器
                                wreg_o = `WriteEnable;
                                // 设定运算操作指令
                                aluop_o = `EXE_OR_OP;
                                // 设定为逻辑运算
                                alusel_o = `EXE_RES_LOGIC;
                                // 1'b1 表示 reg1 以及 reg2 
                                // 均需要从通用寄存器中取值
                                // 取值的通用寄存器的地址默认为 inst_i[25:21] 以及 inst_i[20:16]
                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;

                            end

                            `EXE_AND: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_AND_OP;
                                alusel_o = `EXE_RES_LOGIC;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end

                            `EXE_XOR: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_XOR_OP;
                                alusel_o = `EXE_RES_LOGIC;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end

                            `EXE_NOR: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_NOR_OP;
                                alusel_o = `EXE_RES_LOGIC;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end

                            `EXE_SLLV: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_SLL_OP;
                                // 设定为移位运算
                                alusel_o = `EXE_RES_SHIFT;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end

                            `EXE_SRLV: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_SRL_OP;
                                alusel_o = `EXE_RES_SHIFT;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end

                            `EXE_SRAV: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_SRA_OP;
                                alusel_o = `EXE_RES_SHIFT;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end
                            // openmips 没用用到，因此相当于 nop 指令
                            `EXE_SYNC: begin
                                wreg_o = `WriteDisable;
                                aluop_o = `EXE_NOP_OP;
                                alusel_o = `EXE_RES_NOP;

                                reg1_read_o = 1'b0;
                                reg2_read_o = 1'b1;
                            end

                            `EXE_MFHI: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_MFHI_OP;
                                alusel_o = `EXE_RES_MOVE;

                                reg1_read_o = 1'b0;
                                reg2_read_o = 1'b0;
                            end

                            `EXE_MFLO: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_MFLO_OP;
                                alusel_o = `EXE_RES_MOVE;

                                reg1_read_o = 1'b0;
                                reg2_read_o = 1'b0;
                            end

                            `EXE_MTHI: begin
                                wreg_o = `WriteDisable;
                                aluop_o = `EXE_MTHI_OP;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b0;
                            end

                            `EXE_MTLO: begin
                                wreg_o = `WriteDisable;
                                aluop_o = `EXE_MTLO_OP;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b0;
                            end

                            `EXE_MOVN: begin
                                if(reg2_o != `ZeroWord)
                                    wreg_o = `WriteEnable;
                                else
                                    wreg_o = `WriteDisable;
                                
                                aluop_o = `EXE_MOVN_OP;
                                alusel_o = `EXE_RES_MOVE;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end

                            `EXE_MOVZ: begin
                                if(reg2_o == `ZeroWord)
                                    wreg_o = `WriteEnable;
                                else
                                    wreg_o = `WriteDisable;
                                
                                aluop_o = `EXE_MOVZ_OP;
                                alusel_o = `EXE_RES_MOVE;
                                
                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end

                            // 运算指令
                            `EXE_ADD: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_ADD_OP;
                                alusel_o = `EXE_RES_ARITHMETIC;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;

                            end
                            `EXE_ADDU: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_ADDU_OP;
                                alusel_o = `EXE_RES_ARITHMETIC;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end
                            `EXE_SUB: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_SUB_OP;
                                alusel_o = `EXE_RES_ARITHMETIC;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end
                            `EXE_SUBU: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_SUBU_OP;
                                alusel_o = `EXE_RES_ARITHMETIC;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end
                            `EXE_SLT: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_SLT_OP;
                                alusel_o = `EXE_RES_ARITHMETIC;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end
                            `EXE_SLTU: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_SLTU_OP;
                                alusel_o = `EXE_RES_ARITHMETIC;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end

                            // 这两个乘法指令将结果写入 HILO 特殊寄存器中，而不是通用寄存器中
                            // 写 HILO 特殊寄存器有效信号在 ex.v 中产生，id.v 中的写使能信号
                            // 只管通用寄存器
                            `EXE_MULT: begin
                                wreg_o = `WriteDisable;

                                aluop_o = `EXE_MULT_OP;
                                alusel_o = `EXE_RES_NOP;
                                
                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end
                            `EXE_MULTU: begin
                                wreg_o = `WriteDisable;

                                aluop_o = `EXE_MULTU_OP;
                                alusel_o = `EXE_RES_NOP;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end

                            `EXE_DIV: begin
                                wreg_o = `WriteDisable;

                                aluop_o = `EXE_DIV_OP;
                                alusel_o = `EXE_RES_NOP;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end

                            `EXE_DIVU: begin
                                wreg_o = `WriteDisable;

                                aluop_o = `EXE_DIVU_OP;
                                alusel_o = `EXE_RES_NOP;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                            end

                            `EXE_JR: begin
                                wreg_o = `WriteDisable;
                                link_addr_o = `ZeroWord;

                                aluop_o = `EXE_JR_OP;
                                alusel_o = `EXE_RES_JUMP_BRANCH;

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b0;
                                // 设置跳转 flag 有效，方便 pc_reg 模块进行赋值
                                branch_flag_o = `Branch;
                                // 注意这里要使用 reg1_o 而不是 reg1_data_i，因为 reg1_o
                                // 是解决数据相关问题后的结果
                                branch_target_address_o = reg1_o;

                                next_inst_in_delayslot_o = `InDelaySlot;
                            end

                            `EXE_JALR:begin

                                wd_o = inst_i[15:11];
                                wreg_o = `WriteEnable;
                                link_addr_o = pc_add_8;

                                aluop_o = `EXE_JALR_OP;
                                alusel_o = `EXE_RES_JUMP_BRANCH;
                                

                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b0;

                                branch_flag_o = `Branch;
                                branch_target_address_o = reg1_o;

                                next_inst_in_delayslot_o = `InDelaySlot;
                            end




                    default: begin
                    end 
                    endcase
                default: begin
                end   
                endcase
            end

            `EXE_SPECIAL2_INST: begin
                case(op3)

                    `EXE_CLZ: begin
                        wreg_o = `WriteEnable;

                        aluop_o = `EXE_CLZ_OP;
                        alusel_o = `EXE_RES_ARITHMETIC;

                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b0;

                    end

                    `EXE_CLO: begin
                        wreg_o = `WriteEnable;

                        aluop_o = `EXE_CLO_OP;
                        alusel_o = `EXE_RES_ARITHMETIC;

                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b0;

                    end

                    `EXE_MUL: begin
                        wreg_o = `WriteEnable;

                        aluop_o = `EXE_MUL_OP;
                        alusel_o = `EXE_RES_MUL;

                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                    end

                    // 累加、累减模块由于不需要将结果写入通用寄存器
                    // 因此这里将 alusel_o 置为 `EXE_RES_NOP
                    `EXE_MADD: begin
                        wreg_o = `WriteDisable;

                        aluop_o =  `EXE_MADD_OP;
                        alusel_o = `EXE_RES_NOP;

                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                    end

                    `EXE_MADDU: begin
                        wreg_o = `WriteDisable;

                        aluop_o =  `EXE_MADDU_OP;
                        alusel_o = `EXE_RES_NOP;

                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                    end

                    `EXE_MSUB: begin
                        wreg_o = `WriteDisable;

                        aluop_o =  `EXE_MSUB_OP;
                        alusel_o = `EXE_RES_NOP;

                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                    end

                    `EXE_MSUBU: begin
                        wreg_o = `WriteDisable;

                        aluop_o =  `EXE_MSUBU_OP;
                        alusel_o = `EXE_RES_NOP;

                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                    end

                    default: begin
                        
                    end

                endcase
            end

            `EXE_ORI: begin
                // 设定运算操作指令
                aluop_o = `EXE_OR_OP;
                // 设定为逻辑运算
                alusel_o = `EXE_RES_LOGIC;
                // 写入的通用寄存器的地址，需要注意的是因为这里的指令格式不再是 R 类型
                // 而是 I 类型，因此需要重新给出写入通用寄存器的地址
                wd_o = inst_i[20:16];
                // 允许写通用寄存器
                wreg_o = `WriteEnable;
                // reg1 需要用到寄存器内的数据，因此给出地址并将 reg1_read_o 置位为 1
                reg1_addr_o = inst_i[25:21];
                reg1_read_o = 1'b1;
                // reg2 需要用到立即数中的值，因此这里将 reg2_read_o 置位为 0 
                reg2_addr_o = `NOPRegisterAddress;
                reg2_read_o = 1'b0;

                immediate = {16'd0, inst_i[15:0]};
            end

            `EXE_ANDI: begin
                aluop_o = `EXE_AND_OP;
                alusel_o = `EXE_RES_LOGIC;
                wd_o = inst_i[20:16];
                wreg_o = `WriteEnable;

                reg1_addr_o = inst_i[25:21];
                reg1_read_o = 1'b1;

                reg2_addr_o = `NOPRegisterAddress;
                reg2_read_o = 1'b0;

                immediate = {16'd0, inst_i[15:0]};

            end

            `EXE_XORI: begin
                aluop_o = `EXE_XOR_OP;
                alusel_o = `EXE_RES_LOGIC;
                wd_o = inst_i[20:16];
                wreg_o = `WriteEnable;

                reg1_addr_o = inst_i[25:21];
                reg1_read_o = 1'b1;

                reg2_addr_o = `NOPRegisterAddress;
                reg2_read_o = 1'b0;

                immediate = {16'd0, inst_i[15:0]};

            end

            // LUI 实现的功能是将立即数中的值写入到寄存器的高 16 位中
            // 因为 LUI 的指令中 inst_i[25:21] 是 0 ，所以可以通过 OR
            // 将 immediate 写入
            `EXE_LUI: begin
                aluop_o = `EXE_OR_OP;
                alusel_o = `EXE_RES_LOGIC;
                wd_o = inst_i[20:16];
                wreg_o = `WriteEnable;

                reg1_addr_o = inst_i[25:21];
                reg1_read_o = 1'b1;

                reg2_addr_o = `NOPRegisterAddress;
                reg2_read_o = 1'b0;

                immediate = {inst_i[15:0], 16'd0};

            end

            // openmips 没用用到，因此相当于 nop 指令
            `EXE_PREF: begin
                aluop_o = `EXE_NOP_OP;
                alusel_o = `EXE_RES_NOP;
                wreg_o = `WriteDisable;

                reg1_read_o = 1'b0;

                reg2_read_o = 1'b0;


            end

            // 运算指令
            `EXE_ADDI: begin
                aluop_o = `EXE_ADDI_OP;
                alusel_o = `EXE_RES_ARITHMETIC;
                wd_o = inst_i[20:16];
                wreg_o = `WriteEnable;

                reg1_addr_o = inst_i[25:21];
                reg1_read_o = 1'b1;

                reg2_addr_o = `NOPRegisterAddress;
                reg2_read_o = 1'b0;

                immediate = {{16{inst_i[15]}}, inst_i[15:0]};
            end
            `EXE_ADDIU: begin
                aluop_o = `EXE_ADDIU_OP;
                alusel_o = `EXE_RES_ARITHMETIC;
                wd_o = inst_i[20:16];
                wreg_o = `WriteEnable;

                reg1_addr_o = inst_i[25:21];
                reg1_read_o = 1'b1;

                reg2_addr_o = `NOPRegisterAddress;
                reg2_read_o = 1'b0;

                immediate = {{16{inst_i[15]}}, inst_i[15:0]};
            end
            `EXE_SLTI: begin
                aluop_o = `EXE_SLTI_OP;
                alusel_o = `EXE_RES_ARITHMETIC;
                wd_o = inst_i[20:16];
                wreg_o = `WriteEnable;

                reg1_addr_o = inst_i[25:21];
                reg1_read_o = 1'b1;

                reg2_addr_o = `NOPRegisterAddress;
                reg2_read_o = 1'b0;

                immediate = {{16{inst_i[15]}}, inst_i[15:0]};
            end
            `EXE_SLTIU: begin
                aluop_o = `EXE_SLTIU_OP;
                alusel_o = `EXE_RES_ARITHMETIC;
                wd_o = inst_i[20:16];
                wreg_o = `WriteEnable;

                reg1_addr_o = inst_i[25:21];
                reg1_read_o = 1'b1;

                reg2_addr_o = `NOPRegisterAddress;
                reg2_read_o = 1'b0;

                immediate = {{16{inst_i[15]}}, inst_i[15:0]};
            end

            `EXE_J: begin
                wreg_o = `WriteDisable;

                aluop_o = `EXE_J_OP;
                alusel_o = `EXE_RES_JUMP_BRANCH;

                link_addr_o = `ZeroWord;
                

                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;

                branch_flag_o = `Branch;
                branch_target_address_o = {pc_add_4[31:28], inst_i[25:0], 2'b00};

                next_inst_in_delayslot_o = `InDelaySlot;


            end

            `EXE_JAL:begin
                wreg_o = `WriteEnable;
                wd_o = 5'd31;

                aluop_o = `EXE_JAL_OP;
                alusel_o = `EXE_RES_JUMP_BRANCH;

                link_addr_o = pc_add_8;
                

                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;

                branch_flag_o = `Branch;
                branch_target_address_o = {pc_add_4[31:28], inst_i[25:0], 2'b00};

                next_inst_in_delayslot_o = `InDelaySlot;


            end

            `EXE_BEQ: begin
                wreg_o = `WriteDisable;

                aluop_o = `EXE_BEQ_OP;
                alusel_o = `EXE_RES_JUMP_BRANCH;

                link_addr_o = `ZeroWord;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;

                if(reg1_o == reg2_o) begin
                    branch_flag_o = `Branch;
                    branch_target_address_o = pc_add_4 + signed_extend_offset;
                    next_inst_in_delayslot_o = `InDelaySlot;                 
                end



            end

            `EXE_BNE: begin
                wreg_o = `WriteDisable;

                aluop_o = `EXE_BNE_OP;
                alusel_o = `EXE_RES_JUMP_BRANCH;

                link_addr_o = `ZeroWord;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;

                if(reg1_o != reg2_o) begin
                    branch_flag_o = `Branch;
                    branch_target_address_o = pc_add_4 + signed_extend_offset;
                    next_inst_in_delayslot_o = `InDelaySlot;                 
                end


            end


            `EXE_BGTZ: begin
                wreg_o = `WriteDisable;

                aluop_o = `EXE_BGTZ_OP;
                alusel_o = `EXE_RES_JUMP_BRANCH;

                link_addr_o = `ZeroWord;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;

                // 注意这里 reg1_o > 0 的判断方法
                if(reg1_o[31] == 1'b0 && reg1_o != `ZeroWord) begin
                    branch_flag_o = `Branch;
                    branch_target_address_o = pc_add_4 + signed_extend_offset;
                    next_inst_in_delayslot_o = `InDelaySlot;                 
                end


            end

            `EXE_BLEZ: begin
                wreg_o = `WriteDisable;

                aluop_o = `EXE_BLEZ_OP;
                alusel_o = `EXE_RES_JUMP_BRANCH;

                link_addr_o = `ZeroWord;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;

                // 注意这里 reg1_o <= 0 的判断方法
                if(reg1_o[31] == 1'b1 || reg1_o == `ZeroWord) begin
                    branch_flag_o = `Branch;
                    branch_target_address_o = pc_add_4 + signed_extend_offset;
                    next_inst_in_delayslot_o = `InDelaySlot;                 
                end


            end

            // 加载/存储指令
            `EXE_LB: begin
                wreg_o = `WriteEnable;

                aluop_o = `EXE_LB_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;

                wd_o = inst_i[20:16];
            end

            `EXE_LBU: begin
                wreg_o = `WriteEnable;

                aluop_o = `EXE_LBU_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;

                wd_o = inst_i[20:16];                    
            end

            `EXE_LH: begin
                wreg_o = `WriteEnable;

                aluop_o = `EXE_LH_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;

                wd_o = inst_i[20:16];
            end

            `EXE_LHU: begin
                wreg_o = `WriteEnable;

                aluop_o = `EXE_LHU_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;

                wd_o = inst_i[20:16];
            end

            `EXE_LW: begin
                wreg_o = `WriteEnable;

                aluop_o = `EXE_LW_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;

                wd_o = inst_i[20:16];
            end

            `EXE_LWL: begin
                wreg_o = `WriteEnable;

                aluop_o = `EXE_LWL_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;

                wd_o = inst_i[20:16];
            end

            `EXE_LWR: begin
                wreg_o = `WriteEnable;

                aluop_o = `EXE_LWR_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;

                wd_o = inst_i[20:16];
            end

            `EXE_SB: begin
                wreg_o = `WriteDisable;

                aluop_o = `EXE_SB_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;

            end

            `EXE_SH: begin
                 wreg_o = `WriteDisable;

                aluop_o = `EXE_SH_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;               
            end

            `EXE_SW: begin
                wreg_o = `WriteDisable;

                aluop_o = `EXE_SW_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;
            end

            `EXE_SWL: begin
                wreg_o = `WriteDisable;

                aluop_o = `EXE_SWL_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;
            end

            `EXE_SWR: begin
                wreg_o = `WriteDisable;

                aluop_o = `EXE_SWR_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;
            end

            `EXE_LL: begin
                wreg_o = `WriteEnable;

                aluop_o = `EXE_LL_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;

                wd_o = inst_i[20:16];
            end

            `EXE_SC: begin
                wreg_o = `WriteEnable;

                aluop_o = `EXE_SC_OP;
                alusel_o = `EXE_RES_LOAD_STORE;
                

                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;

                wd_o = inst_i[20:16];
            end



            // 需要注意的是这里需要再进行一级判断!!!
            `EXE_REGIMM_INST: begin
                case(op4)
                `EXE_BLTZ: begin
                    wreg_o = `WriteDisable;

                    aluop_o = `EXE_BLTZ_OP;
                    alusel_o = `EXE_RES_JUMP_BRANCH;

                    link_addr_o = `ZeroWord;
                    

                    reg1_read_o = 1'b1;
                    reg2_read_o = 1'b1;

                    // 注意这里 reg1_o < 0 的判断方法
                    if(reg1_o[31] == 1'b1 && reg1_o != `ZeroWord) begin
                        branch_flag_o = `Branch;
                        branch_target_address_o = pc_add_4 + signed_extend_offset;
                        next_inst_in_delayslot_o = `InDelaySlot;                 
                    end
                end

                `EXE_BGEZ: begin
                    wreg_o = `WriteDisable;

                    aluop_o = `EXE_BGEZ_OP;
                    alusel_o = `EXE_RES_JUMP_BRANCH;

                    link_addr_o = `ZeroWord;
                    

                    reg1_read_o = 1'b1;
                    reg2_read_o = 1'b0;

                    // 注意这里 reg1_o >= 0 的判断方法
                    if(reg1_o[31] == 1'b0 || reg1_o == `ZeroWord) begin
                        branch_flag_o = `Branch;
                        branch_target_address_o = pc_add_4 + signed_extend_offset;
                        next_inst_in_delayslot_o = `InDelaySlot;                 
                    end


                end

                `EXE_BLTZAL: begin
                    wreg_o = `WriteEnable;
                    wd_o = 5'd31;

                    aluop_o = `EXE_BLTZAL_OP;
                    alusel_o = `EXE_RES_JUMP_BRANCH;

                    link_addr_o = pc_add_8;
                    

                    reg1_read_o = 1'b1;
                    reg2_read_o = 1'b0;

                    if(reg1_o[31] == 1'b1 && reg1_o != `ZeroWord) begin
                        branch_flag_o = `Branch;
                        branch_target_address_o = pc_add_4 + signed_extend_offset;
                        next_inst_in_delayslot_o = `InDelaySlot;                 
                    end


                end

                `EXE_BGEZAL: begin
                    wreg_o = `WriteEnable;
                    wd_o = 5'd31;

                    aluop_o = `EXE_BGEZAL_OP;
                    alusel_o = `EXE_RES_JUMP_BRANCH;

                    link_addr_o = pc_add_8;
                    

                    reg1_read_o = 1'b1;
                    reg2_read_o = 1'b0;

                    if(reg1_o[31] == 1'b0 || reg1_o == `ZeroWord) begin
                        branch_flag_o = `Branch;
                        branch_target_address_o = pc_add_4 + signed_extend_offset;
                        next_inst_in_delayslot_o = `InDelaySlot;                 
                    end


                end
                default: begin
                    
                end

                endcase
            end






            default: begin
            end
        endcase

        // 这里需要简单说明一下：EXE_SLL 以及 EXE_SLLV 这两个不同的指令给出了
        // 相同的操作数，因为这两种具体的操作是相同的，都是向左移位，区别在于
        // EXE_SLL 是从 inst_i[10:6] 确定移位多少
        // EXE_SLLV 是从 inst_i[25:21] 确定移位多少
        // 这里的处理比较巧妙，实际上将两者的移位都写到 reg1 中了
        if (inst_i[31:21] == 11'b000_0000_0000) begin
            if(op3 == `EXE_SLL) begin
                aluop_o = `EXE_SLL_OP;
                alusel_o = `EXE_RES_SHIFT;
                wd_o = inst_i[15:11];
                wreg_o = `WriteEnable;

                reg1_addr_o = `NOPRegisterAddress;
                reg1_read_o = 1'b0;

                reg2_addr_o = inst_i[20:16];
                reg2_read_o = 1'b1;

                immediate[4:0] = inst_i[10:6];


            end
            else if(op3 == `EXE_SRL) begin
                aluop_o = `EXE_SRL_OP;
                alusel_o = `EXE_RES_SHIFT;
                wd_o = inst_i[15:11];
                wreg_o = `WriteEnable;

                reg1_addr_o = `NOPRegisterAddress;
                reg1_read_o = 1'b0;

                reg2_addr_o = inst_i[20:16];
                reg2_read_o = 1'b1;

                immediate[4:0] = inst_i[10:6];


            end
            else if(op3 == `EXE_SRA) begin
                aluop_o = `EXE_SRA_OP;
                alusel_o = `EXE_RES_SHIFT;
                wd_o = inst_i[15:11];
                wreg_o = `WriteEnable;

                reg1_addr_o = `NOPRegisterAddress;
                reg1_read_o = 1'b0;

                reg2_addr_o = inst_i[20:16];
                reg2_read_o = 1'b1;

                immediate[4:0] = inst_i[10:6];

            end



        end


    end

//------------------------------------------------------------------//
// 确定进行运算的源操作数 1 和源操作数 2，实际上就是一个 MUX
always@(*) begin
    if(rst == `ResetEnable) 
        reg1_o = `ZeroWord;
    else begin
        // 为了处理流水线相关问题，这里使用到了数据前推技巧（具体可以参考 P111）
        if(reg1_read_o == 1'b1 && ex_wreg_i == 1'b1 && ex_wd_i == reg1_addr_o)
            reg1_o = ex_wdata_i;
        // 为了处理流水线相关问题，这里使用到了数据前推技巧（具体可以参考 P111）
        else if(reg1_read_o == 1'b1 && mem_wreg_i == 1'b1 && mem_wd_i == reg1_addr_o)
            reg1_o = mem_wdata_i;
        // reg1_read_o == 1'b1 就使用寄存器中的值
        else if(reg1_read_o == 1'b1) 
            reg1_o = reg1_data_i;
        // reg1_read_o == 1'b0 就使用立即数中的值
        else
           reg1_o = immediate;

    end

end

always@(*) begin
    if(rst == `ResetEnable) 
        reg2_o = `ZeroWord;
    else begin
        if(reg2_read_o == 1'b1 && ex_wreg_i == 1'b1 && ex_wd_i == reg2_addr_o)
            reg2_o = ex_wdata_i;
        else if(reg2_read_o == 1'b1 && mem_wreg_i == 1'b1 && mem_wd_i == reg2_addr_o)
            reg2_o = mem_wdata_i;
        else if(reg2_read_o == 1'b1) 
            reg2_o = reg2_data_i;
        else
           reg2_o = immediate;
    end

end

//------------------------------------------------------------------//
// 输出变量 is_in_delayslot_o 表示当前译码阶段指令是否是延迟槽指令
always @(*) begin
    if(rst == `ResetEnable)
        is_in_delayslot_o = `NotInDelaySlot;
    else
        is_in_delayslot_o = is_in_delayslot_i;
end

//------------------------------------------------------------------//
// 处理 load 相关问题
reg stallreq_for_reg1_loadrelate;
reg stallreq_for_reg2_loadrelate;
wire pre_inst_is_load;

assign pre_inst_is_load = ((ex_aluop_i == `EXE_LB_OP) || (ex_aluop_i == `EXE_LBU_OP) ||
                           (ex_aluop_i == `EXE_LH_OP) || (ex_aluop_i == `EXE_LHU_OP) ||
                           (ex_aluop_i == `EXE_LW_OP) || (ex_aluop_i == `EXE_LWR_OP) ||
                           (ex_aluop_i == `EXE_LWL_OP)|| (ex_aluop_i == `EXE_LL_OP)  ||
                           (ex_aluop_i == `EXE_SC_OP)) ? 1'b1 : 1'b0;

// 如果上一条指令是加载指令，且该加载指令要加载到的目的寄存器就是当前指令
// 要通过 Regfile 模块读端口 1 读取的通用寄存器，那么表示存在 load 相关
// 设置 stallreq_for_reg1_loadrelate 为 stop
always @(*) begin
    stallreq_for_reg1_loadrelate <= `NoStop;
    if (rst == `ResetEnable)
        reg1_o <= `ZeroWord;
    else if (pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o && reg1_read_o == 1'b1)
        stallreq_for_reg1_loadrelate <= `Stop;
end

always @(*) begin
    stallreq_for_reg2_loadrelate <= `NoStop;
    if (rst == `ResetEnable)
        reg2_o <= `ZeroWord;
    else if (pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o && reg2_read_o == 1'b1)
        stallreq_for_reg2_loadrelate <= `Stop;
end

assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
endmodule