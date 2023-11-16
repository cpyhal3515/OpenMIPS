//---------------------------- mem_wb.v ----------------------------//
// Just a register.
`include "../Include/define.v"
module mem_wb (
    input clk,
    input rst,

    input [`RegisterBus] mem_wdata,
    input [`RegisterAddressBus] mem_wd,
    input mem_wreg,

    input [`RegisterBus] mem_hi,
    input [`RegisterBus] mem_lo,
    input mem_whilo,

    input [5:0] stall,

    input mem_LLbit_we,
    input mem_LLbit_value,

    input mem_cp0_reg_we,
    input [4:0] mem_cp0_reg_write_addr,
    input [`RegisterBus] mem_cp0_reg_data,

    input flush,

    output reg [`RegisterBus] wb_wdata,
    output reg [`RegisterAddressBus] wb_wd,
    output reg wb_wreg,

    output reg [`RegisterBus] wb_hi,
    output reg [`RegisterBus] wb_lo,
    output reg wb_whilo,

    output reg wb_LLbit_we,
    output reg wb_LLbit_value,

    output reg wb_cp0_reg_we,
    output reg [4:0] wb_cp0_reg_write_addr,
    output reg [`RegisterBus] wb_cp0_reg_data

);



always@(posedge clk) begin
    if(rst == `ResetEnable) begin
        wb_wdata   <= `ZeroWord;
        wb_wd      <= `NOPRegisterAddress;
        wb_wreg    <= `WriteDisable;
        wb_hi      <= `ZeroWord;
        wb_lo      <= `ZeroWord;
        wb_whilo   <= `WriteDisable;
        wb_LLbit_we <= 1'b0;
        wb_LLbit_value <= 1'b0;

        wb_cp0_reg_we <= `WriteDisable;
        wb_cp0_reg_write_addr <= 5'b00000;
        wb_cp0_reg_data <= `ZeroWord;

    end
    else begin
        if(flush == 1'b1) begin
            wb_wdata   <= `ZeroWord;
            wb_wd      <= `NOPRegisterAddress;
            wb_wreg    <= `WriteDisable;
            wb_hi      <= `ZeroWord;
            wb_lo      <= `ZeroWord;
            wb_whilo   <= `WriteDisable;
            wb_LLbit_we <= 1'b0;
            wb_LLbit_value <= 1'b0;

            wb_cp0_reg_we <= `WriteDisable;
            wb_cp0_reg_write_addr <= 5'b00000;
            wb_cp0_reg_data <= `ZeroWord;
        end

        else if(stall[5] == `NoStop && stall[4] == `Stop) begin
            wb_wdata <= `ZeroWord;
            wb_wd    <= `NOPRegisterAddress;
            wb_wreg  <= `WriteDisable;
            wb_hi    <= `ZeroWord;
            wb_lo    <= `ZeroWord;
            wb_whilo <= `WriteDisable;

            wb_LLbit_we <= 1'b0;
            wb_LLbit_value <= 1'b0;

            wb_cp0_reg_we <= `WriteDisable;
            wb_cp0_reg_write_addr <= 5'b00000;
            wb_cp0_reg_data <= `ZeroWord;
        end
        else if(stall[4] == `NoStop) begin
            wb_wdata <= mem_wdata;
            wb_wd <= mem_wd;      
            wb_wreg <= mem_wreg;

            wb_hi <= mem_hi;
            wb_lo <= mem_lo;
            wb_whilo <= mem_whilo;

            wb_LLbit_we <= mem_LLbit_we;
            wb_LLbit_value <= mem_LLbit_value;

            wb_cp0_reg_we <= mem_cp0_reg_we;
            wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
            wb_cp0_reg_data <= mem_cp0_reg_data;
        end

               
    end
end

    
endmodule