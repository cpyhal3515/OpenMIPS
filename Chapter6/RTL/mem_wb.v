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

    output reg [`RegisterBus] wb_wdata,
    output reg [`RegisterAddressBus] wb_wd,
    output reg wb_wreg,

    output reg [`RegisterBus] wb_hi,
    output reg [`RegisterBus] wb_lo,
    output reg wb_whilo

);



always@(posedge clk) begin
    if(rst == `ResetEnable) begin
        wb_wdata   <= `ZeroWord;
        wb_wd      <= `NOPRegisterAddress;
        wb_wreg    <= `WriteDisable;

        wb_hi <= `ZeroWord;
        wb_lo <= `ZeroWord;
        wb_whilo <= `WriteEnable;
    end
    else begin
        wb_wdata <= mem_wdata;
        wb_wd <= mem_wd;      
        wb_wreg <= mem_wreg;

        wb_hi <= mem_hi;
        wb_lo <= mem_lo;
        wb_whilo <= mem_whilo;

               
    end
end

    
endmodule