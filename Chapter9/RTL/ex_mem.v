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
    output reg [`DoubleRegisterBus] hilo_o


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
    end
    else begin
        if(stall[4] == `NoStop && stall[3] == `Stop) begin
            mem_wdata   <= `ZeroWord;
            mem_wd      <= `NOPRegisterAddress;
            mem_wreg    <= `WriteDisable;
            mem_hi      <= `ZeroWord;
            mem_lo      <= `ZeroWord;
            mem_whilo   <= `WriteDisable;

            mem_aluop   <= `EXE_NOR_OP;
            mem_mem_addr <= `ZeroWord;
            mem_reg2    <= `ZeroWord;

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