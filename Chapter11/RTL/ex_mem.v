//---------------------------- ex_mem.v ----------------------------//
// Just a register.
`include "../Include/define.v"
module ex_mem (
    input clk,
    input rst,

    input [`RegisterBus] ex_wdata,
    input [`RegisterAddressBus] ex_wd,
    input ex_wreg,

    input [`RegisterBus] ex_hi,
    input [`RegisterBus] ex_lo,
    input ex_whilo,

    input [`ALUOpBus] ex_aluop,
    input [`RegisterBus] ex_mem_addr,
    input [`RegisterBus] ex_reg2,

    input [5:0] stall,
    input [1:0] cnt_i,
    input [`DoubleRegisterBus] hilo_i,

    input ex_cp0_reg_we,
    input [4:0] ex_cp0_reg_write_addr,
    input [`RegisterBus] ex_cp0_reg_data,

    input [31:0] ex_excepttype,
    input ex_is_in_delayslot,
    input [`RegisterBus] ex_current_inst_address,

    input flush,


    output reg [`RegisterBus] mem_wdata,
    output reg [`RegisterAddressBus] mem_wd,
    output reg mem_wreg,

    output reg [`RegisterBus] mem_hi,
    output reg [`RegisterBus] mem_lo,
    output reg mem_whilo,

    output reg [`ALUOpBus] mem_aluop,
    output reg [`RegisterBus] mem_mem_addr,
    output reg [`RegisterBus] mem_reg2,

    output reg [1:0] cnt_o,
    output reg [`DoubleRegisterBus] hilo_o,

    output reg mem_cp0_reg_we,
    output reg [4:0] mem_cp0_reg_write_addr,
    output reg [`RegisterBus] mem_cp0_reg_data,

    output reg [31:0] mem_excepttype,
    output reg mem_is_in_delayslot,
    output reg [`RegisterBus] mem_current_inst_address


);



always@(posedge clk) begin
    if(rst == `ResetEnable) begin
        mem_wdata   <= `ZeroWord;
        mem_wd      <= `NOPRegisterAddress;
        mem_wreg    <= `WriteDisable;
        mem_hi      <= `ZeroWord;
        mem_lo      <= `ZeroWord;
        mem_whilo   <= `WriteDisable;

        mem_aluop   <= `EXE_NOR_OP;
        mem_mem_addr <= `ZeroWord;
        mem_reg2    <= `ZeroWord;

        mem_cp0_reg_we <= `WriteDisable;
        mem_cp0_reg_write_addr <= 5'b00000;
        mem_cp0_reg_data <= `ZeroWord;

        mem_excepttype <= `ZeroWord;
        mem_is_in_delayslot <= `NotInDelaySlot;
        mem_current_inst_address <= `ZeroWord;
    end
    else begin
        if(flush == 1'b1) begin
            mem_wdata   <= `ZeroWord;
            mem_wd      <= `NOPRegisterAddress;
            mem_wreg    <= `WriteDisable;
            mem_hi      <= `ZeroWord;
            mem_lo      <= `ZeroWord;
            mem_whilo   <= `WriteDisable;

            mem_aluop   <= `EXE_NOR_OP;
            mem_mem_addr <= `ZeroWord;
            mem_reg2    <= `ZeroWord;

            mem_cp0_reg_we <= `WriteDisable;
            mem_cp0_reg_write_addr <= 5'b00000;
            mem_cp0_reg_data <= `ZeroWord;

            mem_excepttype <= `ZeroWord;
            mem_is_in_delayslot <= `NotInDelaySlot;
            mem_current_inst_address <= `ZeroWord;
        end
        else if(stall[4] == `NoStop && stall[3] == `Stop) begin
            mem_wdata   <= `ZeroWord;
            mem_wd      <= `NOPRegisterAddress;
            mem_wreg    <= `WriteDisable;
            mem_hi      <= `ZeroWord;
            mem_lo      <= `ZeroWord;
            mem_whilo   <= `WriteDisable;

            mem_aluop   <= `EXE_NOR_OP;
            mem_mem_addr <= `ZeroWord;
            mem_reg2    <= `ZeroWord;

            mem_cp0_reg_we <= `WriteDisable;
            mem_cp0_reg_write_addr <= 5'b00000;
            mem_cp0_reg_data <= `ZeroWord;

            mem_excepttype <= `ZeroWord;
            mem_is_in_delayslot <= `NotInDelaySlot;
            mem_current_inst_address <= `ZeroWord;

        end
        else if(stall[3] == `NoStop) begin
            mem_wdata   <= ex_wdata;
            mem_wd      <= ex_wd;
            mem_wreg    <= ex_wreg;  
            mem_hi      <= ex_hi;
            mem_lo      <= ex_lo;
            mem_whilo   <= ex_whilo; 

            mem_aluop   <= ex_aluop;
            mem_mem_addr <= ex_mem_addr;
            mem_reg2    <= ex_reg2;

            mem_cp0_reg_we <= ex_cp0_reg_we;
            mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr;
            mem_cp0_reg_data <= ex_cp0_reg_data;

            mem_excepttype <= ex_excepttype;
            mem_is_in_delayslot <= ex_is_in_delayslot;
            mem_current_inst_address <= ex_current_inst_address;
        end


    end
end

// 累加、累乘对应的流水线暂停部分
// 如果流水线暂停，那就让 cnt_o = cnt_i; hilo_o = hilo_i;
// 如果流水线继续，那就让 cnt_o 和 hilo_o 都归零
always @(posedge clk) begin
    if(rst == `ResetEnable) begin
        cnt_o = 2'b00;
        hilo_o = {`ZeroWord,`ZeroWord};
    end
    else
        if(stall[4] == `NoStop && stall[3] == `Stop) begin
            cnt_o <= cnt_i;
            hilo_o <= hilo_i;
        end
        else if(stall[3] == `NoStop) begin
            cnt_o <= 2'b00;
            hilo_o <= {`ZeroWord,`ZeroWord};           
        end
        else begin
            cnt_o <= cnt_i;
            hilo_o <= hilo_i;
        end
end

    
endmodule