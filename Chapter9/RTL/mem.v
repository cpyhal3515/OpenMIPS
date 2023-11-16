//---------------------------- mem.v ----------------------------//
// Just a wire.
`include "../Include/define.v"
module mem (
    input rst,
    input [`RegisterBus] wdata_i,
    input [`RegisterAddressBus] wd_i,
    input wreg_i,


    input [`RegisterBus] hi_i,
    input [`RegisterBus] lo_i,
    input whilo_i,

    input [`ALUOpBus] aluop_i,
    input [`RegisterBus] mem_addr_i,
    input [`RegisterBus] reg2_i,
    input [`RegisterBus] mem_data_i,

    input LLbit_i,
    input wb_LLbit_we_i,
    input wb_LLbit_value_i,


    output reg [`RegisterBus] wdata_o,
    output reg [`RegisterAddressBus] wd_o,
    output reg wreg_o,

    output reg [`RegisterBus] hi_o,
    output reg [`RegisterBus] lo_o,
    output reg whilo_o,

    output reg [`RegisterBus] mem_addr_o,
    output reg mem_we_o,
    output reg [3:0] mem_sel_o,
    output reg [`RegisterBus] mem_data_o,
    output reg mem_ce_o,

    output reg LLbit_we_o,
    output reg LLbit_value_o

);
reg LLbit;
always @ (*) begin
    if(rst == `ResetEnable) 
        LLbit = 1'b0;
    else begin
        if(wb_LLbit_we_i == 1'b1) 
            LLbit = wb_LLbit_value_i;
        else
            LLbit <= LLbit_i;
    end
end

always @(*) begin
    if(rst == `ResetEnable) begin
        wdata_o = `ZeroWord;
        wd_o = `NOPRegisterAddress;
        wreg_o = `WriteDisable;
        hi_o = `ZeroWord;
        lo_o = `ZeroWord;
        whilo_o = `WriteDisable;

        mem_addr_o = `ZeroWord;
        mem_we_o = `WriteDisable;
        mem_sel_o = 4'b0000;
        mem_data_o = `ZeroWord;
        mem_ce_o = `ChipDisable;

        LLbit_we_o = 1'b0;
        LLbit_value_o = 1'b0;
    end
    else begin
        wd_o = wd_i;
        wreg_o = wreg_i;  
        wdata_o = wdata_i;
        
        hi_o = hi_i;
        lo_o = lo_i;
        whilo_o = whilo_i;

        mem_addr_o = `ZeroWord;
        mem_we_o = `WriteDisable;
        mem_sel_o = 4'b1111;
        mem_data_o = `ZeroWord;
        mem_ce_o = `ChipDisable; 

        LLbit_we_o = 1'b0;
        LLbit_value_o = 1'b0;

        case (aluop_i)
            `EXE_LB_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `WriteDisable;
                mem_ce_o = `ChipEnable;

                case(mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o = 4'b1000;
                        wdata_o = {{24{mem_data_i[31]}}, mem_data_i[31:24]};
                    end
                    2'b01: begin
                        mem_sel_o = 4'b0100;
                        wdata_o = {{24{mem_data_i[23]}}, mem_data_i[23:16]};
                    end
                    2'b10: begin
                        mem_sel_o = 4'b0010;
                        wdata_o = {{24{mem_data_i[15]}}, mem_data_i[15:8]};
                    end
                    2'b11: begin
                        mem_sel_o = 4'b0001;
                        wdata_o = {{24{mem_data_i[7]}}, mem_data_i[7:0]};
                    end
                    default: begin
                        wdata_o = `ZeroWord;
                    end
                endcase
            end

            `EXE_LBU_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `WriteDisable;
                mem_ce_o = `ChipEnable;

                case(mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o = 4'b1000;
                        wdata_o = {{24{1'b0}}, mem_data_i[31:24]};
                    end
                    2'b01: begin
                        mem_sel_o = 4'b0100;
                        wdata_o = {{24{1'b0}}, mem_data_i[23:16]};
                    end
                    2'b10: begin
                        mem_sel_o = 4'b0010;
                        wdata_o = {{24{1'b0}}, mem_data_i[15:8]};
                    end
                    2'b11: begin
                        mem_sel_o = 4'b0001;
                        wdata_o = {{24{1'b0}}, mem_data_i[7:0]};
                    end
                    default: begin
                        wdata_o = `ZeroWord;
                    end
                endcase
            end

            `EXE_LH_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `WriteDisable;
                mem_ce_o = `ChipEnable;

                case(mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o = 4'b1100;
                        wdata_o = {{16{mem_data_i[31]}}, mem_data_i[31:16]};
                    end
                    2'b10: begin
                        mem_sel_o = 4'b0011;
                        wdata_o = {{16{mem_data_i[15]}}, mem_data_i[15:0]};
                    end
                    default: begin
                        wdata_o = `ZeroWord;
                    end
                endcase
            end

            `EXE_LHU_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `WriteDisable;
                mem_ce_o = `ChipEnable;

                case(mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o = 4'b1100;
                        wdata_o = {{16{1'b0}}, mem_data_i[31:16]};
                    end
                    2'b10: begin
                        mem_sel_o = 4'b0011;
                        wdata_o = {{16{1'b0}}, mem_data_i[15:0]};
                    end
                    default: begin
                        wdata_o = `ZeroWord;
                    end
                endcase
            end

            `EXE_LW_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `WriteDisable;
                mem_ce_o = `ChipEnable;
                mem_sel_o = 4'b1111;
                wdata_o = mem_data_i;             
            end

            // 因为 LWL 指令要从 RAM 中读出一个字
            // 因此需要将地址对齐，同时设置 mem_sel_o 为 4'b1111
            `EXE_LWL_OP: begin
                mem_addr_o = {mem_addr_i[31:2], 2'b00};
                mem_we_o = `WriteDisable;
                mem_ce_o = `ChipEnable;
                mem_sel_o = 4'b1111;

                case(mem_addr_i[1:0])
                    2'b00: wdata_o = mem_data_i;
                    2'b01: wdata_o = {mem_data_i[23:0], reg2_i[7:0]};
                    2'b10: wdata_o = {mem_data_i[15:0], reg2_i[15:0]};
                    2'b11: wdata_o = {mem_data_i[7:0], reg2_i[23:0]};
                    default: begin
                        wdata_o = `ZeroWord;
                    end
                endcase
            end

            `EXE_LWR_OP: begin
                mem_addr_o = {mem_addr_i[31:2], 2'b00};
                mem_we_o = `WriteDisable;
                mem_ce_o = `ChipEnable;
                mem_sel_o = 4'b1111;

                case(mem_addr_i[1:0])
                    2'b00:  wdata_o = {reg2_i[31:8], mem_data_i[31:24]};
                    2'b01:  wdata_o = {reg2_i[31:16], mem_data_i[31:16]};
                    2'b10:  wdata_o = {reg2_i[31:24], mem_data_i[31:8]};
                    2'b11:  wdata_o = mem_data_i;
                    default: begin
                        wdata_o = `ZeroWord;
                    end
                endcase
            end


            // 这里先将 mem_data_o 全部置位 reg2_i[7:0]
            // 然后通过选通信号 mem_sel_o 写入对应的数据存储器
            // 为了与 Wishbone 总线保持一致
            `EXE_SB_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `WriteEnable;
                mem_ce_o = `ChipEnable;
                mem_data_o = {reg2_i[7:0], reg2_i[7:0], reg2_i[7:0], reg2_i[7:0]};
                case(mem_addr_i[1:0])
                    2'b00: mem_sel_o = 4'b1000;
                    2'b01: mem_sel_o = 4'b0100;
                    2'b10: mem_sel_o = 4'b0010;
                    2'b11: mem_sel_o = 4'b0001;
                    default: begin
                        mem_sel_o = 4'b0000;
                    end
                endcase
            end

            `EXE_SH_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `WriteEnable;
                mem_ce_o = `ChipEnable;
                mem_data_o = {reg2_i[15:0], reg2_i[15:0]};

                case(mem_addr_i[1:0])
                    2'b00: mem_sel_o = 4'b1100;
                    2'b10: mem_sel_o = 4'b0011;
                    default: begin
                        mem_sel_o = 4'b0000;
                    end
                endcase
            end

            `EXE_SW_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `WriteEnable;
                mem_ce_o = `ChipEnable;
                mem_data_o = reg2_i;
                mem_sel_o = 4'b1111;

                
            end

            `EXE_SWL_OP: begin
                mem_addr_o = {mem_addr_i[31:2], 2'b00};
                mem_we_o = `WriteEnable;
                mem_ce_o = `ChipEnable;

                case(mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o = 4'b1111;
                        mem_data_o = reg2_i;
                    end
                    2'b01: begin
                        mem_sel_o = 4'b0111;
                        mem_data_o = {8'd0, reg2_i[31:8]};
                    end
                    2'b10: begin
                        mem_sel_o = 4'b0011;
                        mem_data_o = {16'd0, reg2_i[31:16]};
                    end
                    2'b11: begin
                        mem_sel_o = 4'b0001;
                        mem_data_o = {24'd0, reg2_i[31:24]};
                    end
                    default: begin
                        mem_sel_o = 4'b0000;
                    end
                endcase
            end

            `EXE_SWR_OP: begin
                mem_addr_o = {mem_addr_i[31:2], 2'b00};
                mem_we_o = `WriteEnable;
                mem_ce_o = `ChipEnable;

                case(mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o = 4'b1000;
                        wdata_o = {reg2_i[7:0], 24'd0};
                    end
                    2'b01: begin
                        mem_sel_o = 4'b1100;
                        mem_data_o = {reg2_i[15:0], 16'd0};
                    end
                    2'b10: begin
                        mem_sel_o = 4'b1110;
                        mem_data_o = {reg2_i[23:0], 8'd0};
                    end
                    2'b11: begin
                        mem_sel_o = 4'b1111;
                        mem_data_o = reg2_i;
                    end
                    default: begin
                       mem_sel_o = 4'b0000;
                    end
                endcase
            end

            `EXE_LL_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `WriteDisable;
                mem_ce_o = `ChipEnable;
                mem_sel_o = 4'b1111;
                wdata_o = mem_data_i;
                LLbit_we_o = 1'b1;
                LLbit_value_o = 1'b1;
            end

            `EXE_SC_OP: begin
                if(LLbit == 1'b1) begin
                    mem_addr_o = mem_addr_i;
                    mem_we_o = `WriteEnable;
                    mem_ce_o = `ChipEnable;
                    mem_data_o = reg2_i;
                    mem_sel_o = 4'b1111;
                    wdata_o = 32'b1;
                    LLbit_we_o = 1'b1;
                    LLbit_value_o = 1'b0;

                end
                else
                    wdata_o = 32'b0;
            end


        default: begin
            
        end
        endcase   

    end

end 

    





    
endmodule